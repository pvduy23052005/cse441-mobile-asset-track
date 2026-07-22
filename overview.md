# AssetTrack - Báo cáo Tổng quan Dự án & Quản lý Phát triển

Hệ thống Quản lý Lý lịch Thiết bị & Bảo trì Phòng ngừa Nhà máy dựa trên nền tảng **Flutter & Supabase**.

---

## 1. Giới thiệu Dự án & Vấn đề Thực tế (Problem Statement & Scope)

### 1.1. Bất cập thực tế
Trong các dây chuyền sản xuất công nghiệp, máy móc hỏng hóc đột xuất gây ra sự ngưng trệ dây chuyền, dẫn đến thiệt hại kinh tế rất lớn. Nguyên nhân chủ yếu do:
- Công nhân vận hành quên thực hiện bảo dưỡng định kỳ (thay dầu, tra mỡ, kiểm tra áp suất...) theo số giờ chạy thực tế.
- Quy trình báo lỗi thủ công bằng giấy tờ hoặc tin nhắn chat chậm trễ, thông tin sai lệch, không lưu lại được lý lịch máy móc để phân tích.
- Việc nghiệm thu sau sửa chữa thiếu tính xác thực và cam kết trách nhiệm.

### 1.2. Phân hệ người dùng (User Personas)
- **Operator (Công nhân vận hành máy):** Tiếp cận máy hàng ngày, quét QR tra cứu thông số, nhập số giờ chạy và báo sự cố SOS khẩn cấp.
- **ME Engineer (Kỹ sư Cơ điện):** Nhận thông báo sự cố, tiếp nhận sửa chữa đột xuất và thực hiện checklist bảo dưỡng định kỳ (PM Checklist).
- **Supervisor (Quản đốc phân xưởng):** Giám sát thời gian dừng máy (Downtime), phê duyệt vật tư và nghiệm thu công việc bằng chữ ký điện tử trực tiếp trên màn hình.

---

## 2. Danh sách 12 Tính năng Cốt lõi (12 Core Features)

### Tác nhân 1: Công nhân vận hành (Operator)
1. **Quét mã QR - Hộ chiếu Thiết bị (QR Machine Passport):** Xem nhanh thông số kỹ thuật, lịch sử sửa chữa và cẩm nang khắc phục lỗi nhanh.
2. **Khai báo số giờ chạy máy (Running Hours Logging):** Nhập chỉ số giờ chạy thực tế đầu/cuối ca để làm căn cứ tính thời gian bảo trì.
3. **Báo lỗi khẩn cấp SOS (Breakdown SOS Creation):** Tạo phiếu yêu cầu sửa chữa khẩn cấp, chọn mức độ nghiêm trọng và mô tả lỗi.
4. **Đính kèm hình ảnh sự cố (Failure Photo Attachment):** Chụp ảnh/quay video hiện trạng lỗi trực tiếp từ camera gửi lên hệ thống.

### Tác nhân 2: Kỹ sư Cơ điện Bảo trì (ME Engineer)
5. **Tiếp nhận phiếu sửa chữa SOS (SOS Work Order Claiming):** Nhận thông báo đẩy (Push Notification) thời gian thực và bấm "Tiếp nhận" xử lý.
6. **Khai báo linh kiện & Vật tư thay thế (Spare Parts Logging):** Ghi nhận các phụ tùng tiêu hao đã sử dụng để cập nhật lịch sử máy và kiểm kho.
7. **Thực hiện Checklist bảo trì định kỳ (PM Checklist Execution):** Mở danh sách checklist bắt buộc (tra dầu, siết ốc...) và tích chọn hoàn thành từng mục.
8. **Tải ảnh bằng chứng bảo dưỡng (Maintenance Proof Upload):** Chụp ảnh linh kiện cũ/mới trước và sau khi thay thế làm bằng chứng hoàn thành.

### Tác nhân 3: Quản đốc phân xưởng (Factory Supervisor)
9. **Nghiệm thu & Ký tên điện tử (Digital Sign-off):** Ký tên trực tiếp bằng tay trên màn hình cảm ứng để phê duyệt và đưa máy về trạng thái "Hoạt động".
10. **Phê duyệt đề xuất linh kiện đắt tiền (Spare Parts Approval):** Xem xét và phê duyệt/từ chối các đề xuất thay thế phụ tùng giá trị cao từ ME.
11. **Dashboard giám sát Downtime & Trạng thái phân xưởng (Real-time Dashboard):** Xem biểu đồ tỷ lệ máy chạy/hỏng và tổng giờ dừng máy (Downtime).
12. **Thiết lập mốc bảo dưỡng định kỳ (PM Threshold Settings):** Cài đặt mốc số giờ chạy máy (e.g. 500h, 1000h) để tự động sinh phiếu bảo trì.

---

## 3. Danh sách User Stories & Tiêu chí Nghiệm thu (User Stories)

