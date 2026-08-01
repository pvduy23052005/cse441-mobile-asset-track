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
- **ME Engineer (Kỹ sư Cơ điện):** Nhận thông báo sự cố, tiếp nhận sửa chữa đột xuất, thực hiện checklist bảo dưỡng định kỳ và gửi đề xuất vật tư thay thế.
- **Supervisor (Quản đốc phân xưởng):** Giám sát thời gian dừng máy (Downtime), phê duyệt vật tư đắt tiền, nghiệm thu công việc bằng chữ ký điện tử và cài đặt ngưỡng mốc bảo trì/chi phí phân xưởng.

### 1.3. Bối cảnh vận hành thực tế — Phạm vi 1 Phân xưởng Sản xuất (Single Workshop Scope)
- **Đặc điểm phạm vi:** Đề tài tập trung tối ưu cho **1 Phân Xưởng Sản Xuất quy mô vừa & nhỏ (SME)** với số lượng máy móc < 50 máy, đội ngũ kỹ sư bảo trì từ 3 – 7 người, không có thủ kho riêng trực ca 24/7.
- **Quy trình lấy vật tư:** Vật tư tiêu hao cơ bản (dầu mỡ, bu-lông, gioăng, đai curoa...) được để sẵn ở *Tủ vật tư nhanh* tại phân xưởng. Kỹ sư ME là người **TỰ LẤY**: Khi máy hỏng, ME ra tủ lấy linh kiện và tự thay vào máy.
- **Cách AssetTrack hỗ trợ:** ME mở app, chọn các món đồ vừa lấy để **Ghi log (Spare Parts Logging - Tính năng 6)**. Việc ghi log này giúp hệ thống lưu lại lý lịch sửa chữa của máy và trừ lùi số lượng để Quản đốc biết khi nào tủ vật tư sắp hết.

---

## 2. Danh sách 13 Tính năng Cốt lõi (13 Core Features)

### Tác nhân 1: Công nhân vận hành (Operator)
1. **Quét mã QR - Hộ chiếu Thiết bị (QR Machine Passport):** Xem nhanh thông số kỹ thuật, lịch sử sửa chữa và cẩm nang khắc phục lỗi nhanh.
2. **Khai báo chỉ số máy chạy (Running Hours / Mileage Logging):** Nhập chỉ số hoạt động thực tế (giờ hoặc km) đầu/cuối ca để làm căn cứ tính thời gian bảo trì.
3. **Báo lỗi khẩn cấp SOS (Breakdown SOS Creation):** Tạo phiếu yêu cầu sửa chữa khẩn cấp, chọn mức độ nghiêm trọng và mô tả lỗi.
4. **Đính kèm hình ảnh sự cố (Failure Photo Attachment):** Chụp ảnh hiện trạng lỗi trực tiếp từ camera gửi lên hệ thống.

### Tác nhân 2: Kỹ sư Cơ điện Bảo trì (ME Engineer)
5. **Tiếp nhận phiếu sửa chữa SOS (SOS Work Order Claiming):** Nhận thông báo đẩy (Push Notification) thời gian thực và bấm "Tiếp nhận" xử lý.
6. **Khai báo linh kiện & Vật tư thay thế (Spare Parts Logging):** Ghi nhận các phụ tùng tiêu hao đã tự lấy từ *Tủ vật tư nhanh* tại phân xưởng để cập nhật lịch sử sửa chữa của máy và giúp Quản đốc theo dõi trừ lùi số lượng tồn tủ. **Lưu ý phạm vi (Scope note):** tính năng này chỉ ghi log vật tư đã dùng vào lịch sử phiếu công việc — không bao gồm quản lý kho tổng phức tạp.
7. **Thực hiện Checklist bảo trì định kỳ (PM Checklist Execution):** Mở danh sách checklist bắt buộc (tra dầu, siết ốc...) và tích chọn hoàn thành từng mục.
8. **Tải ảnh bằng chứng bảo dưỡng (Maintenance Proof Upload):** Chụp ảnh linh kiện cũ/mới trước và sau khi thay thế làm bằng chứng hoàn thành.
9. **Xem danh sách toàn bộ phiếu công việc đang mở (Work Order List View):** Quản lý và ưu tiên xử lý các sự cố theo mức độ nghiêm trọng.

### Tác nhân 3: Quản đốc phân xưởng (Factory Supervisor)
10. **Nghiệm thu & Ký tên điện tử (Digital Sign-off):** Ký tên trực tiếp bằng tay trên màn hình cảm ứng để phê duyệt và đưa máy về trạng thái "Hoạt động".
11. **Phê duyệt đề xuất linh kiện đắt tiền (Spare Parts Approval):** Xem xét và phê duyệt/từ chối các đề xuất thay thế phụ tùng giá trị cao từ ME.
12. **Dashboard giám sát Downtime & Trạng thái phân xưởng (Real-time Dashboard):** Xem biểu đồ tỷ lệ máy chạy/hỏng, tổng giờ dừng máy (Downtime) và danh sách sự cố đang mở.
13. **Thiết lập ngưỡng hệ thống (System Threshold Settings):** Cài đặt mốc số giờ/km bảo trì định kỳ **và** cấu hình ngưỡng giá trị linh kiện (Cost Threshold) yêu cầu phê duyệt Supervisor trước khi thay thế.

