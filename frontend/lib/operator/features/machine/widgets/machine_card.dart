import 'package:flutter/material.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'machine_detail_modal.dart';

class MachineCard extends StatelessWidget {
  final MachineModel machine;

  const MachineCard({
    super.key,
    required this.machine,
  });

  void _showDetail(BuildContext context) {
    MachineDetailModal.show(context, machine);
  }

  @override
  Widget build(BuildContext context) {
    // Determine location string from Firebase data
    final String locationText = machine.location.isNotEmpty
        ? machine.location
        : (machine.model.isNotEmpty
            ? 'Model: ${machine.model}'
            : (machine.specifications['location']?.toString() ??
                machine.specifications['area']?.toString() ??
                'Phân xưởng'));

    // Format maintenance hours string
    final String nextMaintText = machine.nextMaintenanceHours != null
        ? '${machine.nextMaintenanceHours}h'
        : (machine.runningHours > 0 ? '${machine.runningHours + 500}h' : 'Chưa thiết lập');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Code + Name + Status Badge
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  if (machine.code.isNotEmpty)
                                    TextSpan(
                                      text: '${machine.code}  ',
                                      style: const TextStyle(
                                        color: Color(0xFF059669),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  TextSpan(
                                    text: machine.name.isNotEmpty
                                        ? machine.name
                                        : 'Thiết bị chưa đặt tên',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: machine.statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    machine.statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              machine.statusLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: machine.statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Row 2: Location
                      Text(
                        locationText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Row 3: Maintenance milestone
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Mốc bảo trì kế: ',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: nextMaintText,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Trailing Arrow
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
