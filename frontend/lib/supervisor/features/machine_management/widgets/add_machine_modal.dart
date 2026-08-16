import 'package:flutter/material.dart';

class AddMachineModal extends StatefulWidget {
  final Function(Map<String, dynamic> newMachine)? onAddMachine;

  const AddMachineModal({super.key, this.onAddMachine});

  static Future<void> show(BuildContext context, {Function(Map<String, dynamic>)? onAddMachine}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: AddMachineModal(onAddMachine: onAddMachine),
      ),
    );
  }

  @override
  State<AddMachineModal> createState() => _AddMachineModalState();
}

class _AddMachineModalState extends State<AddMachineModal> {
  final _codeController = TextEditingController(text: 'MC-103');
  final _categoryController = TextEditingController(text: 'Gia Công CNC');
  final _nameController = TextEditingController(text: 'Máy Phay CNC Haas 3 Trục');
  final _locationController = TextEditingController(text: 'Phân Xưởng 1 - Dây chuyền C');
  
  String _trackingUnit = 'HOURS'; // HOURS, KM, DAYS
  final _initialHoursController = TextEditingController(text: '0');
  final _recurringIntervalController = TextEditingController(text: '500');

  List<int> _initialThresholds = [500, 1000];

  final List<Map<String, String>> _quickTroubleshooting = [];

  @override
  void dispose() {
    _codeController.dispose();
    _categoryController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _initialHoursController.dispose();
    _recurringIntervalController.dispose();
    super.dispose();
  }

  String get _unitSymbol {
    if (_trackingUnit == 'KM') return 'km';
    if (_trackingUnit == 'DAYS') return 'ngày';
    return 'h';
  }

  void _handleAddThreshold() {
    setState(() {
      final lastVal = _initialThresholds.isNotEmpty ? _initialThresholds.last : 0;
      final interval = int.tryParse(_recurringIntervalController.text) ?? 500;
      _initialThresholds.add(lastVal + interval);
    });
  }

