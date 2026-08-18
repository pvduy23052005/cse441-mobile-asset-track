import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../models/work_order_model.dart';
import '../../repositories/pm_checklist_repository.dart';
import 'pm_checklist_item_tile.dart';
import 'pm_spare_parts_form.dart';

class PMChecklistItemData {
  final String id;
  final String taskDescription;
  bool isChecked;
  final bool isRequiredPhoto;
  String? photoUrl;

  PMChecklistItemData({
    required this.id,
    required this.taskDescription,
    this.isChecked = false,
    this.isRequiredPhoto = false,
    this.photoUrl,
  });
}

class PMSparePartData {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalCost;
  final bool requiresApproval;

  PMSparePartData({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalCost,
    required this.requiresApproval,
  });
}

class PMChecklistModal extends StatefulWidget {
  final PMChecklistModel checklist;
  final VoidCallback onClose;
  final VoidCallback onComplete;

  const PMChecklistModal({
    super.key,
    required this.checklist,
    required this.onClose,
    required this.onComplete,
  });

  @override
  State<PMChecklistModal> createState() => _PMChecklistModalState();
}

class _PMChecklistModalState extends State<PMChecklistModal> {
  final PMChecklistRepository _repository = PMChecklistRepository();
  late List<PMChecklistItemData> _items;
  final List<PMSparePartData> _spareParts = [];
  bool _isSubmitting = false;

  final _partNameController = TextEditingController();
  final _partQtyController = TextEditingController(text: '1');
  final _partPriceController = TextEditingController(text: '500000');

  final double _costApprovalThreshold = 2000000.0;

  @override
  void initState() {
    super.initState();
    _items = [
      PMChecklistItemData(
        id: 'pmi-1',
        taskDescription: 'Thay dầu bôi trơn động cơ ép chính và xả cặn đáy',
        isChecked: false,
        isRequiredPhoto: true,
      ),
      PMChecklistItemData(
        id: 'pmi-2',
        taskDescription: 'Kiểm tra áp suất khí nén đầu vào và điều chỉnh van an toàn',
        isChecked: false,
        isRequiredPhoto: false,
      ),
      PMChecklistItemData(
        id: 'pmi-3',
        taskDescription: 'Siết chặt bu-lông chân máy và kiểm tra độ chùng dây curoa',
        isChecked: false,
        isRequiredPhoto: true,
      ),
    ];
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final saved = await _repository.getPMStateLocally(widget.checklist.id);
    if (saved != null && mounted) {
      final savedItems = saved['items'] as List<dynamic>?;
      final savedParts = saved['spareParts'] as List<dynamic>?;

      setState(() {
        if (savedItems != null) {
          for (final item in _items) {
            final match = savedItems.firstWhere(
              (s) => s['id'] == item.id,
              orElse: () => null,
            );
            if (match != null) {
              item.isChecked = match['isChecked'] == true;
              item.photoUrl = match['photoUrl']?.toString();
            }
          }
        }

        if (savedParts != null) {
          _spareParts.clear();
          for (final sp in savedParts) {
            _spareParts.add(
              PMSparePartData(
                id: sp['id']?.toString() ?? '',
                name: sp['name']?.toString() ?? '',
                quantity: (sp['quantity'] as num?)?.toInt() ?? 1,
                unitPrice: (sp['unitPrice'] as num?)?.toDouble() ?? 0.0,
                totalCost: (sp['totalCost'] as num?)?.toDouble() ?? 0.0,
                requiresApproval: sp['requiresApproval'] == true,
              ),
            );
          }
        }
      });
    }
  }

  Future<void> _saveCurrentStateLocally() async {
    final itemsJson = _items
        .map((it) => {
              'id': it.id,
              'taskDescription': it.taskDescription,
              'isChecked': it.isChecked,
              'isRequiredPhoto': it.isRequiredPhoto,
              'photoUrl': it.photoUrl,
            })
        .toList();

    final partsJson = _spareParts
        .map((sp) => {
              'id': sp.id,
              'name': sp.name,
              'quantity': sp.quantity,
              'unitPrice': sp.unitPrice,
              'totalCost': sp.totalCost,
              'requiresApproval': sp.requiresApproval,
            })
        .toList();

    await _repository.savePMStateLocally(
      checklistId: widget.checklist.id,
      items: itemsJson,
      spareParts: partsJson,
    );
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _partQtyController.dispose();
    _partPriceController.dispose();
    super.dispose();
  }

  void _handleAddSparePart() {
    final name = _partNameController.text.trim();
    if (name.isEmpty) return;

    final qty = int.tryParse(_partQtyController.text) ?? 1;
    final priceStr = _partPriceController.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    final price = double.tryParse(priceStr) ?? 0.0;
    final total = qty * price;
    final requiresAppr = total >= _costApprovalThreshold;

    setState(() {
      _spareParts.add(
        PMSparePartData(
          id: 'sp-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          quantity: qty,
          unitPrice: price,
          totalCost: total,
          requiresApproval: requiresAppr,
        ),
      );
      _partNameController.clear();
      _partQtyController.text = '1';
      _partPriceController.text = '500000';
    });
    _saveCurrentStateLocally();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final itemsJson = _items
        .map((it) => {
              'id': it.id,
              'taskDescription': it.taskDescription,
              'isChecked': it.isChecked,
              'isRequiredPhoto': it.isRequiredPhoto,
              'photoUrl': it.photoUrl,
            })
        .toList();

    final partsJson = _spareParts
        .map((sp) => {
              'id': sp.id,
              'name': sp.name,
              'quantity': sp.quantity,
              'unitPrice': sp.unitPrice,
              'totalCost': sp.totalCost,
              'requiresApproval': sp.requiresApproval,
            })
        .toList();

    await _repository.submitPMChecklist(
      checklistId: widget.checklist.id,
      items: itemsJson,
      spareParts: partsJson,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onComplete();
    }
  }

  bool get _allMandatoryCompleted {
    return _items.every(
      (it) => (!it.isRequiredPhoto || (it.isRequiredPhoto && it.photoUrl != null)) && it.isChecked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 620),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                widget.checklist.code,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mốc ${widget.checklist.scheduledHours}h',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.checklist.machineName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.build_rounded, size: 16, color: Color(0xFF059669)),
                        SizedBox(width: 6),
                        Text(
                          'DANH SÁCH KIỂM TRA BẮT BUỘC (CHECKLIST):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF475569),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ..._items.map(
                      (item) => PMChecklistItemTile(
                        item: item,
                        onChanged: (val) {
                          setState(() {
                            item.isChecked = val ?? false;
                          });
                          _saveCurrentStateLocally();
                        },
                        onSimulatePhoto: () {
                          setState(() {
                            item.photoUrl =
                                'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=500';
                          });
                          _saveCurrentStateLocally();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    PMSparePartsForm(
                      nameController: _partNameController,
                      qtyController: _partQtyController,
                      priceController: _partPriceController,
                      spareParts: _spareParts,
                      onAddSparePart: _handleAddSparePart,
                    ),
                  ],
                ),
              ),
            ),

            // Footer Action
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: (_allMandatoryCompleted && !_isSubmitting)
                      ? _handleSubmit
                      : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    _isSubmitting
                        ? 'Đang Gửi Nghiệm Thu...'
                        : 'Hoàn Thành PM & Gửi Nghiệm Thu',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