---

## 3. Yêu cầu Phi Chức năng (Non-Functional Requirements - NFR)

| Mã NFR | Thuộc tính | Yêu cầu |
| :--- | :--- | :--- |
| **NFR-01** | Bảo mật & Phân quyền | Toàn bộ dữ liệu được bảo vệ bằng Row-Level Security (RLS) trên Supabase; phân quyền theo 3 vai trò (`Operator`, `ME Engineer`, `Supervisor`) trong phân xưởng. Người dùng chỉ thực hiện các thao tác trong phạm vi quyền hạn của vai trò mình phụ trách. |
| **NFR-02** | Hiệu năng thông báo | Push notification SOS phải được gửi đến ME trong vòng **< 3 giây** kể từ khi Operator bấm gửi phiếu. |
| **NFR-03** | Hiệu năng quét mã | Camera nhận diện và decode mã QR trong **< 1.5 giây** trong điều kiện ánh sáng nhà máy bình thường. |
| **NFR-04** | Dung lượng ảnh | Mỗi ảnh đính kèm (sự cố, linh kiện, chữ ký) không vượt quá **5MB**; app tự nén trước khi upload. |
| **NFR-05** | Tính khả dụng UI | Giao diện tối ưu cho màn hình cảm ứng ≥ 5 inch; các nút hành động quan trọng có kích thước tối thiểu **48×48dp** để dễ thao tác khi đeo găng tay. |
| **NFR-06** | Offline & Tự đồng bộ | App lưu dữ liệu Machine Passport vào local cache để xem khi mất mạng. Các thao tác ghi (nhập giờ chạy, tạo phiếu SOS) khi mất mạng được lưu vào **local queue** (SQLite); khi có mạng trở lại app **tự động upload** theo thứ tự và xóa khỏi queue. App hiển thị banner "Đang offline — dữ liệu sẽ được đồng bộ khi có mạng".<br><br>**① Xử lý ảnh offline:** Ảnh đính kèm khi tạo phiếu SOS offline được lưu vào app storage dưới dạng file (`path_provider`); SQLite queue chỉ lưu đường dẫn local. Khi có mạng, app upload ảnh lên Supabase Storage trước, nhận URL, sau đó mới tạo Work Order kèm URL đó. Nếu upload ảnh thất bại giữa chừng, toàn bộ phiếu giữ lại trong queue và retry lần sau.<br><br>**② Resume queue khi khởi động lại app:** SQLite là persistent storage (không mất khi tắt app/mất pin). App **đọc lại queue ngay khi khởi động** — không chỉ lắng nghe event "có mạng trở lại" — để tiếp tục đồng bộ các phiếu chưa hoàn thành. Idempotency đảm bảo bằng cột `client_generated_id` (UUID do app tạo) có `UNIQUE constraint` tại Supabase, tránh tạo phiếu trùng khi retry.<br><br>**③ Cảnh báo SOS offline:** Push notification tới ME **chỉ gửi được sau khi phiếu đã đồng bộ lên Supabase** — tức là nếu Operator tạo SOS lúc mất mạng, ME sẽ không nhận được notification ngay (không đạt NFR-02 trong trường hợp này). App hiển thị **banner cảnh báo đỏ** khi tạo SOS offline: *"⚠️ Không có mạng — Phiếu SOS sẽ chỉ được gửi tới kỹ sư sau khi kết nối trở lại. Hãy thông báo trực tiếp nếu sự cố nghiêm trọng."*<br><br>**Xử lý conflict:** last-write-wins — bản có timestamp muộn hơn thắng. |

---

## 4. Danh sách User Stories & Tiêu chí Nghiệm thu (User Stories)