  void _handleRemoveThreshold(int index) {
    if (_initialThresholds.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phải giữ ít nhất 1 mốc bảo trì ban đầu!')),
      );
      return;
    }
    setState(() {
      _initialThresholds.removeAt(index);
    });
  }

  void _handleAddTrouble() {
    setState(() {
      _quickTroubleshooting.add({'issue': '', 'solution': ''});
    });
  }

  void _handleRemoveTrouble(int index) {
    setState(() {
      _quickTroubleshooting.removeAt(index);
    });
  }

  void _handleSubmit() {
    if (_codeController.text.trim().isEmpty || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ Mã máy và Tên máy!')),
      );
      return;
    }

    final newMachine = {
      'code': _codeController.text.trim().toUpperCase(),
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim(),
      'location': _locationController.text.trim(),
      'trackingUnit': _trackingUnit,
      'runningHours': double.tryParse(_initialHoursController.text) ?? 0,
      'initialThresholds': _initialThresholds,
      'recurringInterval': int.tryParse(_recurringIntervalController.text) ?? 500,
      'quickTroubleshooting': _quickTroubleshooting,
    };

    if (widget.onAddMachine != null) {
      widget.onAddMachine!(newMachine);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã thêm thiết bị mới [${newMachine['code']}] ${newMachine['name']} thành công!'),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =========================================================================
              // 1. HEADER BANNER (DARK GREEN / TEAL)
              // =========================================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF047857), Color(0xFF0D9488)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.memory_rounded, // Cpu icon
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thêm Hồ Sơ Máy Mới',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cấu hình mốc bảo trì & Cẩm nang xử lý lỗi nhanh',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFD1FAE5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // =========================================================================
              // 2. FORM BODY CONTENT
              // =========================================================================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Mã Thiết Bị & Phân Loại
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mã Thiết Bị (Mã QR)',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _codeController,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                decoration: _inputDecoration('VD: MC-103'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Phân Loại Thiết Bị',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _categoryController,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                decoration: _inputDecoration('VD: Gia Công CNC'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Row 2: Tên Máy / Thiết Bị
                    const Text(
                      'Tên Máy / Thiết Bị',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: _inputDecoration('VD: Máy Phay CNC Haas 3 Trục'),
                    ),

                    const SizedBox(height: 12),

                    // Row 3: Vị Trí Lắp Đặt / Phân Xưởng
                    const Text(
                      'Vị Trí Lắp Đặt / Phân Xưởng',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _locationController,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: _inputDecoration('VD: Phân Xưởng 1 - Dây chuyền C'),
                    ),

                    const SizedBox(height: 16),

                    // =========================================================================
                    // 3. ĐƠN VỊ THEO DÕI BẢO TRÌ (SEGMENTED SELECTOR BOX)
                    // =========================================================================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đơn Vị Theo Dõi Bảo Trì:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildUnitPill('Giờ Máy (h)', 'HOURS'),
                              const SizedBox(width: 6),
                              _buildUnitPill('Km Di Chuyển', 'KM'),
                              const SizedBox(width: 6),
                              _buildUnitPill('Ngày Vận Hành', 'DAYS'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================================================================
                    // 4. CẤU HÌNH MỐC BẢO TRÌ LẶP LẠI (MINT GREEN CONTAINER BOX)
                    // =========================================================================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4), // emerald-50
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA7F3D0)), // emerald-200
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF047857)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Cấu Hình Mốc Bảo Trì Lặp Lại:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                                  ),
                                ],
                              ),
                              Text(
                                'ĐƠN VỊ: ${_unitSymbol.toUpperCase()}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Initial hours & recurring interval row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Chỉ Số Ban Đầu Hiện Tại', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _initialHoursController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      decoration: _inputDecoration('0'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Chu Kỳ Lặp Lại Sau Đó', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _recurringIntervalController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      decoration: _inputDecoration('500').copyWith(
                                        suffixText: _unitSymbol,
                                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Add milestone header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Các Mốc Chạy Rà Ban Đầu:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                              InkWell(
                                onTap: _handleAddThreshold,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add_rounded, size: 14, color: Color(0xFF047857)),
                                      SizedBox(width: 4),
                                      Text('Thêm mốc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Milestone list items
                          ..._initialThresholds.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final val = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Text('Lần ${idx + 1}:', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: val.toString(),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      onChanged: (v) {
                                        final num = int.tryParse(v) ?? val;
                                        _initialThresholds[idx] = num;
                                      },
                                      decoration: _inputDecoration('').copyWith(
                                        suffixText: _unitSymbol,
                                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                    onPressed: () => _handleRemoveThreshold(idx),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 10),

                          // Tip Alert Box
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF047857), height: 1.4),
                                      children: [
                                        const TextSpan(text: 'Lịch nhắc tự động: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const TextSpan(text: 'Máy sẽ được báo bảo trì ở các mốc '),
                                        TextSpan(text: '${_initialThresholds.join("$_unitSymbol, ")}$_unitSymbol', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                        TextSpan(text: ' và sau đó cứ mỗi ${_recurringIntervalController.text}$_unitSymbol lại nhắc 1 lần.'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================================================================
                    // 5. CẨM NANG XỬ LÝ LỖI NHANH (QUICK TROUBLESHOOTING)
                    // =========================================================================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB), // amber-50
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.build_rounded, size: 16, color: Color(0xFFD97706)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Cẩm Nang Xử Lý Lỗi Nhanh:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: _handleAddTrouble,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add_rounded, size: 13, color: Color(0xFFD97706)),
                                      SizedBox(width: 3),
                                      Text('Thêm lỗi', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          ..._quickTroubleshooting.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: item['issue'],
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                          onChanged: (v) => _quickTroubleshooting[idx]['issue'] = v,
                                          decoration: _inputDecoration('Hiện tượng / Tên lỗi'),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 18),
                                        onPressed: () => _handleRemoveTrouble(idx),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    initialValue: item['solution'],
                                    style: const TextStyle(fontSize: 11.5),
                                    onChanged: (v) => _quickTroubleshooting[idx]['solution'] = v,
                                    decoration: _inputDecoration('Hướng xử lý khắc phục'),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================================================================
                    // 6. ACTION BUTTONS (SUBMIT & CANCEL)
                    // =========================================================================
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF047857),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _handleSubmit,
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                            label: const Text(
                              'Tạo Hồ Sơ Máy Mới',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitPill(String label, String unitKey) {
    final isActive = _trackingUnit == unitKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _trackingUnit = unitKey),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF059669) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
      ),
    );
  }
}
