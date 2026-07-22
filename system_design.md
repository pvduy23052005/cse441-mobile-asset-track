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
* **NFR-1 (Bảo mật & Phân quyền):** Ràng buộc truy cập dữ liệu bằng Row-Level Security (RLS) trên Supabase; tài khoản phải được xác thực.
* **NFR-2 (Thời gian thực):** Thông báo đẩy về sự cố SOS phải được gửi đi trong vòng dưới 3 giây kể từ khi công nhân gửi yêu cầu.
* **NFR-3 (Tính khả dụng):** Giao diện quét mã QR và ký tên phải được tối ưu hóa cho màn hình cảm ứng di động (Mobile-friendly).

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
        UC_SignOff["Nghiệm thu & Ký tên điện tử"]
        UC_ApproveParts["Phê duyệt vật tư"]
        UC_ViewDashboard["Xem Dashboard Downtime"]
        UC_ConfigPM["Cài đặt mốc giờ bảo trì"]
    end

    Operator --> UC_ScanQR
    Operator --> UC_LogHours
    Operator --> UC_CreateSOS

    ME --> UC_ScanQR
    ME --> UC_ClaimSOS
    ME --> UC_ExecutePM
    ME --> UC_LogParts

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
| **Luồng sự kiện chính** | 1. **Operator** quét mã QR trên máy, chọn "Báo lỗi khẩn cấp SOS".<br>2. **Operator** điền mô tả sự cố, chụp ảnh hiện trạng lỗi và bấm gửi.<br>3. Hệ thống lưu Work Order ở trạng thái `pending` và đổi trạng thái máy sang `repairing`.<br>4. Hệ thống kích hoạt Trigger gửi thông báo push notification đến các **ME Engineer**.<br>5. **ME Engineer** bấm tiếp nhận phiếu (trạng thái chuyển sang `in_progress`).<br>6. **ME Engineer** sửa máy xong, khai báo vật tư đã thay thế, chụp ảnh máy đã sửa, bấm hoàn thành (`completed`).<br>7. **Supervisor** kiểm tra máy, mở app và thực hiện ký tên điện tử lên màn hình cảm ứng để phê duyệt (`approved`).<br>8. Trạng thái máy tự động cập nhật về `active` (Hoạt động). |
| **Hậu điều kiện** | Phiếu sửa chữa được lưu trữ vĩnh viễn kèm ảnh chữ ký của Quản đốc; Máy móc trở lại sản xuất. |

---

## 3. Biểu đồ Hoạt động (Activity Diagrams)

### 3.1. Quy trình Xử lý Sự cố khẩn cấp (Breakdown SOS Workflow)
```mermaid
flowchart TD
    A([Bắt đầu]) --> B[Operator quét mã QR trên thân máy]
    B --> C[Hệ thống hiển thị Hộ chiếu thiết bị]
    C --> D["Operator chọn 'Báo lỗi SOS', điền mô tả & chụp hình lỗi"]
    D --> E["Hệ thống tạo phiếu SOS (Trạng thái: Pending)"]
    E --> F["Hệ thống chuyển trạng thái máy sang 'Repairing'"]
    F --> G[Hệ thống gửi Push Notification tới ME]
    G --> H["ME Engineer nhận việc & tiến hành sửa chữa (Trạng thái: In Progress)"]
    H --> I[ME hoàn thành sửa chữa, cập nhật vật tư tiêu hao]
    I --> J["ME chụp ảnh bàn giao, chuyển trạng thái phiếu sang 'Completed'"]
    J --> K[Quản đốc Supervisor kiểm tra hiện trường]
    K --> L[Quản đốc ký tên điện tử nghiệm thu trên màn hình]
    L --> M["Hệ thống lưu chữ ký, chuyển trạng thái phiếu sang 'Approved'"]
    M --> N["Hệ thống tự động chuyển trạng thái máy về 'Active'"]
    N --> O([Kết thúc])
```

