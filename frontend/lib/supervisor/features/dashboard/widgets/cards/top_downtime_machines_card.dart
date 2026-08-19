import 'package:flutter/material.dart';
import '../../models/supervisor_dashboard_model.dart';

class TopDowntimeMachinesCard extends StatelessWidget {
  final List<TopDowntimeMachineModel> topMachines;

  const TopDowntimeMachinesCard({
    super.key,
    required this.topMachines,
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
          // Header Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.leaderboard_rounded,
                      size: 16, color: Color(0xFFE11D48)),
                  SizedBox(width: 6),
                  Text(
                    'TOP MÁY CÓ DOWNTIME CAO NHẤT',
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
                'Xếp hạng sự cố',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (topMachines.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Chưa có máy nào phát sinh Downtime kéo dài trong phân xưởng.',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            )
          else
            Column(
              children: topMachines.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final machine = entry.value;

                final isTop1 = index == 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTop1
                        ? const Color(0xFFFFF1F2)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isTop1
                          ? const Color(0xFFFECDD3)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isTop1
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$index',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${machine.code} - ${machine.name}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isTop1
                                      ? const Color(0xFF991B1B)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${machine.incidentCount} lần phát sinh sự cố',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${machine.downtimeHours.toStringAsFixed(1)}h',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          color: isTop1
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF0284C7),
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
