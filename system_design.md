# Tài liệu Phân tích và Thiết kế Kỹ thuật Hệ thống AssetTrack (Technical SAD)

Tài liệu này tập trung chuyên sâu vào các sơ đồ mô hình hóa phần mềm theo chuẩn **Systems Analysis and Design (SAD)** cho dự án AssetTrack, bao gồm đặc tả Yêu cầu, Use Case, Biểu đồ Hoạt động (Activity Diagrams), Biểu đồ Tuần tự (Sequence Diagrams), Biểu đồ Chuyển trạng thái (State Transition Diagrams), Biểu đồ Thực thể Lớp (UML Class Diagram) và Kiến trúc Hệ thống.

---

## 1. Yêu cầu Hệ thống (System Requirements)

### 1.1. Yêu cầu Chức năng (Functional Requirements - FR)
* **FR-1 (Quản lý Lý lịch Máy móc):** Hệ thống phải định danh từng máy bằng mã QR duy nhất và hiển thị lịch sử sửa chữa/bảo trì khi quét.
* **FR-2 (Báo cáo Sự cố khẩn cấp SOS):** Operator phải tạo được yêu cầu sửa chữa tức thời khi máy gặp sự cố (gồm mô tả, mức độ nghiêm trọng và ảnh chụp lỗi).
* **FR-3 (Thông báo thời gian thực):** Hệ thống phải tự động gửi thông báo đẩy đến kỹ sư ME khi có phiếu SOS phát sinh.
* **FR-4 (Thực thi PM Checklist):** Hệ thống phải tự động sinh nhiệm vụ bảo trì định kỳ dựa trên số giờ chạy máy và bắt buộc kỹ sư ME tích chọn checklist kèm ảnh minh chứng.
* **FR-5 (Nghiệm thu Chữ ký số):** Quản đốc phân xưởng phải ký tên điện tử trực tiếp trên app để nghiệm thu phiếu sửa chữa/bảo trì trước khi đưa máy hoạt động lại.
* **FR-6 (Giám sát & Thống kê):** Quản đốc phải xem được thời gian dừng máy (Downtime) và trạng thái phân xưởng thời gian thực thông qua dashboard.

### 1.2. Yêu cầu Phi Chức năng (Non-functional Requirements - NFR)
* **NFR-1 (Bảo mật & Phân quyền):** Ràng buộc truy cập dữ liệu bằng Row-Level Security (RLS) trên Supabase; mỗi role chỉ đọc/ghi trong phạm vi quyền hạn. Mỗi Supervisor chỉ thấy dữ liệu thuộc `workshop_id` mà họ phụ trách.
* **NFR-2 (Thời gian thực):** Thông báo đẩy về sự cố SOS phải được gửi đi trong vòng **< 3 giây** kể từ khi Operator gửi yêu cầu.
* **NFR-3 (Hiệu năng quét mã):** Camera nhận diện và decode mã QR trong **< 1.5 giây** trong điều kiện ánh sáng nhà máy bình thường.
* **NFR-4 (Dung lượng ảnh):** Mỗi ảnh đính kèm không vượt quá **5MB**; app tự nén trước khi upload.
* **NFR-5 (Tính khả dụng UI):** Giao diện tối ưu cho màn hình cảm ứng ≥ 5 inch; các nút hành động quan trọng có kích thước tối thiểu **48×48dp**.
* **NFR-6 (Offline & Tự đồng bộ):** Thao tác ghi khi mất mạng lưu vào SQLite local queue; khi có mạng app tự upload theo thứ tự. Ảnh offline lưu vào app storage dưới dạng file, SQLite chỉ lưu đường dẫn. App đọc lại queue khi khởi động. SOS tạo offline sẽ không gửi notification ngay — chỉ gửi sau khi đồng bộ xong.

---

## 2. Phân tích Use Case (Use Case Analysis)

### 2.1. Biểu đồ Use Case tổng thể (Use Case Diagram)

```mermaid
flowchart LR
    subgraph Actors["Tác nhân Nguồn"]
        Operator["Công nhân Vận hành"]
        ME["Kỹ sư Cơ điện (ME)"]
        Supervisor["Quản đốc Phân xưởng"]
    end

    subgraph System["Hệ thống AssetTrack"]
        UC_ScanQR["Quét QR & Xem lý lịch máy"]
        UC_LogHours["Cập nhật số giờ chạy"]
        UC_CreateSOS["Tạo phiếu SOS báo hỏng"]
        UC_ClaimSOS["Tiếp nhận phiếu sửa chữa SOS"]
        UC_ExecutePM["Thực hiện PM Checklist"]
        UC_LogParts["Khai báo vật tư thay thế"]
        UC_SubmitSpareParts["Gửi đề xuất linh kiện đắt tiền"]
        UC_ViewWorkOrderList["Xem danh sách Work Order"]
        UC_SignOff["Nghiệm thu & Ký tên điện tử"]
        UC_ApproveParts["Phê duyệt đề xuất linh kiện"]
        UC_ViewDashboard["Xem Dashboard Downtime"]
        UC_ConfigPM["Cài đặt mốc giờ & ngưỡng chi phí"]
    end

    Operator --> UC_ScanQR
    Operator --> UC_LogHours
    Operator --> UC_CreateSOS

    ME --> UC_ScanQR
    ME --> UC_ClaimSOS
    ME --> UC_ExecutePM
    ME --> UC_LogParts
    ME --> UC_SubmitSpareParts
    ME --> UC_ViewWorkOrderList

    Supervisor --> UC_SignOff
    Supervisor --> UC_ApproveParts
    Supervisor --> UC_ViewDashboard
    Supervisor --> UC_ConfigPM
```

