import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/work_order_model.dart';

class EngineerDashboardService {
  final Dio _dio = ApiClient.instance;

  // Mock initial work orders matching Wireframe K / ui prototype screenshot
  List<WorkOrderModel> getMockWorkOrders() {
    return [
      WorkOrderModel(
        id: 'wo-101',
        code: 'SOS-2026-001',
        machineId: 'MC-001',
        machineName: 'Máy Trung Tâm Gia Công CNC 5 Trục',
        severity: WorkOrderSeverity.high,
        status: WorkOrderStatus.inProgress,
        description: 'Trục chính Spindle phát ra tiếng kêu rít lớn khi quay tốc độ > 8000 RPM, kẹt gắp dao tự động làm dừng toàn bộ chuyển B.',
        imageUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
        assigneeName: 'Kỹ Sư ME Trần Minh Đức',
        createdAt: '10 phút trước',
      ),
      WorkOrderModel(
        id: 'wo-102',
        code: 'SOS-2026-002',
        machineId: 'MC-002',
        machineName: 'Máy Dập Thủy Lực 500 Tấn',
        severity: WorkOrderSeverity.critical,
        status: WorkOrderStatus.pending,
        description: 'Rò rỉ dầu thủy lực xi lanh ép chính, áp suất hạ dốc nguy cơ rơi khuôn dập.',
        createdAt: '30 phút trước',
      ),
      WorkOrderModel(
        id: 'wo-103',
        code: 'SOS-2026-003',
        machineId: 'MC-003',
        machineName: 'Máy Nén Khí Trục Vít Công Nghiệp',
        severity: WorkOrderSeverity.medium,
        status: WorkOrderStatus.pending,
        description: 'Áp suất khí nén đầu ra tụt giảm dưới 4.5 Bar, bình tách dầu phát tiếng ồn lạ tại van xả an toàn.',
        imageUrl: 'https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=500',
        createdAt: '1 giờ trước',
      ),
    ];
  }

  List<PMChecklistModel> getMockPMChecklists() {
    return [
      PMChecklistModel(
        id: 'pm-101',
        code: 'PM-2026-0500H',
        machineId: 'MC-005',
        machineName: 'Dây Chuyền Hàn Robot Tự Động',
        scheduledHours: 1000,
        status: PMChecklistStatus.pending,
        itemCount: 6,
      ),
    ];
  }

  // Update status locally or send API request
  Future<bool> updateStatus(String machineId, String status) async {
    try {
      await _dio.patch('/machines/$machineId/status', data: {'status': status});
      return true;
    } catch (_) {
      return false;
    }
  }
}
