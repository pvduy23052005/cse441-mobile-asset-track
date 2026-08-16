import 'package:flutter/material.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/machine_formatters.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../supervisor/features/machine_management/widgets/assign_operator_dialog.dart';
import '../services/machine_service.dart';
import '../../ticket/widgets/create_sos_ticket_modal.dart';

class MachineDetailModal extends StatefulWidget {
  final MachineModel machine;
  final ValueChanged<MachineModel>? onStatusUpdated;

  const MachineDetailModal({
    super.key,
    required this.machine,
    this.onStatusUpdated,
  });

  static Future<void> show(
    BuildContext context,
    MachineModel machine, {
    ValueChanged<MachineModel>? onStatusUpdated,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MachineDetailModal(
        machine: machine,
        onStatusUpdated: onStatusUpdated,
      ),
    );

    if (result == 'OPEN_SOS' && context.mounted) {
      CreateSosTicketModal.show(context, machine: machine);
    }
  }

  @override
  State<MachineDetailModal> createState() => _MachineDetailModalState();
}

class _MachineDetailModalState extends State<MachineDetailModal> {
  late MachineModel _currentMachine;
  final MachineService _machineService = MachineService();

  @override
  void initState() {
    super.initState();
    _currentMachine = widget.machine;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (widget.machine.id.isEmpty) return;
    try {
      final fresh = await _machineService.getMachineById(widget.machine.id);
      if (mounted) {
        setState(() {
          _currentMachine = fresh;
        });
        widget.onStatusUpdated?.call(fresh);
      }
    } catch (_) {
      // Keep initial machine state if offline or network error
    }
  }

  void _openAssignOperatorModal(BuildContext context) {
    AssignOperatorDialog.show(
      context,
      machine: _currentMachine,
      onOperatorAssigned: (updatedMachine) {
        setState(() {
          _currentMachine = updatedMachine;
        });
        widget.onStatusUpdated?.call(updatedMachine);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userRole = StorageService.getUserRole()?.toLowerCase() ?? '';
    final bool isSupervisor = userRole == 'supervisor';

    final String locationText = _currentMachine.location.isNotEmpty
        ? _currentMachine.location
        : (_currentMachine.specifications['location']?.toString() ??
            _currentMachine.specifications['area']?.toString() ??
            'Chưa cập nhật vị trí');

    final String nextMaintText = _currentMachine.nextMaintenanceHours != null
        ? '${_currentMachine.nextMaintenanceHours} giờ'
        : (_currentMachine.runningHours > 0
            ? '${_currentMachine.runningHours + 500} giờ'
            : 'Chưa thiết lập');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông Tin Chi Tiết Thiết Bị',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.foregroundColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderColor),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Info Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name + Code + Status Chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentMachine.name.isNotEmpty
                                          ? _currentMachine.name
                                          : 'Chưa đặt tên thiết bị',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.foregroundColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Mã: ${_currentMachine.code.isNotEmpty ? _currentMachine.code : "N/A"}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF059669),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentMachine.statusBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _currentMachine.statusLabel,
                                  style: TextStyle(
                                    color: _currentMachine.statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppTheme.borderColor),
                          const SizedBox(height: 14),

                          // Row 1: Model & Giờ vận hành
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.memory_rounded,
                                  label: 'Model máy',
                                  value: _currentMachine.model.isNotEmpty
                                      ? _currentMachine.model
                                      : 'Tiêu chuẩn',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.timer_outlined,
                                  label: 'Giờ vận hành',
                                  value: '${_currentMachine.runningHours} giờ',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Row 2: Vị trí & Mốc bảo trì kế
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.location_on_outlined,
                                  label: 'Vị trí lắp đặt',
                                  value: locationText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.build_circle_outlined,
                                  label: 'Mốc bảo trì kế',
                                  value: nextMaintText,
                                ),
                              ),
                            ],
                          ),

                          // Row 3: Người vận hành phụ trách
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: AppTheme.borderColor),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _currentMachine.operator != null
                                      ? const Color(0xFFE0F2FE)
                                      : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _currentMachine.operator != null
                                        ? const Color(0xFFBAE6FD)
                                        : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 20,
                                  color: _currentMachine.operator != null
                                      ? const Color(0xFF0284C7)
                                      : AppTheme.mutedForegroundColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Người vận hành phụ trách',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.mutedForegroundColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentMachine.operator?.fullName ??
                                          (_currentMachine.operatorId != null &&
                                                  _currentMachine.operatorId!.isNotEmpty
                                              ? 'Mã: ${_currentMachine.operatorId}'
                                              : 'Chưa phân công'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _currentMachine.operator != null ||
                                                (_currentMachine.operatorId != null &&
                                                    _currentMachine.operatorId!.isNotEmpty)
                                            ? AppTheme.foregroundColor
                                            : AppTheme.mutedForegroundColor,
                                      ),
                                    ),
                                    if (_currentMachine.operator?.email != null &&
                                        _currentMachine.operator!.email.isNotEmpty) ...[
                                      const SizedBox(height: 1),
                                      Text(
                                        _currentMachine.operator!.email,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.mutedForegroundColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (_currentMachine.operator?.phone != null &&
                                  _currentMachine.operator!.phone!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        size: 12,
                                        color: Color(0xFF059669),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _currentMachine.operator!.phone!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],

                              // Supervisor Reassign Button (if already assigned)
                              if (isSupervisor && _currentMachine.operator != null)
                                InkWell(
                                  onTap: () => _openAssignOperatorModal(context),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFFBAE6FD),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.sync_alt_rounded,
                                          size: 13,
                                          color: Color(0xFF0284C7),
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Đổi',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0284C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Quick CTA Button if no operator is assigned yet (Supervisor only)
                          if (isSupervisor && _currentMachine.operator == null) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _openAssignOperatorModal(context),
                                icon: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Chọn Operator tiếp quản máy ngay',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Specifications Section
                    const Text(
                      'Thông Số Kỹ Thuật',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.foregroundColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_currentMachine.specifications.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppTheme.mutedForegroundColor,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Không có thông số kỹ thuật bổ sung',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.mutedForegroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          children: _currentMachine.specifications.entries.map((entry) {
                            final readableKey =
                                MachineFormatters.formatSpecKey(entry.key);
                            final readableValue =
                                MachineFormatters.formatSpecValue(entry.value);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.borderColor,
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      readableKey,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.mutedForegroundColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      readableValue,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.foregroundColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                  color: AppTheme.borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppTheme.foregroundColor,
                            ),
                            label: const Text(
                              'Đóng',
                              style: TextStyle(
                                color: AppTheme.foregroundColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context, 'OPEN_SOS');
                            },
                            icon: const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Báo Sự Cố',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(icon, size: 17, color: AppTheme.mutedForegroundColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.mutedForegroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
