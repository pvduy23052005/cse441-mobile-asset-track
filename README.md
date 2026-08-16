# AssetTrack - Hệ Thống Quản Lý Lý Lịch Thiết Bị & Bảo Trì Nhà Máy

> Ứng dụng di động quản lý lý lịch thiết bị, bảo trì phòng ngừa (PM) & báo sự cố khẩn cấp (SOS Ticket) cho nhà máy sản xuất.

---

## 1. Mô Tả Bài Toán Thực Tế (Problem Statement)

Trong các nhà máy sản xuất công nghiệp, sự cố hỏng hóc máy móc đột xuất (Breakdown) gây dừng dây chuyền sản xuất (Downtime), dẫn đến thiệt hại kinh tế rất lớn. Các bất cập chính bao gồm:

- **Thiếu bảo trì phòng ngừa:** Công nhân vận hành không theo dõi sát số giờ chạy thực tế của máy để thực hiện bảo dưỡng định kỳ (thay dầu, kiểm tra áp suất, siết ốc...).
- **Quy trình báo sự cố thủ công & chậm trễ:** Báo hỏng qua giấy tờ hoặc tin nhắn chat không gửi được thông báo khẩn cấp tới kỹ sư cơ điện, gây kéo dài thời gian chờ đợi (MTTR).
- **Thiếu lý lịch thiết bị & minh chứng nghiệm thu:** Không lưu lại lịch sử sửa chữa, vật tư đã thay thế và thiếu cam kết trách nhiệm nghiệm thu giữa Quản đốc và Kỹ sư.

**Bối cảnh vận hành thực tế — Nhà xưởng Quy mô Vừa & Nhỏ (SME):**

- **Đặc điểm:** Số lượng máy móc < 50 máy, đội ngũ kỹ sư bảo trì từ 3 – 7 người, không có thủ kho riêng trực ca 24/7 (hoặc thủ kho chỉ làm giờ hành chính).
- **Quy trình lấy vật tư:** Vật tư tiêu hao cơ bản (dầu mỡ, bu-lông, gioăng, đai curoa...) được để sẵn ở _Tủ vật tư nhanh_ tại phân xưởng. Kỹ sư ME là người **TỰ LẤY**: Khi máy hỏng, ME ra tủ lấy linh kiện và tự thay vào máy.
- **Cách AssetTrack hỗ trợ:** ME mở app, chọn các món đồ vừa lấy để **Ghi log (Spare Parts Logging - Tính năng 6)**. Việc ghi log này giúp hệ thống lưu lại lý lịch sửa chữa của máy và trừ lùi số lượng để Quản đốc biết khi nào tủ vật tư sắp hết.

**Giải pháp AssetTrack:** Xây dựng hệ thống ứng dụng di động kết nối 3 tác nhân trong nhà máy, số hóa toàn bộ Hộ chiếu thiết bị bằng mã QR, tự động hóa quy trình bảo trì định kỳ theo số giờ máy chạy, gửi thông báo SOS thời gian thực và xác thực nghiệm thu bằng chữ ký số cảm ứng.

---

## 2. Các Tác Nhân Chính & Phân Công Nhiệm Vụ (Core Actors & Team Assignment)

| Tác nhân (Actor) | Thành viên Phụ trách | Phạm vi Chức năng Cốt lõi |
| :--- | :--- | :--- |
| **1. Công nhân Vận hành (Operator)** | **Phùng Văn Duy (2351170589)** | • **QR Machine Passport:** Quét mã QR (`mobile_scanner`), tra cứu Hộ chiếu thiết bị, thông số kỹ thuật, cẩm nang lỗi.<br>• **Running Hours Logging:** Khai báo số giờ chạy máy / km đầu/cuối ca, validation real-time.<br>• **Breakdown SOS Ticket:** Tạo Ticket báo hỏng khẩn cấp, chọn mức độ nghiêm trọng, chụp ảnh hiện trường qua camera.<br>• **Cloudflare Image Upload:** Tích hợp module upload & tối ưu hóa ảnh hiện trường lên Cloudflare (Cloudflare R2 / Images).<br>• **Offline Mode (NFR-06):** Local cache SQLite, lưu tạm giờ chạy & Ticket khi mất mạng, tự động đồng bộ khi có kết nối. |
| **2. Kỹ sư Cơ điện (ME Engineer)** | **Lê Quý Dương (2351170587)** | • Nhận Push Notification khẩn cấp thời gian thực khi có Ticket SOS.<br>• Tiếp nhận Ticket sửa chữa, thực hiện PM Checklist bảo trì định kỳ kèm ảnh minh chứng bắt buộc.<br>• Ghi nhận log vật tư tủ nhanh và gửi đề xuất linh kiện đắt tiền lên Quản đốc. |
| **3. Quản đốc Phân xưởng (Supervisor)** | **Lê Quý Dương (2351170587)** | • Giám sát thời gian dừng máy (Downtime), đo lường chỉ số hiệu suất phân xưởng qua Real-time Dashboard.<br>• Phê duyệt đề xuất linh kiện đắt tiền vượt ngưỡng chi phí cấu hình.<br>• Ký tên điện tử nghiệm thu trực tiếp trên màn hình cảm ứng để đưa máy về `Active` hoặc từ chối kèm lý do (`Rejected`).<br>• Quản lý và import danh sách nhân sự phân xưởng từ file Excel. |