| Mã US | Vai trò (As a) | Mong muốn (I want to) | Lợi ích (So that) | Tiêu chí nghiệm thu (Acceptance Criteria) |
| :--- | :--- | :--- | :--- | :--- |
| **US-01** | Operator | Quét mã QR dán trên thân máy | Xem nhanh "Hộ chiếu thiết bị" (thông số, lịch sử, cẩm nang lỗi). | • Camera decode QR trong < 1.5s.<br>• Hiển thị đúng tên máy, mã máy, trạng thái và lịch sử 5 lần bảo trì gần nhất. |
| **US-02** | Operator | Khai báo số giờ chạy máy đầu/cuối ca | Cung cấp dữ liệu cho hệ thống tính mốc bảo dưỡng. | • Form chỉ nhận số dương lớn hơn chỉ số lần nhập trước.<br>• Lưu log timestamp và tên người nhập. |
| **US-03** | Operator | Tạo phiếu SOS khẩn cấp kèm ảnh lỗi | Báo cáo sự cố dừng chuyền cho kỹ sư ME tức thời. | • Bắt buộc chọn mức độ nghiêm trọng (Low/Medium/High/Critical).<br>• Cho phép đính kèm ít nhất 1 ảnh từ camera.<br>• Trạng thái máy đổi sang `Repairing` ngay sau khi gửi. |
| **US-04** | ME Engineer | Nhận notification sự cố & bấm tiếp nhận | Xác nhận bắt đầu sửa chữa máy hỏng. | • Notification xuất hiện trong < 3s sau khi Operator gửi.<br>• Nhấn notification mở trực tiếp màn hình chi tiết phiếu SOS.<br>• Ghi nhận `claimed_at` để tính MTTR.<br>• **Race condition:** DB dùng `UPDATE work_orders SET status='in_progress', assignee_id=:me_id WHERE id=:id AND status='pending'` — nếu 0 row bị ảnh hưởng (ME khác đã thắng), app hiển thị thông báo "Phiếu đã được tiếp nhận bởi kỹ sư khác" và không cho phép tiếp nhận lại. |
| **US-05** | ME Engineer | Thực hiện PM Checklist & tải ảnh linh kiện | Hoàn tất bảo dưỡng định kỳ đúng quy trình. | • Phải tích 100% hạng mục mới kích hoạt nút "Hoàn thành".<br>• Các hạng mục đánh dấu "Bắt buộc chụp ảnh" phải có ít nhất 1 ảnh đính kèm mới được tích. |
| **US-06** | ME Engineer | Khai báo vật tư tiêu hao tự lấy từ Tủ vật tư nhanh | Ghi nhận lý lịch phụ tùng của máy và hỗ trợ kiểm soát tồn tủ. | • Cho phép chọn vật tư tiêu hao từ danh mục có sẵn và nhập số lượng.<br>• Tự động trừ số lượng tồn tủ vật tư nhanh và lưu vào lịch sử máy. |
| **US-07** | ME Engineer | Gửi đề xuất thay linh kiện đắt tiền lên Supervisor | Xin phê duyệt trước khi tự ý thay thế phụ tùng giá trị cao. | • ME chọn phụ tùng, nhập đơn giá và lý do đề xuất.<br>• Phiếu đề xuất chuyển trạng thái `Pending Approval`; ME không thể tự duyệt.<br>• Supervisor nhận notification về đề xuất mới. |
| **US-08** | Supervisor | Ký tên điện tử nghiệm thu trên màn hình | Xác nhận máy đã được sửa/bảo trì đạt chuẩn. | • Canvas chữ ký xuất file PNG tối thiểu 300×150px.<br>• Không cho phép lưu nếu canvas trống.<br>• Máy tự động về trạng thái `Active` sau khi lưu. |
| **US-09** | Supervisor | Phê duyệt / từ chối đề xuất thay linh kiện đắt tiền | Kiểm soát chi phí sửa chữa phân xưởng. | • Hiển thị cảnh báo màu đỏ nếu đơn giá vượt hạn mức cấu hình.<br>• Lưu rõ tên Supervisor, thời điểm và lý do từ chối (nếu có). |
| **US-10** | Supervisor | Xem Dashboard thống kê Downtime | Giám sát hiệu suất và thời gian dừng máy toàn phân xưởng. | • Biểu đồ tròn tỷ lệ máy Active/Repairing/Maintenance.<br>• Thống kê tổng giờ Downtime tích lũy theo ngày/tuần/tháng.<br>• Danh sách top 5 máy có Downtime cao nhất. |
| **US-11** | Supervisor | Cấu hình mốc giờ bảo dưỡng định kỳ **và ngưỡng duyệt chi phí linh kiện** | Tự động hóa việc tạo PM Checklist và kiểm soát chi phí thay thế. | • Cấu hình được nhiều mốc giờ (500h, 1000h, 2000h) cho từng model máy.<br>• Hệ thống tự sinh PM Checklist khi số giờ chạy vượt mốc.<br>• Cấu hình được ngưỡng giá trị linh kiện (VD: 2.000.000đ); đề xuất vượt ngưỡng mới yêu cầu duyệt, dưới ngưỡng ME tự ghi nhận không cần duyệt.<br>• Chỉ Supervisor của phân xưởng đó mới chỉnh được cấu hình — RLS kiểm tra `workshop_id` khớp. |
| **US-12** | ME Engineer | Xem danh sách toàn bộ phiếu công việc đang mở | Quản lý và ưu tiên xử lý các sự cố theo mức độ nghiêm trọng. | • Hiển thị danh sách Work Order lọc theo 4 tab: Tất cả / Chờ (Pending) / Đang xử lý (In Progress) / Hoàn thành (Completed).<br>• Sắp xếp theo mức độ nghiêm trọng và thời gian tạo phiếu. |
| **US-13** | Operator / Supervisor | Hủy phiếu SOS đã báo nhầm | Tránh ME mất thời gian xử lý sự cố không có thật. | • Chỉ hủy được khi phiếu còn ở trạng thái `Pending` (chưa có ME tiếp nhận).<br>• Trạng thái máy tự động về `Active` sau khi hủy.<br>• Lưu lý do hủy và tên người hủy để audit. |
| **US-14** | Supervisor | Quản lý & Cấp tài khoản nhân sự xưởng (Thêm tay hoặc Import Excel) | Cấp quyền truy cập ứng dụng cho công nhân Operator & kỹ sư ME thuộc phân xưởng mình phụ trách. | • Hỗ trợ thêm tay thủ công từng nhân viên (nhập Họ tên, Email, Mã NV, Role).<br>• Hỗ trợ upload file Excel/CSV (.xlsx/.csv) để import danh sách nhân viên hàng loạt.<br>• Tự động gán `workshop_id` trùng với Supervisor khởi tạo (RLS cách ly).<br>• Chỉ Supervisor mới quản lý/thêm được nhân viên thuộc phân xưởng mình phụ trách. |