| Mã US | Vai trò (As a) | Mong muốn (I want to) | Lợi ích (So that) | Tiêu chí nghiệm thu (Acceptance Criteria) |
| :--- | :--- | :--- | :--- | :--- |
| **US-01** | Operator | Quét mã QR dán trên thân máy | Xem nhanh "Hộ chiếu thiết bị" (thông số, lịch sử, cẩm nang lỗi). | • Camera quét QR trong < 1.5s.<br>• Hiển thị đúng thông tin máy. |
| **US-02** | Operator | Khai báo số giờ chạy máy đầu/cuối ca | Cung cấp dữ liệu cho hệ thống tính mốc bảo dưỡng. | • Form nhập chỉ nhận số dương lớn hơn chỉ số trước.<br>• Lưu log thời gian nhập. |
| **US-03** | Operator | Tạo phiếu SOS khẩn cấp kèm ảnh lỗi | Báo cáo sự cố dừng chuyền cho kỹ sư ME tức thời. | • Cho phép chụp hình bằng camera đính kèm vào phiếu.<br>• Trạng thái máy đổi sang "Repairing". |
| **US-04** | ME Engineer | Nhận notification sự cố & bấm tiếp nhận | Xác nhận bắt đầu sửa chữa máy hỏng. | • Nhấp notification mở trực tiếp phiếu SOS.<br>• Ghi nhận thời điểm tiếp nhận để tính MTTR. |
| **US-05** | ME Engineer | Thực hiện PM Checklist & tải ảnh linh kiện | Hoàn tất bảo dưỡng định kỳ đúng quy trình. | • Phải tích 100% checklist mới bấm "Hoàn thành".<br>• Tải ít nhất 1 ảnh linh kiện thay thế. |
| **US-06** | ME Engineer | Khai báo vật tư tiêu hao đã thay | Ghi nhận lịch sử phụ tùng phục vụ kiểm kho. | • Cho phép chọn vật tư từ danh mục và nhập số lượng. |
| **US-07** | Supervisor | Ký tên điện tử nghiệm thu trên màn hình | Xác nhận máy đã được sửa/bảo trì đạt chuẩn. | • Chữ ký hiển thị sắc nét, xuất ra ảnh PNG/SVG.<br>• Máy tự động về trạng thái "Active". |
| **US-08** | Supervisor | Phê duyệt yêu cầu thay linh kiện đắt tiền | Kiểm soát chi phí sửa chữa phân xưởng. | • Hiển thị cảnh báo màu đỏ nếu vượt hạn mức.<br>• Lưu rõ tên Supervisor đã duyệt. |
| **US-09** | Supervisor | Xem Dashboard thống kê Downtime | Giám sát hiệu suất và thời gian dừng máy. | • Biểu đồ trực quan tỷ lệ máy chạy/hỏng.<br>• Thống kê tổng giờ Downtime tích lũy. |
| **US-10** | Supervisor | Cấu hình mốc giờ bảo dưỡng định kỳ | Tự động hóa việc tạo PM Checklist. | • Đổi mốc giờ (500h, 800h...) cho từng model máy. |

---

## 4. Thiết kế Giao diện Mobile (UI/UX Wireframes)

### A. Giao diện Machine Passport & SOS (Màn hình Operator)
- **Header:** Tên thiết bị + Mã máy (e.g. *Máy dập thủy lực MC-102*).
- **Trạng thái:** Tag màu hiển thị (`Hoạt động` - Xanh, `Sự cố` - Đỏ, `Bảo trì` - Vàng).
- **Body:** Danh sách thông số kỹ thuật & Lịch sử sửa chữa gần nhất.
- **Footer:** 2 Nút hành động: `Cập nhật giờ máy chạy` và `BÁO LỖI SOS KHẨN CẤP` (Nút màu đỏ nổi bật).

### B. Giao diện thực hiện PM Checklist (Màn hình ME Engineer)
- **Header:** Tên công việc + Số giờ mốc (e.g. *Bảo trì định kỳ mốc 500h*).
- **Checklist:** Danh sách checkbox lớn, dễ thao tác trong môi trường nhà máy:
  - [ ] Thay dầu bôi trơn trục chính (Bắt buộc chụp ảnh).
  - [ ] Kiểm tra áp suất khí nén.
  - [ ] Siết chặt bu-lông chân máy.
- **Upload bằng chứng:** Khung nét đứt `[ + Thêm ảnh linh kiện thay thế ]`.
- **Footer:** Nút `Hoàn thành & Gửi nghiệm thu` (Chỉ sáng khi tích đủ 100% checklist).

### C. Giao diện Nghiệm thu & Ký tên (Màn hình Supervisor)
- **Tóm tắt:** Thông tin máy, kỹ sư xử lý, danh sách vật tư đã thay, thời gian dừng máy (Downtime).
- **Canvas chữ ký:** Khung trắng lớn *"Vui lòng ký tên của bạn vào đây để nghiệm thu bàn giao máy"*.
- **Footer:** Nút `Xóa chữ ký` và `Xác nhận & Chạy máy` (Màu xanh lá).

---

## 5. Phân công Công việc Full-stack & Lộ trình Phát triển (Roadmap 5 Tuần)

### 5.1. Phân công công việc (Task Assignment - Full-stack Cộng tác)
Cả **2 thành viên** đều là Full-stack Developers, hợp tác phát triển theo từng Module tính năng:

