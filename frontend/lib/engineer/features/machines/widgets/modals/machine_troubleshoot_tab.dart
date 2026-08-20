import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../services/engineer_machine_service.dart';

class MachineTroubleshootTab extends StatefulWidget {
  final MachineModel machine;
  final ValueChanged<List<TroubleshootingItem>> onSaveTroubleshooting;

  const MachineTroubleshootTab({
    super.key,
    required this.machine,
    required this.onSaveTroubleshooting,
  });

  @override
  State<MachineTroubleshootTab> createState() => _MachineTroubleshootTabState();
}

class _MachineTroubleshootTabState extends State<MachineTroubleshootTab> {
  int? _openIndex = 0;
  bool _isEditing = false;
  late List<TroubleshootingItem> _editList;
  final EngineerMachineService _machineService = EngineerMachineService();

  @override
  void initState() {
    super.initState();
    _editList = List.from(widget.machine.quickTroubleshooting);
  }

  Future<void> _handleSave() async {
    final validList = _editList
        .where((t) => t.issue.trim().isNotEmpty || t.solution.trim().isNotEmpty)
        .toList();

    widget.onSaveTroubleshooting(validList);
    setState(() {
      _isEditing = false;
    });

    final success = await _machineService.updateTroubleshooting(widget.machine.id, validList);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Đã lưu Cẩm nang xử lý lỗi lên DB Server Firestore!'
              : '✅ Đã cập nhật Cẩm nang xử lý lỗi!',
        ),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.build_circle_rounded, size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 6),
                  Text(
                    'Bí kíp xử lý lỗi ME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF78350F),
                    ),
                  ),
                ],
              ),
              if (!_isEditing)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                      _editList = List.from(widget.machine.quickTroubleshooting);
                    });
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 14),
                  label: const Text('Sửa / Thêm Mẹo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save_rounded, size: 14),
                  label: const Text('Lưu Mẹo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (!_isEditing) ...[

          if (widget.machine.quickTroubleshooting.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Chưa có mẹo xử lý lỗi nào trong cẩm nang.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ...widget.machine.quickTroubleshooting.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isOpen = _openIndex == idx;

              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _openIndex = isOpen ? null : idx;
                        });
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFBE123C)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.issue,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFBE123C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isOpen)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hướng khắc phục nhanh:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.solution,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
        ] else ...[

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách bài học kinh nghiệm:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _editList.add(TroubleshootingItem(issue: '', solution: ''));
                  });
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Thêm dòng mẹo mới'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF047857),
                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          ..._editList.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mẹo #${idx + 1}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _editList.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: item.issue,
                    decoration: const InputDecoration(
                      labelText: 'Hiện tượng / Sự cố',
                      hintText: 'VD: Máy kêu to bất thường',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      _editList[idx] = TroubleshootingItem(issue: val, solution: _editList[idx].solution);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: item.solution,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Cách khắc phục nhanh',
                      hintText: 'VD: Siết bu-lông chân máy & tra dầu ISO VG 68.',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 11),
                    onChanged: (val) {
                      _editList[idx] = TroubleshootingItem(issue: _editList[idx].issue, solution: val);
                    },
                  ),
                ],
              ),
            );
          }),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Lưu Cẩm Nang Xử Lý Lỗi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _editList = List.from(widget.machine.quickTroubleshooting);
                  });
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Hủy'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