### 2.2. Đặc tả Use Case tiêu biểu (Use Case Specification)

| Thành phần đặc tả | Mô tả chi tiết |
| :--- | :--- |
| **Tên Use Case** | Tạo phiếu SOS và Nghiệm thu sửa chữa (SOS Breakdown & Sign-off Flow) |
| **Tác nhân** | Operator (Người tạo), ME Engineer (Người sửa), Supervisor (Người nghiệm thu) |
| **Tiền điều kiện** | Máy móc đã được dán mã QR; Người dùng đã đăng nhập vào hệ thống với đúng vai trò. |
| **Luồng sự kiện chính** | 1. **Operator** quét mã QR trên máy, chọn "Báo lỗi khẩn cấp SOS".<br>2. **Operator** điền mô tả sự cố, chụp ảnh hiện trạng lỗi và bấm gửi.<br>3. Hệ thống lưu Work Order ở trạng thái `pending` và đổi trạng thái máy sang `repairing`.<br>4. Hệ thống kích hoạt Trigger gửi thông báo push notification đến các **ME Engineer**.<br>5. **ME Engineer** bấm tiếp nhận phiếu — DB thực hiện `UPDATE ... WHERE status='pending'`; nếu 2 ME bấm cùng lúc, chỉ 1 người thắng (race condition handled), người còn lại thấy thông báo "Phiếu đã được tiếp nhận" (trạng thái chuyển sang `in_progress`).<br>6. **ME Engineer** sửa máy xong, khai báo vật tư đã thay thế, chụp ảnh máy đã sửa, bấm hoàn thành (`completed`).<br>7. **Supervisor** kiểm tra máy, mở app và thực hiện ký tên điện tử lên màn hình cảm ứng để phê duyệt (`approved`).<br>8. Trạng thái máy tự động cập nhật về `active` (Hoạt động). |
| **Hậu điều kiện** | Phiếu sửa chữa được lưu trữ vĩnh viễn kèm ảnh chữ ký của Quản đốc; Máy móc trở lại sản xuất. |

---

## 3. Biểu đồ Hoạt động (Activity Diagrams)

### 3.1. Quy trình Xử lý Sự cố khẩn cấp (Breakdown SOS Workflow)
```mermaid
flowchart TD
    A([Bắt đầu]) --> B[Operator quét mã QR trên thân máy]
    B --> C[Hệ thống hiển thị Hộ chiếu thiết bị]
    C --> D["Operator chọn 'Báo lỗi SOS', điền mô tả & chụp hình lỗi"]
    D --> E{Có kết nối mạng?}
    E -- Có --> F["Hệ thống tạo phiếu SOS (Trạng thái: Pending)"]
    E -- Không --> E2["Lưu vào SQLite offline queue (hiển thị banner cảnh báo đỏ)"]
    E2 --> E3{Có mạng trở lại?}
    E3 -- Có --> F
    F --> G["Hệ thống chuyển trạng thái máy sang 'Repairing'"]
    G --> H[Hệ thống gửi Push Notification tới ME]
    H --> I{ME tiếp nhận phiếu}
    I -- Không ai nhận --> I
    I -- ME bấm Tiếp nhận --> J["ME tiến hành sửa chữa (Trạng thái: In Progress)"]
    J --> K[ME hoàn thành sửa chữa, cập nhật vật tư tiêu hao]
    K --> L["ME chụp ảnh bàn giao, chuyển trạng thái phiếu sang 'Completed'"]
    L --> M{Supervisor xét nghiệm thu}
    M -- Ký nghiệm thu --> N["Hệ thống lưu chữ ký, chuyển sang 'Approved'"]
    M -- Từ chối kèm lý do --> O["Phiếu về 'Rejected' → lưu rejection_reason"]
    O --> J
    N --> P["Hệ thống tự động chuyển trạng thái máy về 'Active'"]
    P --> Q([Kết thúc])
    D --> R{Báo nhầm / Hủy?}
    R -- Hủy phiếu khi còn Pending --> S["Trạng thái: Cancelled — Máy về Active"]
    S --> Q
```

