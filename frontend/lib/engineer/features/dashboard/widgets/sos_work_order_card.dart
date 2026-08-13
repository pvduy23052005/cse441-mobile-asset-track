import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/work_order_model.dart';

class SosWorkOrderCard extends StatelessWidget {
  final WorkOrderModel workOrder;
  final ValueChanged<WorkOrderModel> onClaim;
  final ValueChanged<WorkOrderModel> onComplete;
  final ValueChanged<WorkOrderModel> onTapDetail;

  const SosWorkOrderCard({
    super.key,
    required this.workOrder,
    required this.onClaim,
    required this.onComplete,
    required this.onTapDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // slate-50
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => onTapDetail(workOrder),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Code (Red Monospace) & Severity Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  workOrder.code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: Color(0xFFBE123C), // Rose-700
                  ),
                ),
                _buildSeverityBadge(workOrder.severity),
              ],
            ),
            const SizedBox(height: 6),

            // Machine Name & Description
            Text(
              workOrder.machineName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              workOrder.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),

            // Image Preview (if present)
            if (workOrder.imageUrl != null && workOrder.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  workOrder.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '🖼️ Ảnh hiện trạng máy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Rejection reason banner if rejected by supervisor
            if (workOrder.status == WorkOrderStatus.rejected &&
                workOrder.rejectionReason != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFFDA4AF)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 15,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Supervisor từ chối nghiệm thu: ${workOrder.rejectionReason}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9F1239),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Action Button matching UI prototype
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(WorkOrderSeverity severity) {
    Color bg = const Color(0xFFFEF3C7); // Amber-100
    Color text = const Color(0xFF92400E); // Amber-800
    String label = 'HIGH';

    if (severity == WorkOrderSeverity.critical) {
      bg = const Color(0xFFFFE4E6); // Rose-100
      text = const Color(0xFF9F1239); // Rose-800
      label = 'CRITICAL';
    } else if (severity == WorkOrderSeverity.medium) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFF92400E);
      label = 'MEDIUM';
    } else if (severity == WorkOrderSeverity.low) {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF475569);
      label = 'LOW';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Nghiêm trọng: $label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (workOrder.status == WorkOrderStatus.pending) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          onPressed: () => onClaim(workOrder),
          icon: const Icon(Icons.build_rounded, size: 16),
          label: const Text(
            'Bấm Tiếp Nhận Sửa Chữa',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7), // Cyan/Sky blue matching UI
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    if (workOrder.status == WorkOrderStatus.inProgress ||
        workOrder.status == WorkOrderStatus.rejected) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          onPressed: () => onComplete(workOrder),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
          label: const Text(
            'Hoàn Thành & Gửi Nghiệm Thu',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor, // Emerald Green matching UI
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    if (workOrder.status == WorkOrderStatus.completed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFD97706)),
            SizedBox(width: 4),
            Text(
              'Đã xong - Đang chờ Quản Đốc ký',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF92400E),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
