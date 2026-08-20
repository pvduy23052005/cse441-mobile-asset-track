import 'package:flutter/material.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/machine_service.dart';

class ChangeStatusDialog extends StatefulWidget {
  final MachineModel machine;
  final ValueChanged<MachineModel> onStatusUpdated;

  const ChangeStatusDialog({
    super.key,
    required this.machine,
    required this.onStatusUpdated,
  });

  static Future<void> show(
    BuildContext context,
    MachineModel machine, {
    required ValueChanged<MachineModel> onStatusUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeStatusDialog(
        machine: machine,
        onStatusUpdated: onStatusUpdated,
      ),
    );
  }

  @override
  State<ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<ChangeStatusDialog> {
  final MachineService _machineService = MachineService();
  late String _selectedStatus;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'ACTIVE',
      'label': 'Đang hoạt động',
      'desc': 'Thiết bị sẵn sàng và đang vận hành bình thường',
      'color': AppTheme.primaryColor,
      'icon': Icons.check_circle_rounded,
    },
    {
      'value': 'MAINTENANCE',
      'label': 'Đang bảo trì',
      'desc': 'Thiết bị đang trong quá trình bảo dưỡng kỹ thuật',
      'color': const Color(0xFFD97706),
      'icon': Icons.build_circle_rounded,
    },
    {
      'value': 'INACTIVE',
      'label': 'Tạm ngưng',
      'desc': 'Thiết bị tạm thời dừng hoạt động theo kế hoạch',
      'color': AppTheme.mutedForegroundColor,
      'icon': Icons.pause_circle_rounded,
    },
    {
      'value': 'ERROR',
      'label': 'Báo lỗi / Sự cố',
      'desc': 'Thiết bị gặp lỗi kỹ thuật cần kỹ sư kiểm tra',
      'color': AppTheme.errorColor,
      'icon': Icons.error_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.machine.status.toUpperCase();
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == widget.machine.status.toUpperCase()) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await _machineService.updateMachineStatus(
        widget.machine.id,
        _selectedStatus,
      );

      if (mounted) {
        widget.onStatusUpdated(updated);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã cập nhật trạng thái thiết bị "${widget.machine.name}" thành công!',
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi cập nhật: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đổi Trạng Thái Thiết Bị',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.machine.code} - ${widget.machine.name}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.mutedForegroundColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.borderColor),
            const SizedBox(height: 16),

            ..._statusOptions.map((opt) {
              final isSelected = _selectedStatus == opt['value'];
              final Color optColor = opt['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedStatus = opt['value'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? optColor.withValues(alpha: 0.08)
                          : AppTheme.secondaryColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? optColor : AppTheme.borderColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(opt['icon'] as IconData, color: optColor, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['label'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? optColor
                                      : AppTheme.foregroundColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt['desc'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.mutedForegroundColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: opt['value'] as String,
                          groupValue: _selectedStatus,
                          activeColor: optColor,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStatus = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        color: AppTheme.foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSaving ? null : _updateStatus,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Lưu Thay Đổi',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