### 3.2. Quy trình Bảo trì Định kỳ (Preventive Maintenance Workflow)
```mermaid
flowchart TD
    A([Bắt đầu]) --> B[Hệ thống theo dõi số giờ máy chạy]
    B --> C{Số giờ chạy >= Mốc cấu hình bảo trì?}
    C -- Có --> D["Hệ thống tự động tạo PM Checklist (Trạng thái: Pending)"]
    D --> E["Hệ thống chuyển trạng thái máy sang 'Maintenance'"]
    E --> F[Hệ thống phân công task cho ME]
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
    App->>DB: INSERT INTO work_orders (status: 'pending')
    Note over DB: Thay đổi trạng thái máy sang 'repairing'
    DB-->>App: Xác nhận tạo thành công (201 Created)
    App-->>OP: Hiển thị "Đã gửi yêu cầu thành công"

    activate Trigger
    DB->>Trigger: Lắng nghe sự kiện INSERT
    Trigger->>FCM: Gửi Push Payload (Tiêu đề: Máy X gặp sự cố SOS!)
    deactivate Trigger
    FCM->>ME: Đẩy Notification thời gian thực tới điện thoại ME
    ME->>App: Nhấn Notification -> Xem chi tiết sự cố
```

### 4.2. Luồng Sửa chữa & Thực thi PM Checklist

```mermaid
sequenceDiagram
    autonumber
    actor ME as ME Engineer
    participant App as Flutter Mobile App
    participant DB as Supabase DB
    participant Store as Supabase Storage

    ME->>App: Xem danh sách công việc & Chọn "Tiếp nhận"
    App->>DB: UPDATE work_orders/pm_checklists (status: 'in_progress')
    ME->>App: Tiến hành bảo trì & tích chọn checklist
    ME->>App: Chụp ảnh linh kiện mới thay thế
    App->>Store: Upload ảnh linh kiện
    Store-->>App: Trả về Image URL
    ME->>App: Báo cáo vật tư tiêu hao & Chọn "Hoàn thành"
    App->>DB: UPDATE pm_checklist_items (is_checked: true, photo_url: url)
    App->>DB: UPDATE work_orders (status: 'completed', downtime_end: now())
    DB-->>App: Ghi nhận dữ liệu thành công
    App-->>ME: Hiển thị "Đang đợi Quản đốc nghiệm thu"
```

### 4.3. Luồng Nghiệm thu và Ký tên điện tử (Digital Sign-off)

```mermaid
sequenceDiagram
    autonumber
    actor SV as Supervisor (Quản đốc)
    participant App as Flutter Mobile App
    participant Store as Supabase Storage
    participant DB as Supabase DB

    SV->>App: Mở danh sách chờ nghiệm thu -> Chọn phiếu
    SV->>App: Vẽ chữ ký tay trực tiếp lên màn hình cảm ứng
    SV->>App: Xác nhận nghiệm thu
    App->>Store: Upload ảnh chữ ký (Format PNG)
    Store-->>App: Trả về Signature Image URL
    App->>DB: UPDATE work_orders SET status = 'approved', signature_url = url
    Note over DB: SQL Trigger tự động đổi trạng thái máy về 'active' (Hoạt động)
    DB-->>App: Cập nhật cơ sở dữ liệu thành công
    App-->>SV: Báo cáo: "Thiết bị đã hoạt động trở lại"
```

---

## 5. Biểu đồ Chuyển trạng thái (State Transition Diagrams)

### 5.1. Trạng thái Thiết bị (Machine States)

