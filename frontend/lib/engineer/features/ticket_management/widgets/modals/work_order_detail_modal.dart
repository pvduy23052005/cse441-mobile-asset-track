import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';

class WorkOrderDetailModal extends StatefulWidget {
  final TicketModel ticket;
  final VoidCallback onClaim;
  final ValueChanged<List<SparePartItem>> onComplete;
  final ValueChanged<String>? onCancel;

  const WorkOrderDetailModal({
    super.key,
    required this.ticket,
    required this.onClaim,
    required this.onComplete,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required TicketModel ticket,
    required VoidCallback onClaim,
    required ValueChanged<List<SparePartItem>> onComplete,
    ValueChanged<String>? onCancel,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'WorkOrderDetailModal',
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: WorkOrderDetailModal(
            ticket: ticket,
            onClaim: onClaim,
            onComplete: onComplete,
            onCancel: onCancel,
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
  final TextEditingController _partQtyController = TextEditingController(
    text: '1',
  );
  final TextEditingController _partPriceController = TextEditingController(
    text: '500000',
  );
  final TextEditingController _cancelReasonController = TextEditingController();

  bool _showAddPartForm = false;
  bool _showCancelForm = false;

  @override
  void initState() {
    super.initState();
    // Lấy 100% dữ liệu linh kiện thật từ phiếu Backend API
    _usedParts.addAll(widget.ticket.usedSpareParts);
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _partQtyController.dispose();
    _partPriceController.dispose();
    _cancelReasonController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final int val = amount.toInt();
    final String str = val.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} VNĐ';
  }

  void _addSparePart() {
    final name = _partNameController.text.trim();
    final qty = int.tryParse(_partQtyController.text.trim()) ?? 1;
    final priceStr = _partPriceController.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    final price = double.tryParse(priceStr) ?? 500000;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên phụ tùng / linh kiện!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _usedParts.add(
        SparePartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          code: 'PART-${_usedParts.length + 1}',
          name: name,
          quantity: qty,
          unitPrice: price,
        ),
      );
      _partNameController.clear();
      _partQtyController.text = '1';
      _partPriceController.text = '500000';
      _showAddPartForm = false;
    });
  }

  void _removeSparePart(int index) {
    setState(() {
      _usedParts.removeAt(index);
    });
  }

  Widget _buildSeverityBadge(TicketSeverity severity) {
    String label = 'MEDIUM';
    Color bg = const Color(0xFFFEF3C7);
    Color border = const Color(0xFFFDE68A);
    Color text = const Color(0xFF92400E);
    Color dotColor = const Color(0xFFF59E0B);

    if (severity == TicketSeverity.critical) {
      label = 'CRITICAL';
      bg = const Color(0xFFFFE4E6);
      border = const Color(0xFFFECDD3);
      text = const Color(0xFFBE123C);
      dotColor = const Color(0xFFE11D48);
    } else if (severity == TicketSeverity.high) {
      label = 'HIGH';
      bg = const Color(0xFFFEF3C7);
      border = const Color(0xFFFDE68A);
      text = const Color(0xFF92400E);
      dotColor = const Color(0xFFF59E0B);
    } else if (severity == TicketSeverity.low) {
      label = 'LOW';
      bg = const Color(0xFFD1FAE5);
      border = const Color(0xFFA7F3D0);
      text = const Color(0xFF065F46);
      dotColor = const Color(0xFF10B981);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: text,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE7F3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFBCFE8),
                              ),
                            ),
                            child: Text(
                              ticket.code,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: Color(0xFF9D174D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSeverityBadge(ticket.severity),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Chi Tiết Phiếu Báo Lỗi SOS',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Body Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card (THIẾT BỊ SỰ CỐ)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'THIẾT BỊ SỰ CỐ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      ticket.machineName,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ticket.machineCode,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Báo bởi: ',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            ticket.reporterName ??
                                            'Không xác định',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thời gian:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    ticket.createdAt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          if (ticket.engineerName != null &&
                              ticket.engineerName!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFEFF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFA5F3FC),
                                ),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Kỹ sư tiếp nhận: ',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0891B2),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ticket.engineerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0891B2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // MÔ TẢ CHI TIẾT SỰ CỐ
                    const Text(
                      'MÔ TẢ CHI TIẾT SỰ CỐ:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        ticket.description,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF334155),
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // ẢNH MINH CHỨNG LỖI HIỆN TRƯỜNG (Chỉ hiển thị nếu từ API thật có ảnh)
                    if (ticket.imageUrl != null &&
                        ticket.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'ẢNH MINH CHỨNG LỖI HIỆN TRƯỜNG:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          ticket.imageUrl!,
                          height: 175,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // LINH KIỆN ĐÃ KHAI BÁO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'LINH KIỆN ĐÃ KHAI BÁO:',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (ticket.status != TicketStatus.closed &&
                            ticket.status != TicketStatus.cancelled)
                          InkWell(
                            onTap: () => setState(
                              () => _showAddPartForm = !_showAddPartForm,
                            ),
                            child: const Text(
                              '+ Khai báo thêm phụ tùng',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF008B99),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (_showAddPartForm) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFA5F3FC)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thêm Vật Tư / Phụ Tùng Thay Thế',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _partNameController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText:
                                    'Tên phụ tùng (e.g. Vòng bi Spindle 7014C)',
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 64,
                                  child: TextField(
                                    controller: _partQtyController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: 'SL',
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFCBD5E1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _partPriceController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Đơn giá (VND)',
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFCBD5E1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Duyệt Quản đốc nếu > 2.0Trđ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => setState(
                                        () => _showAddPartForm = false,
                                      ),
                                      child: const Text(
                                        'Hủy',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF008B99,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: _addSparePart,
                                      child: const Text(
                                        'Lưu Vật Tư',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Spare Parts List Cards (Nếu API chưa có linh kiện thì báo chưa khai báo)
                    if (_usedParts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Chưa khai báo linh kiện thay thế cho phiếu này.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF94A3B8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ..._usedParts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final part = entry.value;
                        final bool isApproved =
                            (part.quantity * part.unitPrice) >= 2000000;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      part.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'x${part.quantity} cái  •  ${_formatCurrency(part.quantity * part.unitPrice)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isApproved
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isApproved ? 'Đã Duyệt' : 'Tự Động',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isApproved
                                            ? const Color(0xFF065F46)
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  if (widget.ticket.status != TicketStatus.closed &&
                                      widget.ticket.status != TicketStatus.cancelled) ...[
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: Color(0xFFE11D48),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _removeSparePart(index),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                    if (_showCancelForm) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hủy Phiếu SOS Đã Báo Nhầm (US-13)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _cancelReasonController,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 11.5),
                              decoration: InputDecoration(
                                hintText:
                                    'Nhập lý do hủy phiếu (thao tác nhầm...)',
                                isDense: true,
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () =>
                                        setState(() => _showCancelForm = false),
                                    child: const Text(
                                      'Quay Lại',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE11D48),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      final reason = _cancelReasonController
                                          .text
                                          .trim();
                                      if (reason.isNotEmpty &&
                                          widget.onCancel != null) {
                                        widget.onCancel!(reason);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text(
                                      'Xác Nhận Hủy',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 3. Footer Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Column(
                children: [
                  if (ticket.status == TicketStatus.open &&
                      !_showCancelForm) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0097B2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onClaim();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.build_rounded, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Bấm Tiếp Nhận Sửa Chữa Ngay',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE11D48),
                          side: const BorderSide(color: Color(0xFFFECDD3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => setState(() => _showCancelForm = true),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              size: 16,
                              color: Color(0xFFE11D48),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Hủy Phiếu SOS Báo Nhầm (US-13)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (ticket.status == TicketStatus.inProgress ||
                      ticket.status == TicketStatus.rejected) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF009966),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onComplete(_usedParts);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Hoàn Thành & Gửi Quản Đốc Nghiệm Thu',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (ticket.status == TicketStatus.pendingApproval) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Text(
                        'Đã hoàn thành sửa chữa — Đang chờ Quản đốc ký nghiệm thu!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ] else if (ticket.status == TicketStatus.closed) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        'Đã được Quản đốc ký nghiệm thu & bàn giao về Active!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