### 3.2. Quy trình Bảo trì Định kỳ (Preventive Maintenance Workflow)
```mermaid
flowchart TD
    A([Bắt đầu]) --> B[Hệ thống theo dõi số giờ máy chạy]
    B --> C{Số giờ chạy >= Mốc cấu hình bảo trì?}
    C -- Có --> D["Hệ thống tự động tạo PM Checklist (Trạng thái: Pending)"]
    D --> E["Hệ thống chuyển trạng thái máy sang 'Maintenance'"]
    E --> F[Hệ thống đưa PM vào danh sách chờ — ME tự chọn tiếp nhận]
    F --> G[ME mở danh sách checklist cần làm]
    G --> H[ME thực hiện hạng mục bảo dưỡng]
    H --> I[ME tích chọn hoàn thành hạng mục]
    I --> J{Hoàn tất 100% Checklist?}
    J -- Chưa --> H
    J -- Rồi --> K[ME chụp ảnh linh kiện mới làm bằng chứng]
    K --> L["ME bấm 'Hoàn thành' (Trạng thái: Completed)"]
    L --> M[Quản đốc kiểm tra & ký tên nghiệm thu]
    M --> N["Hệ thống lưu chữ ký, cập nhật trạng thái phiếu sang 'Approved'"]
    N --> O["Hệ thống cập nhật thời điểm bảo trì gần nhất và chuyển máy về 'Active'"]
    O --> P([Kết thúc])
    C -- Không --> Q[Tiếp tục chạy máy & theo dõi số giờ]
    Q --> P
```

---

## 4. Biểu đồ Tuần tự (Sequence Diagrams)

### 4.1. Luồng Báo hỏng SOS và Đẩy Thông báo

```mermaid
sequenceDiagram
    autonumber
    actor OP as Operator
    participant App as Flutter Mobile App
    participant DB as Supabase DB
    participant Trigger as DB Trigger / Edge Function
    participant FCM as Firebase Push Server
    actor ME as ME Engineer

    OP->>App: Quét mã QR & Chọn Báo lỗi SOS
    OP->>App: Nhập mô tả, chọn độ nghiêm trọng & chụp ảnh lỗi
    App->>DB: INSERT INTO work_orders (status: 'pending', client_generated_id: uuid)
    Note over DB: Trigger đổi trạng thái máy sang 'repairing'
    DB-->>App: Xác nhận tạo thành công (201 Created)
    App-->>OP: Hiển thị "Đã gửi yêu cầu thành công"

    activate Trigger
    DB->>Trigger: Lắng nghe sự kiện INSERT
    Trigger->>FCM: Gửi Push Payload (Tiêu đề: Máy X gặp sự cố SOS!)
    deactivate Trigger
    FCM->>ME: Đẩy Notification thời gian thực tới điện thoại ME
    ME->>App: Nhấn Notification → Xem chi tiết sự cố
    App->>DB: UPDATE work_orders SET status='in_progress', assignee_id=me_id WHERE status='pending'
    Note over DB: Nếu 0 row affected → ME khác đã tiếp nhận trước (race condition handled)
```

### 4.2. Luồng Tiếp nhận & Sửa chữa SOS (ME Engineer)

```mermaid
sequenceDiagram
    autonumber
    actor ME as ME Engineer
    participant App as Flutter Mobile App
    participant DB as Supabase DB
    participant Store as Supabase Storage

    ME->>App: Xem danh sách Work Order & Chọn "Tiếp nhận"
    App->>DB: UPDATE work_orders SET status='in_progress' WHERE status='pending'
    DB-->>App: Cập nhật thành công — ghi nhận claimed_at
    ME->>App: Tiến hành sửa chữa & cập nhật vật tư tiêu hao
    ME->>App: Chụp ảnh máy đã sửa làm bằng chứng
    App->>Store: Upload ảnh bằng chứng
    Store-->>App: Trả về Image URL
    ME->>App: Chọn "Hoàn thành"
    App->>DB: UPDATE work_orders SET status='completed', downtime_end=now()
    DB-->>App: Ghi nhận dữ liệu thành công
    App-->>ME: Hiển thị "Đang đợi Quản đốc nghiệm thu"
```

### 4.3. Luồng Thực thi PM Checklist (ME Engineer)

```mermaid
sequenceDiagram
    autonumber
    actor ME as ME Engineer
    participant App as Flutter Mobile App
    participant DB as Supabase DB
    participant Store as Supabase Storage

    Note over DB: Hệ thống tự sinh PM khi running_hours >= scheduled_hours
    ME->>App: Xem danh sách Work Order & Chọn phiếu PM
    App->>DB: UPDATE pm_checklists SET status='in_progress'
    ME->>App: Tick từng hạng mục checklist
    ME->>App: Chụp ảnh linh kiện mới thay thế (bắt buộc với mục có photo_required)
    App->>Store: Upload ảnh linh kiện
    Store-->>App: Trả về Image URL
    App->>DB: UPDATE pm_checklist_items SET is_checked=true, photo_url=url
    ME->>App: Chọn "Hoàn thành" (chỉ active khi 100% checklist đã tích)
    App->>DB: UPDATE pm_checklists SET status='completed'
    DB-->>App: Ghi nhận dữ liệu thành công
    App-->>ME: Hiển thị "Đang đợi Quản đốc nghiệm thu"
```

