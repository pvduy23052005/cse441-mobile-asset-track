import 'package:flutter/material.dart';
import '../../../../core/models/machine_model.dart';

class OperatorMachineCard extends StatelessWidget {
  final MachineModel machine;
  final int index;
  final VoidCallback onTap;

  const OperatorMachineCard({
    super.key,
    required this.machine,
    required this.index,
    required this.onTap,
  });

  String _formatHours(num hours) {
    if (hours == hours.roundToDouble()) {
      return hours.toInt().toString();
    }
    return hours.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> iconStyles = [
      {
        'bg': const Color(0xFFECFDF5),
        'border': const Color(0xFFA7F3D0),
        'color': const Color(0xFF059669),
        'icon': Icons.developer_board_rounded,
      },
      {
        'bg': const Color(0xFFFFE4E6),
        'border': const Color(0xFFFECDD3),
        'color': const Color(0xFFE11D48),
        'icon': Icons.memory_rounded,
      },
      {
        'bg': const Color(0xFFFEF3C7),
        'border': const Color(0xFFFDE68A),
        'color': const Color(0xFFD97706),
        'icon': Icons.precision_manufacturing_rounded,
      },
    ];

    final style = iconStyles[index % iconStyles.length];

    final runningHoursText = _formatHours(machine.runningHours);
    final nextMaintText = machine.nextMaintenanceHours != null
        ? '${_formatHours(machine.nextMaintenanceHours!)}h'
        : (machine.runningHours > 0
              ? '${_formatHours(machine.runningHours + 500)}h'
              : '500h');

    final isTopCard = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopCard ? const Color(0xFF6EE7B7) : const Color(0xFFE2E8F0),
          width: isTopCard ? 1.4 : 1.0,
        ),
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
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style['bg'] as Color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: style['border'] as Color),
                  ),
                  child: Icon(
                    style['icon'] as IconData,
                    color: style['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  TextSpan(
                                    text: machine.name.isNotEmpty
                                        ? machine.name
                                        : 'Thiết bị không tên',
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
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
                                color: machine.statusColor.withValues(
                                  alpha: 0.3,
                                ),
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
                      const SizedBox(height: 4),
                      Text(
                        '$runningHoursText Giờ máy chạy (Mốc kế: $nextMaintText)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
