import 'package:flutter/material.dart';
import '../../../../core/widgets/signature_pad_widget.dart';
import '../models/supervisor_approval_model.dart';

class SupervisorDigitalSignoffModal extends StatefulWidget {
  final SupervisorApprovalModel item;
  final Function(String signatureData) onConfirmSign;
  final Function(String reason)? onReject;

  const SupervisorDigitalSignoffModal({
    super.key,
    required this.item,
    required this.onConfirmSign,
    this.onReject,
  });

  static Future<void> show(
    BuildContext context, {
    required SupervisorApprovalModel item,
    required Function(String signatureData) onConfirmSign,
    Function(String reason)? onReject,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SupervisorDigitalSignoffModal(
          item: item,
          onConfirmSign: onConfirmSign,
          onReject: onReject,
        ),
      ),
    );
  }

  @override
  State<SupervisorDigitalSignoffModal> createState() =>
      _SupervisorDigitalSignoffModalState();
}

class _SupervisorDigitalSignoffModalState
    extends State<SupervisorDigitalSignoffModal> {
  final GlobalKey<SignaturePadWidgetState> _signatureKey = GlobalKey();
  final TextEditingController _rejectionController = TextEditingController();
  bool _hasSigned = false;
  bool _showRejectForm = false;

  @override
  void dispose() {
    _rejectionController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (!_hasSigned) return;
    // Export signature drawing
    final image = await _signatureKey.currentState?.exportImage();
    final signatureDataStr =
        image != null ? 'data:image/png;base64,sample_signature_png' : 'signed';
    widget.onConfirmSign(signatureDataStr);
    if (mounted) Navigator.pop(context);
  }

  void _handleConfirmReject() {
    final reason = _rejectionController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập lý do từ chối nghiệm thu!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    widget.onReject?.call(reason);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5), // emerald-50
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF059669),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Mã phiếu: ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              widget.item.code,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: _showRejectForm ? _buildRejectionForm() : _buildSignoffView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignoffView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Work Summary Card (Wireframe 5.E / US-08)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.build_circle_outlined,
                          size: 16, color: Color(0xFF065F46)),
                      SizedBox(width: 6),
                      Text(
                        'TÓM TẮT CÔNG VIỆC SỬA CHỮA / BẢO TRÌ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Wireframe 5.E',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Machine & Engineer details grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thiết bị:',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                        Text(
                          '${widget.item.machineName} (${widget.item.machineCode})',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kỹ sư thực hiện:',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                        Text(
                          widget.item.engineerName,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Downtime Duration Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB), // amber-50
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 15, color: Color(0xFFD97706)),
                        SizedBox(width: 4),
                        Text(
                          'Thời gian dừng máy (Downtime):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.item.downtimeDuration,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Used Spare Parts List
              const Text(
                'Vật tư & Phụ tùng đã thay thế:',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),

              if (widget.item.usedSpareParts.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    '• Không thay thế linh kiện mới (Căn chỉnh kỹ thuật)',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ),
              ] else ...[
                Column(
                  children: widget.item.usedSpareParts.map((sp) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '• ${sp.name}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${sp.quantity} ${sp.unit}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Instruction Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF), // sky-50
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: const Row(
            children: [
              Icon(Icons.border_color_rounded, size: 16, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ký tên cảm ứng trực tiếp vào ô bên dưới để xác nhận bàn giao máy',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Signature Canvas Pad
        SignaturePadWidget(
          key: _signatureKey,
          height: 160,
          onSignatureChanged: (hasSigned) {
            if (_hasSigned != hasSigned) {
              setState(() {
                _hasSigned = hasSigned;
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Footer Action Buttons
        Row(
          children: [
            // Reject Button (Red)
            if (widget.onReject != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626), // red-600
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showRejectForm = true;
                  });
                },
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text(
                  'Từ Chối',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),

            if (widget.onReject != null) const SizedBox(width: 8),

            // Cancel Button
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy bỏ'),
              ),
            ),

            const SizedBox(width: 8),

            // Confirm Approval Button (Emerald Green)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669), // emerald-600
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _hasSigned ? _handleConfirm : null,
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text(
                  'Xác Nhận',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRejectionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2), // rose-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 20, color: Color(0xFFE11D48)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Phiếu sẽ chuyển về trạng thái REJECTED để kỹ sư ME tiếp tục sửa chữa.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9F1239),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Lý do từ chối nghiệm thu:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),

        TextField(
          controller: _rejectionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Ví dụ: Máy vẫn còn tiếng rít lạch cạch, cụm van thủy lực chưa siết chặt...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showRejectForm = false;
                  });
                },
                child: const Text('Quay Lại'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleConfirmReject,
                icon: const Icon(Icons.cancel_rounded, size: 18),
                label: const Text(
                  'Xác Nhận Từ Chối',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