### 4.4. Luồng Nghiệm thu và Ký tên điện tử (Digital Sign-off)

```mermaid
sequenceDiagram
    autonumber
    actor SV as Supervisor (Quản đốc)
    participant App as Flutter Mobile App
    participant Store as Supabase Storage
    participant DB as Supabase DB

    SV->>App: Mở danh sách chờ nghiệm thu → Chọn phiếu
    SV->>App: Xem tóm tắt: máy, kỹ sư, vật tư đã thay, tổng downtime
    SV->>App: Vẽ chữ ký tay trực tiếp lên màn hình cảm ứng
    alt Supervisor chấp nhận
        SV->>App: Xác nhận nghiệm thu
        App->>Store: Upload ảnh chữ ký (PNG ≥ 300×150px)
        Store-->>App: Trả về Signature Image URL
        App->>DB: UPDATE work_orders SET status='approved', signature_url=url
        Note over DB: Trigger tự động đổi trạng thái máy về 'active'
        DB-->>App: Cập nhật thành công
        App-->>SV: "Thiết bị đã hoạt động trở lại"
    else Supervisor từ chối
        SV->>App: Bấm "Từ chối" & nhập lý do
        App->>DB: UPDATE work_orders SET status='rejected', rejection_reason=reason, rejected_by=sv_id
        DB-->>App: Cập nhật thành công
        App-->>SV: "Đã gửi yêu cầu làm lại cho kỹ sư"
    end
```

---

## 5. Biểu đồ Chuyển trạng thái (State Transition Diagrams)

### 5.1. Trạng thái Thiết bị (Machine States)

```mermaid
stateDiagram-v2
    [*] --> Active : Nhập máy mới vào hệ thống
    Active --> Repairing : Operator báo lỗi khẩn cấp SOS
    Active --> Maintenance : Đến mốc số giờ chạy máy tự động sinh PM
    Repairing --> Active : Sửa xong & Supervisor ký nghiệm thu (Approved)
    Maintenance --> Active : Bảo trì xong & Supervisor ký nghiệm thu (Approved)
    Repairing --> Active : Phiếu SOS bị hủy (Cancelled)
    Active --> Inactive : Ngừng hoạt động (Thanh lý / Hỏng nặng)
    Repairing --> Inactive : Đánh giá không thể sửa chữa
    Inactive --> [*]
```

### 5.2. Trạng thái Phiếu công việc (Work Order / PM Checklist States)

```mermaid
stateDiagram-v2
    [*] --> Pending : Operator tạo phiếu SOS / Hệ thống tự sinh PM
    Pending --> In_Progress : ME bấm "Tiếp nhận" (optimistic lock)
    Pending --> Cancelled : Operator/Supervisor hủy khi chưa có ME nhận
    In_Progress --> Pending : ME trả lại phiếu (chưa có người khác nhận)
    In_Progress --> Completed : ME hoàn thành & chụp ảnh bằng chứng
    Completed --> Approved : Supervisor ký nghiệm thu
    Completed --> Rejected : Supervisor từ chối kèm lý do
    Rejected --> In_Progress : ME tiếp tục sửa lại
    Approved --> [*]
    Cancelled --> [*]
```

---

## 6. Sơ đồ Thực thể Lớp (UML Class Diagram)

