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
    final isPendingApproval = pm.status.toUpperCase() == 'COMPLETED' ||
        pm.status.toUpperCase() == 'PENDING_APPROVAL' ||
        pm.status.toUpperCase() == 'APPROVED';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            const SizedBox(width: 12),
            isPendingApproval
                ? OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFBEB),
                      side: const BorderSide(color: Color(0xFFFDE68A), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onTap,
                    icon: const Text('⏳', style: TextStyle(fontSize: 12)),
                    label: const Text(
                      'Chờ Duyệt',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      elevation: 1,
                      shadowColor: const Color(0xFFD97706).withValues(alpha: 0.4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onTap,
                    icon: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                    label: const Text(
                      'Làm PM',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
