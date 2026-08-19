import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../models/pm_checklist_model.dart';

class PMChecklistModal extends StatefulWidget {
  final PMChecklistModel pm;
  final ValueChanged<PMChecklistModel> onCompletePM;

  const PMChecklistModal({
    super.key,
    required this.pm,
    required this.onCompletePM,
  });

  static Future<void> show(
    BuildContext context, {
    required PMChecklistModel pm,
    required ValueChanged<PMChecklistModel> onCompletePM,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PMChecklistModal',
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: PMChecklistModal(
            pm: pm,
            onCompletePM: onCompletePM,
          ),
        ),
      ),
    );
  }

  @override
  State<PMChecklistModal> createState() => _PMChecklistModalState();
}

class _PMChecklistModalState extends State<PMChecklistModal> {
  late List<PMChecklistItem> _items;

  @override
  void initState() {
    super.initState();
    final isDone = widget.pm.status.toUpperCase() == 'COMPLETED' ||
        widget.pm.status.toUpperCase() == 'PENDING_APPROVAL' ||
        widget.pm.status.toUpperCase() == 'APPROVED';

    if (isDone) {
      _items = widget.pm.items.map((i) => i.copyWith(isCompleted: true)).toList();
    } else {
      _items = List.from(widget.pm.items);
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index] = _items[index].copyWith(isCompleted: !_items[index].isCompleted);
    });
  }

  bool get _isAllCompleted => _items.every((item) => item.isCompleted);

  @override
  Widget build(BuildContext context) {
    final pm = widget.pm;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBEB), // amber-50
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Color(0xFFFDE68A))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pm.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mốc ${pm.scheduledHours.toInt()}h',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pm.machineName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Checklist items
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hạng mục công việc kiểm tra định kỳ (PM):',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 10),
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => _toggleItem(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.isCompleted ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: item.isCompleted ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item.isCompleted,
                                activeColor: AppTheme.primaryColor,
                                onChanged: (_) => _toggleItem(index),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: item.isCompleted ? FontWeight.bold : FontWeight.normal,
                                    color: item.isCompleted ? const Color(0xFF065F46) : const Color(0xFF0F172A),
                                    decoration: item.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Footer complete button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAllCompleted ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onCompletePM(
                    PMChecklistModel(
                      id: pm.id,
                      code: pm.code,
                      machineId: pm.machineId,
                      machineCode: pm.machineCode,
                      machineName: pm.machineName,
                      scheduledHours: pm.scheduledHours,
                      status: 'COMPLETED',
                      items: _items,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  _isAllCompleted ? 'Hoàn Thành Kiểm Tra PM' : 'Xác Nhận Tiến Độ PM',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