```mermaid
classDiagram
    direction TB

    class UserRole {
        <<enumeration>>
        OPERATOR
        ME_ENGINEER
        SUPERVISOR
    }

    class MachineStatus {
        <<enumeration>>
        ACTIVE
        REPAIRING
        MAINTENANCE
        INACTIVE
    }

    class TaskStatus {
        <<enumeration>>
        PENDING
        IN_PROGRESS
        COMPLETED
        APPROVED
        REJECTED
        CANCELLED
    }

    class SeverityLevel {
        <<enumeration>>
        LOW
        MEDIUM
        HIGH
        CRITICAL
    }

    class UserProfile {
        +UUID id
        +String fullName
        +UserRole role
        +UUID workshopId
        +DateTime createdAt
        +login()
        +updateProfile()
    }

    class Machine {
        +UUID id
        +String code
        +String name
        +String model
        +Map specifications
        +MachineStatus status
        +double runningHours
        +UUID workshopId
        +DateTime lastMaintenance
        +DateTime createdAt
        +updateRunningHours()
        +changeStatus()
    }

    class WorkOrder {
        +UUID id
        +UUID clientGeneratedId
        +UUID workshopId
        +UUID machineId
        +UUID reporterId
        +UUID assigneeId
        +UUID supervisorId
        +SeverityLevel severity
        +String description
        +List imageUrls
        +TaskStatus status
        +DateTime downtimeStart
        +DateTime downtimeEnd
        +String supervisorSignatureUrl
        +String rejectionReason
        +UUID rejectedBy
        +DateTime cancelledAt
        +String cancellationReason
        +UUID cancelledBy
        +claim()
        +complete()
        +approve()
        +reject()
        +cancel()
    }

    class PmChecklist {
        +UUID id
        +UUID workshopId
        +UUID machineId
        +UUID assigneeId
        +UUID supervisorId
        +double scheduledHours
        +TaskStatus status
        +String supervisorSignatureUrl
        +String rejectionReason
        +UUID rejectedBy
        +DateTime completedAt
        +execute()
        +approve()
        +reject()
    }

    class PmChecklistItem {
        +UUID id
        +UUID pmChecklistId
        +String taskDescription
        +boolean isChecked
        +boolean photoRequired
        +String photoUrl
        +DateTime checkedAt
        +toggleCheck()
        +uploadProofPhoto()
    }

    class SparePartLog {
        +UUID id
        +UUID workOrderId
        +UUID pmChecklistId
        +String partName
        +int quantity
        +String unit
        +DateTime loggedAt
        +UUID loggedBy
    }

    class SparePartsRequest {
        +UUID id
        +UUID workOrderId
        +UUID pmChecklistId
        +UUID requestedBy
        +String partName
        +double unitPrice
        +String reason
        +String status
        +UUID approvedBy
        +String rejectionReason
        +DateTime createdAt
    }

    class WorkshopConfig {
        +UUID id
        +UUID workshopId
        +String machineModel
        +List pmThresholdHours
        +double costApprovalThreshold
        +DateTime updatedAt
        +UUID updatedBy
    }

    UserProfile "1" -- "0..*" WorkOrder : "báo lỗi / tiếp nhận / nghiệm thu"
    UserProfile "1" -- "0..*" PmChecklist : "thực hiện / nghiệm thu"
    Machine "1" -- "0..*" WorkOrder : "phát sinh sự cố"
    Machine "1" -- "0..*" PmChecklist : "bảo trì định kỳ"
    PmChecklist "1" *-- "1..*" PmChecklistItem : "bao gồm các hạng mục"
    WorkOrder "1" -- "0..*" SparePartLog : "ghi nhận vật tư"
    PmChecklist "1" -- "0..*" SparePartLog : "ghi nhận vật tư"
    WorkOrder "1" -- "0..*" SparePartsRequest : "đề xuất linh kiện"
    Machine "1" -- "1" WorkshopConfig : "cấu hình theo model"
```

---

## 7. Kiến trúc Hệ thống Tổng thể (System Architecture)

```mermaid
graph TD
    subgraph Client_App ["Ứng dụng Flutter (iOS/Android)"]
        UI[Giao diện UI/UX]
        Riverpod[State Management - Riverpod]
        Scanner[mobile_scanner SDK]
        SigCanvas[signature Canvas SDK]
        ClientSDK[Supabase Flutter Client SDK]
        SQLiteQ[SQLite - Offline Queue]
        LocalFS[Local File Storage - path_provider]
    end

    subgraph Supabase_BaaS ["Hệ thống Backend (Supabase)"]
        Auth[Xác thực người dùng - Auth]
        DB[(Cơ sở dữ liệu PostgreSQL)]
        RLS[Chính sách bảo mật RLS theo workshop_id]
        Storage[Supabase Storage - Ảnh & Chữ ký]
        Triggers[DB Triggers / Webhooks]
        EdgeFunc[Edge Functions]
    end

    subgraph External_Services ["Dịch vụ bên thứ ba"]
        FCM[Firebase Cloud Messaging - FCM]
    end

    UI --> Riverpod
    Riverpod --> Scanner
    Riverpod --> SigCanvas
    Riverpod --> ClientSDK
    Riverpod --> SQLiteQ
    SQLiteQ -->|Lưu ảnh path| LocalFS
    SQLiteQ -->|Sync khi có mạng| ClientSDK

    ClientSDK -->|HTTPS / WSS| Auth
    ClientSDK -->|SQL Query| RLS
    RLS --> DB
    ClientSDK -->|Upload/Download| Storage

    DB -->|Listen Event| Triggers
    Triggers -->|Invoke| EdgeFunc
    EdgeFunc -->|Send Payload| FCM
    FCM -->|Push Notification| Client_App
```

---

## 8. Thiết kế Cơ sở Dữ liệu Quan hệ (Relational Database Design)

### 8.1. Mô hình Thực thể Quan hệ (ERD)