---

## 3. Công Nghệ Sử Dụng (Technology Stack)

### Mobile Application (Core App):

- **Framework:** [Flutter](https://flutter.dev/) (Dart) — Phát triển ứng dụng di động đa nền tảng (Android / iOS).
- **State Management:** Riverpod.
- **QR Code Scanner:** `mobile_scanner` (decode mã QR trong < 1.5s).
- **Digital Signature:** `signature` Canvas SDK (xuất ảnh chữ ký PNG).
- **Image Storage & CDN:** Cloudflare (Cloudflare R2 Storage / Cloudflare Images).
- **Offline Storage & Sync:** SQLite (`sqflite`) lưu trữ Local Queue khi mất mạng, tự động đồng bộ khi có kết nối trở lại.

### Backend & Infrastructure:

- **BaaS Platform:** [Supabase](https://supabase.com/) / Firebase (PostgreSQL / Firestore NoSQL).
- **Cloud Storage:** Cloudflare R2 / Firebase Storage lưu trữ ảnh lỗi và ảnh chữ ký.
- **Security:** Row-Level Security (RLS) / Security Rules phân quyền theo phân xưởng (`workshop_id`).
- **Realtime & Cloud Functions:** Database Triggers, Cloud Functions.
- **Push Notification:** Firebase Cloud Messaging (FCM).

### Web Mobile Demo:

- **Framework:** Next.js 16 (App Router) + TypeScript + Tailwind CSS v4 + shadcn/ui (dùng cho bản trải nghiệm giao diện Web di động tại thư mục `ui/`).

---

## 4. Hướng Dẫn Cài Đặt Và Chạy Ứng Dụng (Installation & Setup Guide)

### 4.1. Chạy Ứng Dụng Di Động Flutter (Flutter Mobile App)

#### Yêu cầu tiền đề:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ($\ge 3.19.0$)
- Android Studio / Xcode / VS Code
- Thiết bị thật hoặc Emulator (Android/iOS)

#### Các bước thực hiện:

```bash
# 1. Di chuyển vào thư mục dự án Flutter gốc
cd /Users/macbook/Documents/hk6/mobile/project

# 2. Tải các gói thư viện phụ thuộc (Dependencies)
flutter pub get

# 3. Kiểm tra thiết bị sẵn sàng
flutter devices

# 4. Chạy ứng dụng trên thiết bị di động
flutter run
```

---

### 4.2. Chạy Bản Trải Nghiệm Giao Diện Web Mobile (Next.js Demo)

#### Yêu cầu tiền đề:

- Node.js ($\ge 18.x$)
- npm ($\ge 9.x$)

#### Các bước thực hiện:

```bash
# 1. Di chuyển vào thư mục giao diện UI
cd /Users/macbook/Documents/hk6/mobile/project/ui

# 2. Cài đặt các gói npm
npm install

# 3. Khởi động Server phát triển (Dev Server)
npm run dev
```

Trình duyệt tự động mở tại đường dẫn: **`http://localhost:3000`**

---

## 5. Tài Liệu Thiết Kế Chi Tiết (Project Documentation)

- **Tóm tắt Quản lý Dự án:** [overview.md](file:///Users/macbook/Documents/hk6/mobile/project/overview.md)
- **Đặc tả Thiết kế SAD (System Architecture Document):** [system_design.md](file:///Users/macbook/Documents/hk6/mobile/project/system_design.md)
- **Thiết kế CSDL & Tập lệnh SQL:** [database_schema.md](file:///Users/macbook/Documents/hk6/mobile/project/database_schema.md)
- **Thiết kế Giao diện UI/UX:** [design.md](file:///Users/macbook/Documents/hk6/mobile/project/design.md)
