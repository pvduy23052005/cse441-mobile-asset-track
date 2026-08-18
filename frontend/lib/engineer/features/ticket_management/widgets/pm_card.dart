import 'package:flutter/material.dart';
import '../models/pm_checklist_model.dart';

class PMCard extends StatelessWidget {
  final PMChecklistModel pm;
  final VoidCallback onTap;

  const PMCard({
    super.key,
    required this.pm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // bg-slate-50
        borderRadius: BorderRadius.circular(12), // rounded-xl
        border: Border.all(color: const Color(0xFFE2E8F0)), // border-slate-200
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${pm.code} - ${pm.machineName}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800, // font-bold text-slate-900
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Mốc ${pm.scheduledHours.toInt()}h máy chạy',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B), // text-slate-500
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (pm.status.toUpperCase() == 'COMPLETED' ||
              pm.status.toUpperCase() == 'SUBMITTED' ||
              pm.status.toUpperCase() == 'PENDING_APPROVAL' ||
              pm.status.toUpperCase() == 'APPROVED')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 14, color: Color(0xFFB45309)),
                  SizedBox(width: 4),
                  Text(
                    'Chờ Duyệt',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706), // amber-600
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 2,
                  shadowColor: const Color(0xFFD97706).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(
                  'Làm PM',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