```mermaid
erDiagram
    profiles {
        uuid id PK
        text full_name
        text role
        uuid workshop_id FK
        timestamptz created_at
    }

    workshops {
        uuid id PK
        text name
        text location
        timestamptz created_at
    }

    machines {
        uuid id PK
        text code UK
        text name
        text model
        jsonb specifications
        text status
        float8 running_hours
        uuid workshop_id FK
        timestamptz last_maintenance_at
        timestamptz created_at
    }

    workshop_configs {
        uuid id PK
        uuid workshop_id FK
        text machine_model
        int4[] pm_threshold_hours
        float8 cost_approval_threshold
        uuid updated_by FK
        timestamptz updated_at
    }

    work_orders {
        uuid id PK
        uuid client_generated_id UK
        uuid workshop_id FK
        uuid machine_id FK
        uuid reporter_id FK
        uuid assignee_id FK
        uuid supervisor_id FK
        text severity
        text description
        text status
        timestamptz downtime_start
        timestamptz downtime_end
        timestamptz claimed_at
        text supervisor_signature_url
        text rejection_reason
        uuid rejected_by FK
        timestamptz cancelled_at
        text cancellation_reason
        uuid cancelled_by FK
        timestamptz created_at
    }

    pm_checklists {
        uuid id PK
        uuid workshop_id FK
        uuid machine_id FK
        uuid assignee_id FK
        uuid supervisor_id FK
        float8 scheduled_hours
        text status
        text supervisor_signature_url
        text rejection_reason
        uuid rejected_by FK
        timestamptz completed_at
        timestamptz created_at
    }

    pm_checklist_items {
        uuid id PK
        uuid pm_checklist_id FK
        text task_description
        bool is_checked
        bool photo_required
        text photo_url
        timestamptz checked_at
    }

    spare_part_logs {
        uuid id PK
        uuid work_order_id FK
        uuid pm_checklist_id FK
        text part_name
        int4 quantity
        text unit
        uuid logged_by FK
        timestamptz logged_at
    }

    spare_parts_requests {
        uuid id PK
        uuid work_order_id FK
        uuid pm_checklist_id FK
        uuid requested_by FK
        text part_name
        float8 unit_price
        text reason
        text status
        uuid approved_by FK
        text rejection_reason
        timestamptz created_at
    }

    running_hours_log {
        uuid id PK
        uuid client_generated_id UK
        uuid machine_id FK
        float8 hours_value
        text shift
        uuid logged_by FK
        timestamptz logged_at
    }

    profiles ||--o{ work_orders : "báo lỗi / tiếp nhận / nghiệm thu"
    profiles ||--o{ pm_checklists : "thực hiện / nghiệm thu"
    profiles ||--o{ spare_part_logs : "ghi nhận vật tư"
    profiles ||--o{ spare_parts_requests : "đề xuất linh kiện"
    profiles ||--o{ running_hours_log : "nhập giờ chạy"
    profiles }o--|| workshops : "thuộc phân xưởng"
    workshops ||--o{ machines : "có máy móc"
    workshops ||--o{ workshop_configs : "cấu hình"
    workshops ||--o{ work_orders : "phụ trách"
    workshops ||--o{ pm_checklists : "phụ trách"
    machines ||--o{ work_orders : "phát sinh sự cố"
    machines ||--o{ pm_checklists : "bảo trì định kỳ"
    machines ||--o{ running_hours_log : "theo dõi giờ chạy"
    pm_checklists ||--|{ pm_checklist_items : "bao gồm hạng mục"
    work_orders ||--o{ spare_part_logs : "ghi nhận vật tư"
    pm_checklists ||--o{ spare_part_logs : "ghi nhận vật tư"
    work_orders ||--o{ spare_parts_requests : "đề xuất linh kiện"
    pm_checklists ||--o{ spare_parts_requests : "đề xuất linh kiện"
```

---

### 8.2. Mô tả Chi tiết Từng Bảng

#### Bảng `profiles` — Hồ sơ người dùng
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK, default `auth.uid()` | ID người dùng, liên kết với Supabase Auth |
| `full_name` | `text` | NOT NULL | Họ tên đầy đủ |
| `role` | `text` | NOT NULL, CHECK IN ('operator','me_engineer','supervisor') | Vai trò trong hệ thống |
| `workshop_id` | `uuid` | FK → workshops.id | Phân xưởng phụ trách |
| `created_at` | `timestamptz` | default now() | Thời điểm tạo |

---

#### Bảng `workshops` — Phân xưởng
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK, default gen_random_uuid() | ID phân xưởng |
| `name` | `text` | NOT NULL | Tên phân xưởng |
| `location` | `text` | | Vị trí / địa chỉ |
| `created_at` | `timestamptz` | default now() | Thời điểm tạo |

---

#### Bảng `machines` — Máy móc
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | ID máy |
| `code` | `text` | UNIQUE, NOT NULL | Mã máy in trên QR (e.g. MC-102) |
| `name` | `text` | NOT NULL | Tên máy |
| `model` | `text` | NOT NULL | Model máy (liên kết với workshop_configs.machine_model) |
| `specifications` | `jsonb` | | Thông số kỹ thuật (công suất, áp suất...) |
| `status` | `text` | NOT NULL, CHECK IN ('active','repairing','maintenance','inactive') | Trạng thái hiện tại |
| `running_hours` | `float8` | default 0 | Tổng số giờ chạy tích lũy |
| `workshop_id` | `uuid` | FK → workshops.id | Thuộc phân xưởng nào |
| `last_maintenance_at` | `timestamptz` | | Thời điểm bảo trì gần nhất |
| `created_at` | `timestamptz` | default now() | |