| Module / Tính năng | Thành viên Chủ trì | Thành viên Phối hợp | Công việc chi tiết |
| :--- | :--- | :--- | :--- |
| **Module 1: Auth, Máy móc & QR Passport** | **Thành viên 1** | **Thành viên 2** | • *Thành viên 1:* Cấu trúc Flutter project, UI Machine Passport, tích hợp `mobile_scanner`.<br>• *Thành viên 2:* Tạo Supabase DB, bảng `machines`, `profiles` và cài đặt Auth RLS. |
| **Module 2: SOS Breakdown & Push Notification** | **Thành viên 2** | **Thành viên 1** | • *Thành viên 2:* Tạo bảng `work_orders`, DB Trigger & Edge Function gọi Firebase FCM.<br>• *Thành viên 1:* UI Form SOS, đính kèm ảnh lỗi và lắng nghe FCM notification. |
| **Module 3: PM Checklist & Bằng chứng bảo trì** | **Thành viên 1** | **Thành viên 2** | • *Thành viên 1:* UI checklist tương tác, tích hợp `image_picker` chụp ảnh linh kiện.<br>• *Thành viên 2:* Bảng `pm_checklists`, `pm_checklist_items`, Supabase Storage Bucket `work-order-images`. |
| **Module 4: Ký nghiệm thu & Dashboard Downtime** | **Thành viên 2** | **Thành viên 1** | • *Thành viên 2:* Màn hình ký tên nghiệm thu (`signature` canvas), Bucket `signatures`.<br>• *Thành viên 1:* UI Dashboard biểu đồ Downtime (`fl_chart`), kết nối SQL Aggregates. |

---

### 5.2. Lịch trình phát triển (Roadmap 5 Tuần)

- **Tuần 1: Khởi động hệ thống & Nền tảng**
  - *Cả 2 thành viên:* Thống nhất API Contract & cấu hình Supabase.
  - *Thành viên 1:* Khởi tạo Flutter Project, Riverpod, Theme nhà máy.
  - *Thành viên 2:* Tạo Supabase Project, chạy mã DDL, cấu hình RLS Policies & Triggers.
- **Tuần 2: Hoàn thiện Module 1 (QR Code & Machine Passport)**
  - *Thành viên 1:* UI camera quét QR, Hộ chiếu thiết bị & Popup nhập giờ chạy.
  - *Thành viên 2:* Nhập dữ liệu máy mẫu, tạo RPC Function xử lý mã QR.
- **Tuần 3: Hoàn thiện Module 2 (Breakdown SOS & Push Notification)**
  - *Thành viên 1:* Form báo lỗi SOS, chụp ảnh đính kèm lỗi, màn hình danh sách sự cố.
  - *Thành viên 2:* DB Trigger đổi trạng thái máy sang `repairing`, Edge Function gửi push noti FCM.
- **Tuần 4: Hoàn thiện Module 3 (PM Checklist & Chữ ký nghiệm thu)**
  - *Thành viên 1:* UI Checklist bảo dưỡng bắt buộc, upload ảnh linh kiện làm bằng chứng.
  - *Thành viên 2:* Canvas ký tên nghiệm thu, lưu file chữ ký vào Supabase Storage, đổi trạng thái máy về `active`.
- **Tuần 5: Dashboard Downtime, Tích hợp & Testing**
  - *Thành viên 1:* Dashboard biểu đồ thống kê Downtime.
  - *Thành viên 2:* Viết câu lệnh SQL truy vấn tổng hợp dữ liệu Downtime.
  - *Cả 2 thành viên:* Test toàn bộ luồng với mã QR in giấy, sửa lỗi và đóng gói ứng dụng (APK/IPA).

---

## 6. Các Tài liệu Phân tích & Thiết kế Chi tiết (Detailed Documentation Links)

Để xem chi tiết mô hình hóa kỹ thuật UML và kịch bản cơ sở dữ liệu, vui lòng tham khảo các tài liệu chuyên sâu sau:

1. 📘 **Phân tích & Thiết kế Kỹ thuật Hệ thống (Technical SAD):** [system_design.md](file:///Users/macbook/Documents/hk6/mobile/project/system_design.md)
   - *Bao gồm:* Yêu cầu kỹ thuật FR/NFR, Biểu đồ Use Case & Đặc tả, Biểu đồ Hoạt động (Activity Diagrams), Biểu đồ Tuần tự (Sequence Diagrams), Biểu đồ Chuyển trạng thái (State Transition Diagrams), Biểu đồ Thực thể Lớp (UML Class Diagram), và Kiến trúc Hệ thống.
2. 🗄️ **Thiết kế Cơ sở Dữ liệu & Tập lệnh SQL (Database Schema):** [database_schema.md](file:///Users/macbook/Documents/hk6/mobile/project/database_schema.md)
   - *Bao gồm:* Sơ đồ ERD, Tập lệnh SQL DDL (Tạo Bảng, Enum, Trigger tự động đồng bộ Profile), Chính sách Bảo mật cấp dòng (RLS Policies), và Cấu hình Supabase Storage Buckets.