---

## 5. Thiết kế Giao diện Mobile (UI/UX Wireframes)

### A. Màn hình Machine Passport (Operator)
```
┌─────────────────────────────────┐
│  ←   Máy dập thủy lực MC-102   │  ← Header: Tên + Mã máy
│      [● HOẠT ĐỘNG]             │  ← Tag trạng thái màu Xanh
├─────────────────────────────────┤
│  THÔNG SỐ KỸ THUẬT             │
│  • Công suất: 150 kW            │
│  • Áp suất max: 250 bar         │
│  • Mốc bảo trì tiếp theo: 500h  │
│  • Giờ chạy hiện tại: 463h      │
├─────────────────────────────────┤
│  LỊCH SỬ BẢO TRÌ GẦN NHẤT     │
│  ✓ 12/06 - Thay dầu 500h - ME A│
│  ✓ 01/04 - Sửa SOS van áp - ME B│
│  ✓ 15/01 - Bảo trì 1000h - ME A│
├─────────────────────────────────┤
│  CẨM NANG XỬ LÝ LỖI NHANH     │
│  • Máy rung mạnh → Kiểm tra bu-lông chân │
│  • Áp suất thấp → Kiểm tra van xả │
├─────────────────────────────────┤
│ [Cập nhật giờ máy chạy]        │  ← Nút thứ cấp
│ [🚨 BÁO LỖI SOS KHẨN CẤP 🚨]  │  ← Nút đỏ nổi bật
└─────────────────────────────────┘
```
- **Trạng thái màu:** `Hoạt động` → Xanh lá | `Sự cố` → Đỏ | `Bảo trì` → Vàng | `Ngừng` → Xám.
- **Cảnh báo ngưỡng:** Thanh progress bar hiển thị % số giờ còn lại đến mốc bảo trì tiếp theo; chuyển màu vàng khi còn < 10%.

### B. Màn hình Tạo phiếu SOS (Operator)
```
┌─────────────────────────────────┐
│  ←   Báo lỗi SOS - MC-102      │
├─────────────────────────────────┤
│  Mức độ nghiêm trọng           │
│  ○ Low  ○ Medium  ● High  ○ Critical │
├─────────────────────────────────┤
│  Mô tả sự cố                   │
│  ┌──────────────────────────┐  │
│  │ Máy phát tiếng kêu lớn, │  │
│  │ áp suất giảm đột ngột...│  │
│  └──────────────────────────┘  │
├─────────────────────────────────┤
│  Ảnh hiện trạng lỗi            │
│  ┌────┐ ┌────┐ ┌────┐         │
│  │IMG1│ │IMG2│ │ + │          │
│  └────┘ └────┘ └────┘         │
├─────────────────────────────────┤
│      [GỬI PHIẾU SOS]          │
└─────────────────────────────────┘
```

### C. Màn hình Danh sách Work Order (ME Engineer)
```
┌─────────────────────────────────┐
│  Công việc của tôi              │
│  [Tất cả][Chờ][Xử lý][Xong]  │  ← Tab filter
├─────────────────────────────────┤
│  🔴 CRITICAL - MC-102           │
│  Áp suất giảm đột ngột          │
│  ⏱ 14 phút trước  [Tiếp nhận] │
├─────────────────────────────────┤
│  🟠 HIGH - MC-205               │
│  Máy rung bất thường            │
│  ⏱ 1 giờ trước    [Tiếp nhận] │
├─────────────────────────────────┤
│  🔵 PM - MC-301 (500h)          │
│  Bảo trì định kỳ mốc 500h       │
│  ⏱ 2 giờ trước    [Bắt đầu]   │
├─────────────────────────────────┤
│  🟡 MEDIUM - MC-108             │
│  Đang xử lý... (In Progress)    │
│  ⏱ Tiếp nhận lúc 08:30        │
└─────────────────────────────────┘
```
- Màu badge theo mức độ: Critical=Đỏ, High=Cam, Medium=Vàng, Low=Xanh dương.
- PM Checklist hiển thị ký hiệu `🔵 PM` phân biệt với SOS.

