import 'package:flutter/material.dart';
import '../../models/supervisor_dashboard_model.dart';

class SupervisorKpiCards extends StatelessWidget {
  final SupervisorDashboardStats stats;

  const SupervisorKpiCards({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        _buildKpiContainer(
          borderColor: const Color(0xFF99F6E4),
          iconBgColor: const Color(0xFFF0FDFA),
          iconColor: const Color(0xFF0D9488),
          icon: Icons.memory_rounded,
          title: 'TÌNH TRẠNG THIẾT BỊ',
          subtitle:
              'SOS: ${stats.repairingCount} • PM: ${stats.maintenanceCount} • Dừng: ${stats.stoppedCount}',
          valueWidget: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${stats.activeCount}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: Color(0xFF059669),
                  height: 1,
                ),
              ),
              Text(
                '/${stats.totalMachines}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        _buildKpiContainer(
          borderColor: const Color(0xFFFDE68A),
          iconBgColor: const Color(0xFFFFFBEB),
          iconColor: const Color(0xFFD97706),
          icon: Icons.timer_outlined,
          title: 'TỔNG THỜI GIAN DỪNG MÁY',
          subtitle: 'Downtime tích lũy toàn xưởng',
          valueWidget: Text(
            '${stats.totalDowntimeHours.toStringAsFixed(1)}h',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: Color(0xFFBE123C),
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiContainer({
    required Color borderColor,
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget valueWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          valueWidget,
        ],
      ),
    );
  }
}
