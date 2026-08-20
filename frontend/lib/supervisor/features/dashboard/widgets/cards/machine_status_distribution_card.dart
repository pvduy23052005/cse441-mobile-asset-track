import 'package:flutter/material.dart';
import '../../models/supervisor_dashboard_model.dart';

class MachineStatusDistributionCard extends StatelessWidget {
  final SupervisorDashboardStats stats;

  const MachineStatusDistributionCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              const Row(
                children: [
                  Icon(Icons.pie_chart_outline_rounded,
                      size: 16, color: Color(0xFF0284C7)),
                  SizedBox(width: 6),
                  Text(
                    'PHÂN BỔ TRẠNG THÁI MÁY MÓC',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF334155),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Text(
                'Tổng ${stats.totalMachines} Máy',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (stats.activePercent > 0)
                    Expanded(
                      flex: stats.activePercent,
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  if (stats.repairingPercent > 0)
                    Expanded(
                      flex: stats.repairingPercent,
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  if (stats.maintenancePercent > 0)
                    Expanded(
                      flex: stats.maintenancePercent,
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                  if (stats.stoppedPercent > 0)
                    Expanded(
                      flex: stats.stoppedPercent,
                      child: Container(color: const Color(0xFF6B7280)),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          _buildStatusRow(
            color: const Color(0xFF10B981),
            title: '🟢 Hoạt Động (Active)',
            countText: '${stats.activeCount} Máy',
            percentText: '${stats.activePercent}%',
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            color: const Color(0xFFEF4444),
            title: '🔴 Sự Cố (Repairing SOS)',
            countText: '${stats.repairingCount} Máy',
            percentText: '${stats.repairingPercent}%',
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            color: const Color(0xFFF59E0B),
            title: '🟡 Bảo Trì (Maintenance PM)',
            countText: '${stats.maintenanceCount} Máy',
            percentText: '${stats.maintenancePercent}%',
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            color: const Color(0xFF6B7280),
            title: '⚪ Tạm Dừng / Ngưng Vận Hành (Stopped)',
            countText: '${stats.stoppedCount} Máy',
            percentText: '${stats.stoppedPercent}%',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required Color color,
    required String title,
    required String countText,
    required String percentText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              countText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                percentText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