### D. Màn hình PM Checklist (ME Engineer)
```
┌─────────────────────────────────┐
│  ←  Bảo trì định kỳ mốc 500h   │
│     MC-102 | Tiến độ: 2/5 ✓    │
├─────────────────────────────────┤
│  ☑ Thay dầu bôi trơn trục chính│
│     📷 [Ảnh linh kiện đã upload]│  ← Bắt buộc có ảnh
│  ☑ Kiểm tra áp suất khí nén    │
│     ✓ Đạt 220 bar               │
│  ☐ Siết chặt bu-lông chân máy  │  ← Chưa thực hiện
│  ☐ Vệ sinh bộ lọc dầu          │
│  ☐ Kiểm tra dây curoa / dây đai│
├─────────────────────────────────┤
│  Ảnh bằng chứng bảo dưỡng      │
│  ┌──────────────────────────┐  │
│  │  + Thêm ảnh linh kiện    │  │  ← Nét đứt khi chưa upload
│  └──────────────────────────┘  │
├─────────────────────────────────┤
│  [Hoàn thành & Gửi nghiệm thu] │  ← Disabled khi chưa tích 100%
└─────────────────────────────────┘
```

### E. Màn hình Nghiệm thu & Ký tên (Supervisor)
```
┌─────────────────────────────────┐
│  ←  Nghiệm thu - MC-102        │
├─────────────────────────────────┤
│  TÓM TẮT CÔNG VIỆC             │
│  Máy: Máy dập thủy lực MC-102  │
│  Kỹ sư: Nguyễn Văn A           │
│  Thời gian dừng: 2h 35m        │
│  Vật tư đã thay:               │
│   • Dầu thủy lực 46# (5 lít)   │
│   • Gioăng làm kín van (2 cái) │
├─────────────────────────────────┤
│  CHỮ KÝ NGHIỆM THU             │
│  ┌──────────────────────────┐  │
│  │                          │  │
│  │  Ký tên vào đây để       │  │
│  │  nghiệm thu bàn giao     │  │
│  │                          │  │
│  └──────────────────────────┘  │
├─────────────────────────────────┤
│[Xóa chữ ký] [✗ Từ chối] [✓ Xác nhận] │
└─────────────────────────────────┘
```
- Nút "Xác nhận" màu xanh lá, disabled khi canvas chữ ký trống.
- Nút "Từ chối" màu đỏ — mở dialog nhập lý do từ chối trước khi gửi; phiếu chuyển về `REJECTED` → ME tiếp tục sửa lại.
- Hiển thị tổng Downtime để Supervisor nắm bối cảnh trước khi ký.

### F. Màn hình Dashboard Downtime (Supervisor)
```
┌─────────────────────────────────┐
│  Dashboard Phân xưởng          │
│  [Hôm nay] [7 ngày] [30 ngày] │  ← Bộ lọc thời gian
├─────────────────────────────────┤
│  TRẠNG THÁI PHÂN XƯỞNG         │
│  ┌──────────────────────────┐  │
│  │  🟢 Active:   18 máy     │  │
│  │  🔴 Repairing: 3 máy     │  │
│  │  🟡 Maintenance: 2 máy   │  │
│  └──────────────────────────┘  │
│         [Biểu đồ tròn]        │
├─────────────────────────────────┤
│  TỔNG DOWNTIME HÔM NAY: 6h 40m │
│  ▓▓▓▓▓▓▓░░░░░░░░ 42%          │  ← Bar chart
├─────────────────────────────────┤
│  TOP 5 MÁY DOWNTIME CAO NHẤT  │
│  1. MC-102 — 2h 35m (SOS)     │
│  2. MC-205 — 1h 50m (SOS)     │
│  3. MC-301 — 1h 20m (PM)      │
│  4. MC-108 — 45m   (SOS)      │
│  5. MC-412 — 10m   (PM)       │
├─────────────────────────────────┤
│  SỰ CỐ ĐANG MỞ (3)            │
│  • MC-102 - Critical - ME A    │
│  • MC-205 - High - Chờ tiếp nhận│
└─────────────────────────────────┘
```
- Biểu đồ tròn (Pie Chart) tỷ lệ trạng thái máy; Bar Chart Downtime theo giờ trong ngày.
- Danh sách sự cố đang mở tap vào chuyển trực tiếp sang phiếu để ký nghiệm thu.

### G. Popup Nhập giờ chạy máy (Operator)
```
┌─────────────────────────────────┐
│     Cập nhật giờ chạy máy      │
│         MC-102                  │
├─────────────────────────────────┤
│  Chỉ số giờ lần trước: 463h    │
│                                 │
│  Chỉ số giờ hiện tại           │
│  ┌──────────────────────────┐  │
│  │         475              │  │  ← Chỉ nhận số > 463
│  └──────────────────────────┘  │
│  ⚠ Phải lớn hơn chỉ số trước  │  ← Hiện khi nhập sai
├─────────────────────────────────┤
│  Ca làm việc                   │
│  ○ Đầu ca    ● Cuối ca         │
├─────────────────────────────────┤
│    [Hủy]    [Lưu giờ chạy]    │
└─────────────────────────────────┘
```
- Validation real-time: nút "Lưu" disabled nếu giá trị ≤ chỉ số lần trước.
- Lưu log: timestamp + tên Operator nhập vào bảng `running_hours_log`.

