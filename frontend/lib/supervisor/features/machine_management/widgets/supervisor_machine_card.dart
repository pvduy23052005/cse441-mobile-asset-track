import 'package:flutter/material.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../operator/features/machine/widgets/machine_detail_modal.dart';
import 'change_status_dialog.dart';
import 'machine_qr_modal.dart';

class SupervisorMachineCard extends StatelessWidget {
  final MachineModel machine;
  final ValueChanged<MachineModel>? onStatusUpdated;

  const SupervisorMachineCard({
    super.key,
    required this.machine,
    this.onStatusUpdated,
  });

  void _showDetail(BuildContext context) {
    MachineDetailModal.show(
      context,
      machine,
      onStatusUpdated: onStatusUpdated,
    );
  }

  void _openChangeStatus(BuildContext context) {
    if (onStatusUpdated != null) {
      ChangeStatusDialog.show(
        context,
        machine,
        onStatusUpdated: onStatusUpdated!,
      );
    }
  }

  void _openQrModal(BuildContext context) {
    MachineQrModal.show(context, machine);
  }

  @override
  Widget build(BuildContext context) {
    final String locationText = machine.location.isNotEmpty
        ? machine.location
        : (machine.model.isNotEmpty
            ? 'Model: ${machine.model}'
            : (machine.specifications['location']?.toString() ??
                machine.specifications['area']?.toString() ??
                'Phân xưởng'));

    final String nextMaintText = machine.nextMaintenanceHours != null
        ? '${machine.nextMaintenanceHours}h'
        : (machine.runningHours > 0
            ? '${machine.runningHours + 500}h'
            : 'Chưa thiết lập');

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
                      // Row 1: Code + Name
                      Row(
                        children: [
                          if (machine.code.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                machine.code,
                                style: const TextStyle(
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              machine.name.isNotEmpty
                                  ? machine.name
                                  : 'Thiết bị chưa đặt tên',
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

                // Right: Status Chip & QR Code Button
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openChangeStatus(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: machine.statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: machine.statusColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: machine.statusColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              machine.statusLabel,
                              style: TextStyle(
                                color: machine.statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 16,
                              color: machine.statusColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => _openQrModal(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_rounded,
                                  size: 14,
                                  color: AppTheme.primaryColor,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'QR',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