---

#### Bảng `workshop_configs` — Cấu hình ngưỡng phân xưởng
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | |
| `workshop_id` | `uuid` | FK → workshops.id | Phân xưởng áp dụng |
| `machine_model` | `text` | NOT NULL | Model máy (e.g. "Máy dập thủy lực") |
| `pm_threshold_hours` | `int4[]` | NOT NULL | Danh sách mốc giờ PM (e.g. {500,1000,2000}) |
| `cost_approval_threshold` | `float8` | default 2000000 | Ngưỡng giá trị linh kiện cần duyệt (VNĐ) |
| `updated_by` | `uuid` | FK → profiles.id | Supervisor cuối cùng chỉnh sửa |
| `updated_at` | `timestamptz` | default now() | |

---

#### Bảng `work_orders` — Phiếu sửa chữa SOS
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | |
| `client_generated_id` | `uuid` | UNIQUE, NOT NULL | UUID do app tạo offline, tránh tạo trùng khi retry |
| `workshop_id` | `uuid` | FK → workshops.id | Phân xưởng quản lý (phục vụ RLS trực tiếp theo NFR-01) |
| `machine_id` | `uuid` | FK → machines.id | Máy bị sự cố |
| `reporter_id` | `uuid` | FK → profiles.id | Operator tạo phiếu |
| `assignee_id` | `uuid` | FK → profiles.id, nullable | ME tiếp nhận |
| `supervisor_id` | `uuid` | FK → profiles.id, nullable | Supervisor nghiệm thu |
| `severity` | `text` | NOT NULL, CHECK IN ('low','medium','high','critical') | Mức độ nghiêm trọng |
| `description` | `text` | NOT NULL | Mô tả sự cố |
| `image_urls` | `text[]` | default '{}' | Mảng URL ảnh hiện trạng lỗi (tối đa 5 ảnh, enforce ở app layer) |
| `status` | `text` | NOT NULL, CHECK IN ('pending','in_progress','completed','approved','rejected','cancelled') | Trạng thái phiếu |
| `downtime_start` | `timestamptz` | | Thời điểm máy bắt đầu dừng |
| `downtime_end` | `timestamptz` | | Thời điểm máy chạy lại |
| `claimed_at` | `timestamptz` | | Thời điểm ME tiếp nhận (tính MTTR) |
| `supervisor_signature_url` | `text` | | URL ảnh chữ ký PNG |
| `rejection_reason` | `text` | | Lý do từ chối nghiệm thu |
| `rejected_by` | `uuid` | FK → profiles.id, nullable | Supervisor từ chối |
| `cancelled_at` | `timestamptz` | | Thời điểm hủy phiếu |
| `cancellation_reason` | `text` | | Lý do hủy |
| `cancelled_by` | `uuid` | FK → profiles.id, nullable | Người hủy phiếu (Operator / Supervisor) |
| `created_at` | `timestamptz` | default now() | |

---

#### Bảng `pm_checklists` — Phiếu bảo trì định kỳ
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | |
| `workshop_id` | `uuid` | FK → workshops.id | Phân xưởng quản lý (phục vụ RLS trực tiếp theo NFR-01) |
| `machine_id` | `uuid` | FK → machines.id | Máy cần bảo trì |
| `assignee_id` | `uuid` | FK → profiles.id, nullable | ME thực hiện |
| `supervisor_id` | `uuid` | FK → profiles.id, nullable | Supervisor nghiệm thu |
| `scheduled_hours` | `float8` | NOT NULL | Mốc giờ kích hoạt bảo trì (e.g. 500) |
| `status` | `text` | NOT NULL, CHECK IN ('pending','in_progress','completed','approved','rejected','cancelled') | |
| `supervisor_signature_url` | `text` | | URL chữ ký nghiệm thu |
| `rejection_reason` | `text` | | Lý do từ chối |
| `rejected_by` | `uuid` | FK → profiles.id, nullable | Supervisor từ chối |
| `completed_at` | `timestamptz` | | |
| `created_at` | `timestamptz` | default now() | |

---

#### Bảng `pm_checklist_items` — Hạng mục checklist bảo trì
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | |
| `pm_checklist_id` | `uuid` | FK → pm_checklists.id, ON DELETE CASCADE | Thuộc phiếu PM nào |
| `task_description` | `text` | NOT NULL | Mô tả hạng mục (e.g. "Thay dầu bôi trơn") |
| `is_checked` | `bool` | default false | Đã hoàn thành chưa |
| `photo_required` | `bool` | default false | Bắt buộc chụp ảnh minh chứng |
| `photo_url` | `text` | | URL ảnh linh kiện đã thay |
| `checked_at` | `timestamptz` | | Thời điểm tích hoàn thành |

---

