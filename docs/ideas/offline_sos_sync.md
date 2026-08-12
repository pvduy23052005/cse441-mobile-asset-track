# Offline-First SOS & Media Sync (Lean Two-Phase Outbox with Fallback UX)

## Problem Statement
How might we enable factory line operators in network dead zones to report critical machine breakdowns in under 5 seconds with zero data loss, guaranteed sequential sync, and immediate local confirmation — without overwhelming mobile device resources or giving a false sense of security during total connectivity loss?

---

## Recommended Direction

### 1. The Two-Phase Atomic Outbox
When an Operator creates an emergency SOS in an offline or intermittent network zone, the application does not block or fail. Instead, it instantly commits the report to a local SQLite Outbox table within `< 100ms`, generating a unique `client_generated_id` (UUID v4) and saving the compressed image file to local app storage.

Upon detecting network connectivity:
* **Phase 1 (Instant SOS Notification Trigger):** The queue manager immediately flushes the ticket metadata (`machine_id`, `severity`, `description`, `created_at`, `client_generated_id`, `media_pending: true`) to Cloud Firestore via an idempotent `set(..., SetOptions(merge: true))` call. This allows Cloud Functions to trigger instant FCM push notifications to on-duty ME Engineers within `< 1.5s`, alerting them to the breakdown without waiting for slow image uploads.
* **Phase 2 (Asynchronous Media Pipeline):** The local queue uploader streams the compressed photo (max 300KB JPEG) to Firebase Storage in the background. Once the download URL is obtained, Firestore is updated with `photo_url` and `media_pending: false`, completing the ticket synchronization.

### 2. Dual-Track Industrial Fallback UX
Recognizing that software cannot bypass physical radio silence in shielded factory basements:
* **Offline Warning Banner & Sound Cue:** The SOS modal clearly displays a persistent amber warning badge: *"⚠️ Mất kết nối — Phiếu SOS đã được lưu vào hàng đợi máy và sẽ tự động gửi tới kỹ sư ngay khi có mạng."*
* **Immediate Physical Escalation Protocol:** For critical breakdown (`severity: CRITICAL` / Dừng chuyền), the app presents an explicit emergency fallback card with the workshop direct hotline and physical alert button instructions, ensuring operators don't wait passively in dead zones assuming maintenance is en route.
* **Startup Queue Reconciliation:** On every cold start, the app inspects the SQLite queue to resume any uncompleted uploads, preventing abandoned drafts if the user kills the application.

---

## Key Assumptions to Validate

- [ ] **Assumption 1 (ME Triage without initial photo):** ME Engineers can immediately identify the urgency and location from `machine_id` and `severity` before Phase 2 photo upload finishes.  
  *Validation:* Review typical incident response logs with workshop ME team to verify if knowing machine code + fault category is sufficient for dispatch.
- [ ] **Assumption 2 (Idempotency under unstable flapping networks):** Repeated network flapping (Wi-Fi reconnecting and dropping rapidly) does not produce duplicate Firestore tickets or orphaned Storage files.  
  *Validation:* Automated integration test simulating network drops during Phase 1 and Phase 2 with the same `client_generated_id`.
- [ ] **Assumption 3 (Local SQLite performance on low-end devices):** Writing ticket metadata and caching compressed JPEG paths takes `< 100ms` on entry-level Android devices without UI stuttering.  
  *Validation:* Benchmark on physical Android test device (Android 10+, 2GB RAM).

---

## MVP Scope

### In Scope (What We Are Building)
1. **Local SQLite Outbox Table (`sos_outbox`):**
   * Columns: `id`, `client_generated_id`, `machine_id`, `machine_name`, `severity`, `description`, `photo_local_path`, `status` (`QUEUED`, `SYNCING_DOC`, `SYNCING_MEDIA`, `COMPLETED`, `FAILED`), `retry_count`, `created_at`.
2. **Instant Local Submission UX:**
   * Local ticket creation in `< 100ms` with visual queue badge and non-blocking screen dismissal.
3. **Two-Phase Background Sync Engine (Riverpod / ConnectivityPlus):**
   * Phase 1: Firestore document write with `client_generated_id` as document ID.
   * Phase 2: Firebase Storage upload with retry backoff + Firestore doc update.
4. **App Startup Queue Recovery:**
   * Automatic queue check and resumption whenever the app starts up or regains connectivity.
5. **Industrial Offline Fallback Banner:**
   * Warning banner and physical dispatch instructions for `CRITICAL` severity tickets.

### Out of Scope / Not Doing (and Why)
- **Peer-to-Peer / Bluetooth Mesh Alerting:** *Not doing* — Adds massive battery consumption, requires all workers to keep Bluetooth active, and introduces high architectural complexity for single workshop SME scope.
- **Complex Conflict Resolution (CRDTs / Multi-master merge):** *Not doing* — SOS tickets are append-only incident reports created by a single operator. Simple Last-Write-Wins and unique `client_generated_id` are completely sufficient.
- **Chunked Resumable Video Uploads:** *Not doing* — Factory SOS requires fast static photo evidence (compressed JPEG < 300KB); video uploads consume excessive factory mobile bandwidth.
- **Full Offline Database Mirroring:** *Not doing* — Operators only need machine passport cached lookup and SOS queue, not the entire factory history.

---

## Open Questions

1. **Retry Limit & Failure Handling:** If a photo upload fails continuously after 5 retry attempts (e.g. corrupted local file), should the ticket remain flagged as `media_failed` while preserving the Firestore document, or alert the operator via a local notification?
2. **Audio Note Attachment in Phase 1:** Should an optional 5-second voice memo be grouped with Phase 1 payload or deferred to Phase 2 along with the photo?
