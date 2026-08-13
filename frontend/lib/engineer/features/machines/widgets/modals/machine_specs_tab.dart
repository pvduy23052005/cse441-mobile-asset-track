import 'package:flutter/material.dart';
import '../../models/machine_model.dart';

class MachineSpecsTab extends StatelessWidget {
  final MachineModel machine;

  const MachineSpecsTab({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    final remainingHours = machine.nextMaintenanceHours - machine.runningHours;
    final isNearMaintenance = remainingHours > 0 && remainingHours <= machine.nextMaintenanceHours * 0.1;
    final isOverdue = remainingHours <= 0;
    final progress = (machine.runningHours / machine.nextMaintenanceHours).clamp(0.0, 1.0);

    final specs = machine.specifications;
    final power = specs['power']?.toString() ?? '37 kW';
    final voltage = specs['voltage']?.toString() ?? '380V / 50Hz';
    final manufacturer = specs['manufacturer']?.toString() ?? 'Mazak Japan';
    final year = specs['year']?.toString() ?? '2023';
    final unitLabel = machine.trackingUnit == 'KM' ? 'km' : 'h';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Grid 2x2 Thông Số Kỹ Thuật (Co giãn vừa khít theo chữ, không có khoảng trống thừa)
        Row(
          children: [
            Expanded(child: _buildSpecTile('Công Suất', power)),
            const SizedBox(width: 8),
            Expanded(child: _buildSpecTile('Điện Áp Hoạt Động', voltage)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSpecTile('Hãng Sản Xuất', manufacturer)),
            const SizedBox(width: 8),
            Expanded(child: _buildSpecTile('Năm Sản Xuất', year)),
          ],
        ),
        const SizedBox(height: 10),

        // 2. Maintenance ProgressBar (Co gọn khít, thanh thoát)
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isOverdue
                ? const Color(0xFFFFF1F2) // bg-rose-50
                : isNearMaintenance
                    ? const Color(0xFFFEF3C7) // bg-amber-50
                    : const Color(0xFFF8FAFC), // bg-slate-50
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isOverdue
                  ? const Color(0xFFFECDD3) // border-rose-200
                  : isNearMaintenance
                      ? const Color(0xFFFDE68A) // border-amber-200
                      : const Color(0xFFE2E8F0), // border-slate-200
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Text(
                          'Mốc bảo trì tiếp theo:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        if (isNearMaintenance)
                          const Text(
                            '⚠️ Sắp đến hạn (<10%)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309), // text-amber-700
                            ),
                          ),
                        if (isOverdue)
                          const Text(
                            '🚨 Quá hạn bảo trì!',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFBE123C), // text-rose-700
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${machine.nextMaintenanceHours.toInt()}$unitLabel',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: Color(0xFF047857), // text-emerald-700
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Progress Bar Indicator (w-full bg-slate-200 h-2 rounded-full)
              ClipRRect(
                borderRadius: BorderRadius.circular(999.0),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverdue
                        ? const Color(0xFFE11D48)
                        : isNearMaintenance
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Bảo trì gần nhất: ${machine.lastMaintenanceDate} (${machine.lastMaintenanceHours.toInt()}$unitLabel)',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B), // text-slate-500
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