#### Bảng `spare_part_logs` — Log vật tư đã sử dụng
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | |
| `work_order_id` | `uuid` | FK → work_orders.id, nullable | Thuộc phiếu SOS nào |
| `pm_checklist_id` | `uuid` | FK → pm_checklists.id, nullable | Thuộc phiếu PM nào |
| `part_name` | `text` | NOT NULL | Tên vật tư / linh kiện |
| `quantity` | `int4` | NOT NULL, CHECK > 0 | Số lượng |
| `unit` | `text` | NOT NULL | Đơn vị (cái, lít, kg...) |
| `logged_by` | `uuid` | FK → profiles.id | ME ghi nhận |
| `logged_at` | `timestamptz` | default now() | |

> **Ghi chú:** `work_order_id` và `pm_checklist_id` chỉ một trong hai được điền, cái còn lại là NULL. CHECK (`work_order_id` IS NOT NULL OR `pm_checklist_id` IS NOT NULL).

---

#### Bảng `spare_parts_requests` — Đề xuất linh kiện đắt tiền
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | |
| `work_order_id` | `uuid` | FK → work_orders.id, nullable | Thuộc phiếu SOS nào (nếu có) |
| `pm_checklist_id` | `uuid` | FK → pm_checklists.id, nullable | Thuộc phiếu PM nào (nếu có) |
| `requested_by` | `uuid` | FK → profiles.id | ME gửi đề xuất |
| `part_name` | `text` | NOT NULL | Tên linh kiện |
| `unit_price` | `float8` | NOT NULL, CHECK > 0 | Đơn giá (VNĐ) |
| `reason` | `text` | NOT NULL | Lý do cần thay thế |
| `status` | `text` | NOT NULL, CHECK IN ('pending_approval','approved','rejected') | |
| `approved_by` | `uuid` | FK → profiles.id, nullable | Supervisor phê duyệt |
| `rejection_reason` | `text` | | Lý do từ chối |
| `created_at` | `timestamptz` | default now() | |

> **Ghi chú:** `work_order_id` và `pm_checklist_id` chỉ một trong hai được điền. CHECK (`work_order_id` IS NOT NULL OR `pm_checklist_id` IS NOT NULL).

---

#### Bảng `running_hours_log` — Lịch sử nhập giờ chạy máy
| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | PK | |
| `client_generated_id` | `uuid` | UNIQUE, NOT NULL | UUID do app tạo offline (chống tạo trùng log khi retry sync) |
| `machine_id` | `uuid` | FK → machines.id | Máy được nhập giờ |
| `hours_value` | `float8` | NOT NULL, CHECK > 0 | Chỉ số giờ tại thời điểm nhập |
| `shift` | `text` | CHECK IN ('start','end') | Đầu ca hay cuối ca |
| `logged_by` | `uuid` | FK → profiles.id | Operator nhập |
| `logged_at` | `timestamptz` | default now() | |

> **Ghi chú:** Mỗi lần nhập, `hours_value` phải lớn hơn lần nhập gần nhất của cùng máy. Kiểm tra bằng DB Trigger hoặc RPC Function trước khi INSERT.

---

### 8.3. Tóm tắt Quan hệ Giữa Các Bảng

| Bảng con | Khóa ngoại | Bảng cha | Loại quan hệ |
| :--- | :--- | :--- | :--- |
| `profiles` | `workshop_id` | `workshops` | N-1 (nhiều người thuộc 1 phân xưởng) |
| `machines` | `workshop_id` | `workshops` | N-1 |
| `workshop_configs` | `workshop_id` | `workshops` | N-1 |
| `work_orders` | `workshop_id` | `workshops` | N-1 (hỗ trợ RLS theo NFR-01) |
| `work_orders` | `machine_id` | `machines` | N-1 |
| `work_orders` | `reporter_id`, `assignee_id`, `supervisor_id`, `rejected_by`, `cancelled_by` | `profiles` | N-1 |
| `pm_checklists` | `workshop_id` | `workshops` | N-1 (hỗ trợ RLS theo NFR-01) |
| `pm_checklists` | `machine_id` | `machines` | N-1 |
| `pm_checklists` | `assignee_id`, `supervisor_id`, `rejected_by` | `profiles` | N-1 |
| `pm_checklist_items` | `pm_checklist_id` | `pm_checklists` | N-1 (CASCADE DELETE) |
| `spare_part_logs` | `work_order_id` | `work_orders` | N-1 (nullable) |
| `spare_part_logs` | `pm_checklist_id` | `pm_checklists` | N-1 (nullable) |
| `spare_part_logs` | `logged_by` | `profiles` | N-1 |
| `spare_parts_requests` | `work_order_id` | `work_orders` | N-1 (nullable) |
| `spare_parts_requests` | `pm_checklist_id` | `pm_checklists` | N-1 (nullable) |
| `spare_parts_requests` | `requested_by`, `approved_by` | `profiles` | N-1 |
| `running_hours_log` | `machine_id` | `machines` | N-1 |
| `running_hours_log` | `logged_by` | `profiles` | N-1 |