### H. Màn hình Duyệt đề xuất linh kiện (Supervisor)
```
┌─────────────────────────────────┐
│  ←  Đề xuất linh kiện          │
│     Work Order: MC-102 / SOS   │
├─────────────────────────────────┤
│  KỸ SƯ ĐỀ XUẤT                │
│  Nguyễn Văn A — 10:25 hôm nay  │
├─────────────────────────────────┤
│  CHI TIẾT ĐỀ XUẤT              │
│  Linh kiện: Van điều áp PN-16  │
│  Số lượng: 1 cái               │
│  Đơn giá: 3.500.000đ           │
│  ⚠ Vượt ngưỡng duyệt 2.000.000đ│  ← Cảnh báo đỏ
│                                 │
│  Lý do: Van bị rò rỉ áp suất,  │
│  không thể bịt kín bằng gioăng │
├─────────────────────────────────┤
│  Lý do từ chối (nếu từ chối)   │
│  ┌──────────────────────────┐  │
│  │                          │  │
│  └──────────────────────────┘  │
├─────────────────────────────────┤
│  [✗ Từ chối]  [✓ Phê duyệt]   │
└─────────────────────────────────┘
```
- Cảnh báo màu đỏ tự động khi đơn giá vượt `costApprovalThreshold` trong `WorkshopConfig`.
- Lưu `approvedBy` hoặc `rejectionReason` + tên Supervisor sau khi xử lý.

### I. Màn hình Cấu hình ngưỡng hệ thống (Supervisor)
```
┌─────────────────────────────────┐
│  ←  Cấu hình hệ thống          │
│     Phân xưởng A               │
├─────────────────────────────────┤
│  MỐC BẢO TRÌ ĐỊNH KỲ          │
│  Model: Máy dập thủy lực       │
│  ┌─────────────────────────┐   │
│  │ Mốc 1:  500  h  [Xóa]  │   │
│  │ Mốc 2: 1000  h  [Xóa]  │   │
│  │ Mốc 3: 2000  h  [Xóa]  │   │
│  │ [+ Thêm mốc giờ]        │   │
│  └─────────────────────────┘   │
├─────────────────────────────────┤
│  NGƯỠNG DUYỆT CHI PHÍ LINH KIỆN│
│  Đề xuất vượt ngưỡng này       │
│  yêu cầu Supervisor phê duyệt  │
│  ┌──────────────────────────┐  │
│  │     2.000.000  đ         │  │
│  └──────────────────────────┘  │
│  Dưới ngưỡng: ME tự ghi nhận   │
├─────────────────────────────────┤
│         [Lưu cấu hình]         │
└─────────────────────────────────┘
```
- Chỉ Supervisor của phân xưởng đó mới thấy và chỉnh được màn hình này (RLS theo `workshop_id`).
- Thay đổi mốc giờ có hiệu lực với các lần nhập giờ chạy tiếp theo, không ảnh hưởng phiếu đang mở.

### J. Màn hình Quản lý & Import Nhân viên Phân xưởng (Supervisor)
```
┌─────────────────────────────────┐
│  ←  Quản lý Nhân sự Phân xưởng  │
│     Phân xưởng Ép nhựa 1        │
├─────────────────────────────────┤
│  [Danh sách] [Thêm tay] [Excel] │  ← Tab chuyển đổi
├─────────────────────────────────┤
│  THÊM NHÂN VIÊN THỦ CÔNG        │
│  Họ và tên:                     │
│  ┌──────────────────────────┐  │
│  │ Nguyễn Văn B             │  │
│  └──────────────────────────┘  │
│  Email:                        │
│  ┌──────────────────────────┐  │
│  │ nguyenvanb@factory.com   │  │
│  └──────────────────────────┘  │
│  Vai trò:                      │
│  ● Operator (Công nhân)         │
│  ○ ME Engineer (Kỹ sư Bảo trì)  │
│  [+ Tạo tài khoản nhân viên]   │
├─────────────────────────────────┤
│  NHẬP DANH SÁCH TỪ EXCEL        │
│  ┌──────────────────────────┐  │
│  │ 📄 [Chọn file .xlsx/.csv]│  │  ← Nút tải file
│  └──────────────────────────┘  │
│  Tải file mẫu: [📥 File_Mau.xlsx]│
│  Preview (3 nhân viên tìm thấy):│
│  • Tran Van C — Operator        │
│  • Le Van D — ME Engineer       │
│  • Pham Van E — Operator        │
│  [✓ Xác nhận Import Hàng Loạt] │
└─────────────────────────────────┘
```
- Chỉ Supervisor mới thấy màn hình này; tài khoản mới khởi tạo tự động gán `workshop_id` của phân xưởng hiện tại.
- Hỗ trợ 2 hình thức: Thêm thủ công từng nhân viên hoặc chọn file Excel để import hàng loạt.

