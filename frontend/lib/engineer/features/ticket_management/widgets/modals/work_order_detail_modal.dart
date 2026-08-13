import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../models/ticket_model.dart';

class WorkOrderDetailModal extends StatefulWidget {
  final TicketModel ticket;
  final VoidCallback onClaim;
  final ValueChanged<List<SparePartItem>> onComplete;

  const WorkOrderDetailModal({
    super.key,
    required this.ticket,
    required this.onClaim,
    required this.onComplete,
  });

  static Future<void> show(
    BuildContext context, {
    required TicketModel ticket,
    required VoidCallback onClaim,
    required ValueChanged<List<SparePartItem>> onComplete,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'WorkOrderDetailModal',
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: WorkOrderDetailModal(
            ticket: ticket,
            onClaim: onClaim,
            onComplete: onComplete,
          ),
        ),
      ),
    );
  }

  @override
  State<WorkOrderDetailModal> createState() => _WorkOrderDetailModalState();
}

class _WorkOrderDetailModalState extends State<WorkOrderDetailModal> {
  final List<SparePartItem> _usedParts = [];
  final TextEditingController _partNameController = TextEditingController();
  final TextEditingController _partQtyController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _usedParts.addAll(widget.ticket.usedSpareParts);
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _partQtyController.dispose();
    super.dispose();
  }

  void _addSparePart() {
    final name = _partNameController.text.trim();
    final qty = int.tryParse(_partQtyController.text.trim()) ?? 1;
    if (name.isEmpty) return;

    setState(() {
      _usedParts.add(
        SparePartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          code: 'PART-${_usedParts.length + 1}',
          name: name,
          quantity: qty,
        ),
      );
      _partNameController.clear();
      _partQtyController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

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
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
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
                          ticket.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: Color(0xFFBE123C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket.machineCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket.machineName,
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

          // Content body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mô tả sự cố khẩn cấp:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      ticket.description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Spare Parts Section
                  const Text(
                    'Linh kiện / Vật tư đã sử dụng:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),

                  if (_usedParts.isEmpty)
                    const Text('Chưa ghi nhận vật tư thay thế nào', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
                  else
                    Column(
                      children: _usedParts.map((part) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(part.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('x${part.quantity} ${part.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 10),

                  // Add Spare Part form
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _partNameController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Tên vật tư thay mới...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _partQtyController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'SL',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _addSparePart,
                        child: const Text('Thêm', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                if (ticket.status == TicketStatus.open)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onClaim();
                      },
                      icon: const Icon(Icons.build_rounded, size: 18),
                      label: const Text('Tiếp Nhận Sửa Chữa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  )
                else if (ticket.status == TicketStatus.inProgress || ticket.status == TicketStatus.rejected)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onComplete(_usedParts);
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Hoàn Thành & Gửi Nghiệm Thu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
