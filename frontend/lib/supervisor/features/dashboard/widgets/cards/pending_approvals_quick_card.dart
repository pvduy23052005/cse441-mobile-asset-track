import 'package:flutter/material.dart';
import '../../../approvals/models/supervisor_approval_model.dart';

class PendingApprovalsQuickCard extends StatelessWidget {
  final List<SupervisorApprovalModel> pendingItems;
  final VoidCallback onRefresh;
  final ValueChanged<SupervisorApprovalModel> onOpenSignoff;

  const PendingApprovalsQuickCard({
    super.key,
    required this.pendingItems,
    required this.onRefresh,
    required this.onOpenSignoff,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = pendingItems.where((i) => i.status == 'COMPLETED' || i.status == 'PENDING_APPROVAL' || i.status == 'SUBMITTED').length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEF08A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.draw_rounded,
                      size: 14,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'CẦN QUẢN ĐỐC NGHỆM THU GẤP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pendingCount > 0
                      ? const Color(0xFFFFF1F2)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: pendingCount > 0
                        ? const Color(0xFFFECDD3)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Text(
                  '$pendingCount Chờ duyệt',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: pendingCount > 0
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (pendingItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 16, color: Color(0xFF059669)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tất cả phiếu đã được nghiệm thu hoàn tất!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: pendingItems.take(3).map((item) {
                final isPending = item.status == 'COMPLETED' ||
                    item.status == 'PENDING_APPROVAL' ||
                    item.status == 'SUBMITTED';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.code,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${item.machineName} (${item.machineCode})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kỹ sư: ${item.engineerName} • Downtime: ${item.downtimeDuration}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      isPending
                          ? ElevatedButton.icon(
                              onPressed: () => onOpenSignoff(item),
                              icon: const Icon(Icons.draw_rounded, size: 14),
                              label: const Text(
                                'Ký Duyệt',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '✓ Đã Duyệt',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