### K. Màn hình Đăng nhập (Login Screen)
```
┌─────────────────────────────────┐
│          ASSETTRACK             │
│   Hệ thống Quản lý Lý lịch      │
│     & Bảo trì Nhà máy           │
├─────────────────────────────────┤
│  Email / Mã nhân viên           │
│  ┌──────────────────────────┐  │
│  │ supervisor.a@factory.com │  │
│  └──────────────────────────┘  │
│  Mật khẩu                       │
│  ┌──────────────────────────┐  │
│  │ ••••••••••               │  │
│  └──────────────────────────┘  │
│  [✓ Ghi nhớ đăng nhập]          │
│                                 │
│         [ĐĂNG NHẬP]             │
├─────────────────────────────────┤
│  Hỗ trợ kỹ thuật: 1900-xxxx     │
└─────────────────────────────────┘
```
- Điều hướng tự động dựa trên `role` (`operator`, `me_engineer`, `supervisor`) sau khi xác thực thành công.

---

## 6. Luồng Trạng thái Work Order (State Machine)

Định nghĩa đầy đủ các trạng thái của phiếu công việc để tránh nhầm lẫn khi implement DB Trigger:

```
[Tạo phiếu]
     ↓
  PENDING ──(Supervisor / Operator hủy)──→ CANCELLED ──→ [Kết thúc]
     │
     │ (ME bấm Tiếp nhận — DB dùng optimistic lock,
     │  chỉ 1 ME thắng race condition)
     ↓
  IN_PROGRESS ──(ME bấm Hủy nhận việc)──→ PENDING  (trả lại hàng chờ)
     │
     │ (ME bấm Hoàn thành)
     ↓
  COMPLETED
     │                      ┌──→ REJECTED ──(ME sửa lại)──→ IN_PROGRESS
     │ (Supervisor xét)     │
     └──────────────────────┤
                            └──→ APPROVED ──→ [Kết thúc]
```

| Trạng thái | Mô tả | Ai thực hiện chuyển |
| :--- | :--- | :--- |
| `PENDING` | Phiếu vừa tạo, chờ ME tiếp nhận | Operator tạo / Hệ thống tự sinh PM |
| `IN_PROGRESS` | ME đã tiếp nhận, đang sửa chữa / bảo trì | ME bấm "Tiếp nhận" — DB dùng `UPDATE ... WHERE status = 'pending' RETURNING id` để đảm bảo chỉ 1 ME thắng |
| `COMPLETED` | ME hoàn thành, chờ Supervisor nghiệm thu | ME bấm "Hoàn thành" |
| `APPROVED` | Supervisor đã ký nghiệm thu, máy về `ACTIVE` | DB Trigger sau khi lưu chữ ký |
| `REJECTED` | Supervisor từ chối nghiệm thu, yêu cầu ME làm lại | Supervisor bấm "Từ chối" kèm lý do; phiếu quay về `IN_PROGRESS` |
| `CANCELLED` | Phiếu bị hủy (báo nhầm / không còn cần thiết) | Operator hoặc Supervisor hủy khi phiếu còn ở `PENDING`; máy về `ACTIVE` |

> **Lưu ý DB:** Trạng thái `REJECTED` → `IN_PROGRESS` phải lưu lại `rejection_reason` và `rejected_by` để audit. Chỉ cho phép hủy (`CANCELLED`) khi phiếu còn ở `PENDING` — không hủy được phiếu đang sửa.

**Trạng thái máy (Machine) tương ứng:**

| Sự kiện | Trạng thái máy trước | Trạng thái máy sau |
| :--- | :--- | :--- |
| Tạo phiếu SOS | `ACTIVE` | `REPAIRING` |
| Tạo PM Checklist | `ACTIVE` | `MAINTENANCE` |
| Phiếu được `APPROVED` | `REPAIRING` / `MAINTENANCE` | `ACTIVE` |
| Phiếu bị `CANCELLED` (khi còn `PENDING`) | `REPAIRING` | `ACTIVE` |

---

## 7. Phân công Công việc Full-stack & Lộ trình Phát triển (Roadmap 5 Tuần)

### 7.1. Phân công công việc (Task Assignment)
Cả **2 thành viên** đều là Full-stack Developers, hợp tác phát triển theo từng Module tính năng:

