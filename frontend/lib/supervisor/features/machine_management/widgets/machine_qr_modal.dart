import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/machine_service.dart';

class MachineQrModal extends StatefulWidget {
  final MachineModel machine;

  const MachineQrModal({super.key, required this.machine});

  static Future<void> show(BuildContext context, MachineModel machine) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MachineQrModal(machine: machine),
    );
  }

  @override
  State<MachineQrModal> createState() => _MachineQrModalState();
}

class _MachineQrModalState extends State<MachineQrModal> {
  final MachineService _machineService = MachineService();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSharing = false;
  String? _errorMessage;
  Uint8List? _qrImageBytes;

  @override
  void initState() {
    super.initState();
    _fetchQrCode();
  }

  Future<void> _fetchQrCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _machineService.getMachineQrCode(widget.machine.id);
      final qrDataUrl = res['qrCode'] as String?;
      if (qrDataUrl != null && qrDataUrl.contains(',')) {
        final base64Str = qrDataUrl.split(',')[1];
        if (mounted) {
          setState(() {
            _qrImageBytes = base64Decode(base64Str);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Dữ liệu QR code không đúng định dạng');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _downloadQrCode() async {
    if (_qrImageBytes == null) return;

    setState(() => _isSaving = true);

    try {
      final rawCode = widget.machine.code.isNotEmpty
          ? widget.machine.code
          : widget.machine.id;
      final fileName = 'QR_${rawCode.replaceAll(RegExp(r'[^\w\-]'), '_')}';

      if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
        final downloadsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        final filePath = '${downloadsDir.path}/$fileName.png';
        final file = File(filePath);
        await file.writeAsBytes(_qrImageBytes!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đã lưu file QR vào thư mục Downloads của máy tính ($fileName.png)!',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (!kIsWeb && Platform.isAndroid) {

        bool savedToFiles = false;
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final file = File('${downloadDir.path}/$fileName.png');
            await file.writeAsBytes(_qrImageBytes!);
            savedToFiles = true;
          }
        } catch (_) {}

        try {
          final hasAccess = await Gal.hasAccess();
          if (!hasAccess) {
            await Gal.requestAccess();
          }
          await Gal.putImageBytes(_qrImageBytes!, name: fileName);
        } catch (e) {
          if (!savedToFiles) rethrow;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đã lưu mã QR ($fileName.png) vào Thư viện ảnh / Tải về!',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {

        await Gal.putImageBytes(
          _qrImageBytes!,
          name: fileName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đã lưu mã QR ($fileName) vào thư viện ảnh!',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } on GalException catch (e) {
      String msg = 'Không thể lưu mã QR vào thư viện.';
      if (e.type == GalExceptionType.accessDenied) {
        msg = 'Vui lòng cấp quyền truy cập Thư viện ảnh để tải xuống.';
      } else if (e.type == GalExceptionType.notEnoughSpace) {
        msg = 'Bộ nhớ thiết bị không đủ dung lượng.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu ảnh: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareQrCode() async {
    if (_qrImageBytes == null) return;

    setState(() => _isSharing = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final rawCode = widget.machine.code.isNotEmpty
          ? widget.machine.code
          : widget.machine.id;
      final safeName = rawCode.replaceAll(RegExp(r'[^\w\-]'), '_');
      final file = File('${tempDir.path}/QR_$safeName.png');
      await file.writeAsBytes(_qrImageBytes!);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'Mã QR thiết bị: ${widget.machine.name} ($rawCode)',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chia sẻ: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.qr_code_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mã QR Thiết Bị',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.foregroundColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppTheme.borderColor),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
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
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      widget.machine.code.isNotEmpty
                          ? widget.machine.code
                          : 'N/A',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.machine.name.isNotEmpty
                              ? widget.machine.name
                              : 'Thiết bị',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.foregroundColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${widget.machine.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutedForegroundColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              Container(
                height: 220,
                width: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 12),
                    Text(
                      'Đang tạo mã QR...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.mutedForegroundColor,
                      ),
                    ),
                  ],
                ),
              )
            else if (_errorMessage != null)
              Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppTheme.errorColor,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _fetchQrCode,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
            else if (_qrImageBytes != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.memory(
                  _qrImageBytes!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),

            const SizedBox(height: 16),

            const Text(
              'Mã QR chứa ID thiết bị dùng để in/dán lên máy móc. Nhân viên vận hành có thể quét mã này để kiểm tra nhanh thông số và thực hiện checklist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.mutedForegroundColor,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            if (_qrImageBytes != null) ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSaving ? null : _downloadQrCode,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.file_download_outlined, size: 20),
                      label: Text(
                        _isSaving ? 'Đang lưu...' : 'Tải mã QR',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: AppTheme.foregroundColor,
                        side: const BorderSide(color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSharing ? null : _shareQrCode,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : const Icon(Icons.share_outlined, size: 18),
                      label: Text(
                        _isSharing ? '...' : 'Chia sẻ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  foregroundColor: AppTheme.mutedForegroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Đóng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
