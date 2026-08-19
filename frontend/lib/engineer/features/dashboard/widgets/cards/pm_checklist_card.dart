import 'package:flutter/material.dart';
import '../../models/work_order_model.dart';

class PmChecklistCard extends StatelessWidget {
  final PMChecklistModel pmChecklist;
  final ValueChanged<PMChecklistModel> onOpenPM;

  const PmChecklistCard({
    super.key,
    required this.pmChecklist,
    required this.onOpenPM,
  });

  @override
  Widget build(BuildContext context) {
    final isPendingApproval = pmChecklist.status == PMChecklistStatus.completed ||
        pmChecklist.status == PMChecklistStatus.approved;

    return InkWell(
      onTap: () => onOpenPM(pmChecklist),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pmChecklist.code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pmChecklist.machineName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mốc số giờ: ${pmChecklist.scheduledHours}h',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            SizedBox(
              height: 34,
              child: isPendingApproval
                  ? OutlinedButton.icon(
                      onPressed: () => onOpenPM(pmChecklist),
                      icon: const Text('⏳', style: TextStyle(fontSize: 12)),
                      label: const Text(
                        'Chờ Duyệt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFBEB),
                        side: const BorderSide(color: Color(0xFFFDE68A), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => onOpenPM(pmChecklist),
                      icon: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                      label: const Text(
                        'Làm PM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