| Module / Tính năng | Thành viên Chủ trì | Thành viên Phối hợp | Công việc chi tiết |
| :--- | :--- | :--- | :--- |
| **Module 1: Auth, Máy móc & QR Passport** | **Thành viên 1** | **Thành viên 2** | • *TV1:* Cấu trúc Flutter project, UI Machine Passport, tích hợp `mobile_scanner`, offline cache.<br>• *TV2:* Tạo Supabase DB, bảng `machines`, `profiles`, cài đặt Auth RLS. |
| **Module 2: SOS Breakdown & Push Notification** | **Thành viên 2** | **Thành viên 1** | • *TV2:* Tạo bảng `work_orders`, DB Trigger đổi trạng thái máy, Edge Function gọi Firebase FCM.<br>• *TV1:* UI Form SOS, đính kèm ảnh lỗi, màn hình danh sách Work Order, lắng nghe FCM. |
| **Module 3: PM Checklist & Spare Parts** | **Thành viên 1** | **Thành viên 2** | • *TV1:* UI checklist tương tác, tích hợp `image_picker`, UI đề xuất & duyệt vật tư.<br>• *TV2:* Bảng `pm_checklists`, `pm_checklist_items`, `spare_parts_requests`, Supabase Storage Bucket `work-order-images`. |
| **Module 4: Ký nghiệm thu & Dashboard Downtime** | **Thành viên 2** | **Thành viên 1** | • *TV2:* Canvas ký tên nghiệm thu (`signature`), Bucket `signatures`, DB Trigger về `active`.<br>• *TV1:* UI Dashboard biểu đồ Downtime (`fl_chart`), kết nối SQL Aggregates. |

---

### 7.2. Lịch trình phát triển (Roadmap 5 Tuần)

- **Tuần 1: Khởi động hệ thống & Nền tảng**
  - *Cả 2 thành viên:* Thống nhất API Contract, cấu hình Supabase và thiết lập Flutter project.
  - *Thành viên 1:* Khởi tạo Flutter Project, cài Riverpod, thiết lập Theme nhà máy, màn hình Login.
  - *Thành viên 2:* Tạo Supabase Project, chạy mã DDL đầy đủ, cấu hình RLS Policies & DB Triggers.

- **Tuần 2: Hoàn thiện Module 1 (QR Code & Machine Passport)**
  - *Thành viên 1:* UI camera quét QR, màn hình Hộ chiếu thiết bị, popup nhập giờ chạy, **offline queue** (lưu Machine Passport vào local cache để đọc; lưu thao tác ghi vào SQLite queue khi mất mạng, tự đồng bộ lên Supabase khi có mạng trở lại, hiển thị banner trạng thái đồng bộ).
  - *Thành viên 2:* Nhập dữ liệu máy mẫu, tạo RPC Function xử lý mã QR, sinh QR code mẫu để test.

- **Tuần 3: Hoàn thiện Module 2 (Breakdown SOS & Push Notification)**
  - *Thành viên 1:* Form báo lỗi SOS, chụp ảnh đính kèm, màn hình danh sách Work Order với filter/sort.
  - *Thành viên 2:* DB Trigger đổi trạng thái máy sang `repairing`, Edge Function gửi push noti FCM.

- **Tuần 4: Hoàn thiện Module 3 & 4 (PM Checklist, Spare Parts, Chữ ký)**
  - *Thành viên 1:* UI Checklist bảo dưỡng, upload ảnh linh kiện, UI đề xuất vật tư từ ME.
  - *Thành viên 2:* Canvas ký tên nghiệm thu, lưu chữ ký vào Supabase Storage, UI phê duyệt vật tư cho Supervisor.

- **Tuần 5: Dashboard, Cấu hình PM & Testing**
  - *Thành viên 1:* Dashboard biểu đồ Downtime (Pie Chart + Bar Chart), màn hình cấu hình mốc giờ PM **và ngưỡng chi phí linh kiện** (tính năng 12 mở rộng).
  - *Thành viên 2:* SQL Aggregates truy vấn dữ liệu Downtime, test toàn bộ DB Trigger & Edge Function, **kiểm tra RLS đa phân xưởng** (Supervisor A không thấy dữ liệu phân xưởng B).
  - *Cả 2 thành viên:* Test end-to-end toàn bộ luồng với mã QR in giấy, kiểm tra hành vi offline (banner, block ghi), sửa lỗi và đóng gói APK/IPA.

---

## 8. Các Tài liệu Phân tích & Thiết kế Chi tiết

Để xem chi tiết mô hình hóa kỹ thuật UML và kịch bản cơ sở dữ liệu, tham khảo các tài liệu sau:

1. 📘 **Phân tích & Thiết kế Kỹ thuật Hệ thống (Technical SAD):** [system_design.md](./system_design.md)
   - *Bao gồm:* Yêu cầu kỹ thuật FR/NFR, Biểu đồ Use Case & Đặc tả, Biểu đồ Hoạt động (Activity Diagrams), Biểu đồ Tuần tự (Sequence Diagrams), Biểu đồ Chuyển trạng thái (State Transition Diagrams), Biểu đồ Thực thể Lớp (UML Class Diagram), và Kiến trúc Hệ thống.

2. 🗄️ **Thiết kế Cơ sở Dữ liệu & Tập lệnh SQL (Database Schema):** [database_schema.md](./database_schema.md)
   - *Bao gồm:* Sơ đồ ERD, Tập lệnh SQL DDL (Tạo Bảng, Enum, Trigger tự động đồng bộ Profile), Chính sách Bảo mật cấp dòng (RLS Policies), và Cấu hình Supabase Storage Buckets.