```mermaid
stateDiagram-v2
    [*] --> Active : Nhập máy mới vào hệ thống
    Active --> Repairing : Operator báo lỗi khẩn cấp SOS
    Active --> Maintenance : Đến mốc số giờ chạy máy tự động sinh PM
    Repairing --> Active : Sửa xong & Quản đốc ký nghiệm thu
    Maintenance --> Active : Bảo trì xong & Quản đốc ký nghiệm thu
    Active --> Inactive : Ngừng hoạt động (Thanh lý/Hỏng nặng)
    Repairing --> Inactive : Đánh giá không thể sửa chữa
    Inactive --> [*]
```

### 5.2. Trạng thái Phiếu công việc (Work Order / PM Checklist States)

```mermaid
stateDiagram-v2
    [*] --> Pending : Operator tạo phiếu SOS / Hệ thống tự sinh PM
    Pending --> Assigned : Đã phân công cho ME cụ thể
    Assigned --> In_Progress : ME bấm "Tiếp nhận" công việc
    In_Progress --> Completed : ME hoàn thành sửa/bảo trì & chụp ảnh linh kiện
    Completed --> Approved : Quản đốc ký tên điện tử nghiệm thu
    Approved --> [*]
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
        ASSIGNED
        IN_PROGRESS
        COMPLETED
        APPROVED
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
        +DateTime createdAt
        +login()
        +updateProfile()
    }

    class Machine {
        +UUID id
        +String code
        +String name
        +Map specifications
        +MachineStatus status
        +double runningHours
        +DateTime lastMaintenance
        +DateTime createdAt
        +updateRunningHours()
        +changeStatus()
    }

    class WorkOrder {
        +UUID id
        +UUID machineId
        +UUID reporterId
        +UUID assigneeId
        +UUID supervisorId
        +SeverityLevel severity
        +String description
        +String imageUrl
        +TaskStatus status
        +DateTime downtimeStart
        +DateTime downtimeEnd
        +String supervisorSignatureUrl
        +claim()
        +complete()
        +approve()
    }

    class PmChecklist {
        +UUID id
        +UUID machineId
        +UUID assigneeId
        +UUID supervisorId
        +double scheduledHours
        +TaskStatus status
        +String supervisorSignatureUrl
        +DateTime completedAt
        +execute()
        +approve()
    }

    class PmChecklistItem {
        +UUID id
        +UUID pmChecklistId
        +String taskDescription
        +boolean isChecked
        +String photoUrl
        +DateTime checkedAt
        +toggleCheck()
        +uploadProofPhoto()
    }

    UserProfile "1" -- "0..*" WorkOrder : "báo lỗi / tiếp nhận / nghiệm thu"
    UserProfile "1" -- "0..*" PmChecklist : "thực hiện / nghiệm thu"
    Machine "1" -- "0..*" WorkOrder : "phát sinh sự cố"
    Machine "1" -- "0..*" PmChecklist : "bảo trì định kỳ"
    PmChecklist "1" *-- "1..*" PmChecklistItem : "bao gồm các hạng mục"
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
    end

    subgraph Supabase_BaaS ["Hệ thống Backend (Supabase)"]
        Auth[Xác thực người dùng - Auth]
        DB[(Cơ sở dữ liệu PostgreSQL)]
        RLS[Chính sách bảo mật RLS]
        Storage[Supabase Storage - Lưu trữ ảnh & Chữ ký]
        Triggers[DB Triggers / Webhooks]
        EdgeFunc[Edge Functions - Dịch vụ trung gian]
    end

    subgraph External_Services ["Dịch vụ bên thứ ba"]
        FCM[Firebase Cloud Messaging - FCM]
    end

    UI --> Riverpod
    Riverpod --> Scanner
    Riverpod --> SigCanvas
    Riverpod --> ClientSDK

    ClientSDK -->|HTTPS / WSS| Auth
    ClientSDK -->|SQL Query| RLS
    RLS --> DB
    ClientSDK -->|Upload/Download| Storage

    DB -->|Listen Event| Triggers
    Triggers -->|Invoke| EdgeFunc
    EdgeFunc -->|Send Payload| FCM
    FCM -->|Push Notification| Client_App
```
