import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/models/machine_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../supervisor/features/machine_management/services/machine_service.dart';
import '../features/machine/widgets/machine_detail_modal.dart';

class OperatorQRScannerSheet extends StatefulWidget {
  const OperatorQRScannerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OperatorQRScannerSheet(),
    );
  }

  @override
  State<OperatorQRScannerSheet> createState() => _OperatorQRScannerSheetState();
}

class _OperatorQRScannerSheetState extends State<OperatorQRScannerSheet> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final MachineService _machineService = MachineService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _statusText;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeDetected(String rawCode) async {
    if (_isProcessing) return;

    final trimmedCode = rawCode.trim();
    if (trimmedCode.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'Đang tìm thông tin thiết bị...';
    });

    try {
      MachineModel? machine;

      // 1. Try to fetch directly by ID
      try {
        machine = await _machineService.getMachineById(trimmedCode);
      } catch (_) {
        // 2. Fallback: search in machine list by code or id
        final machines = await _machineService.getMachines();
        for (final m in machines) {
          if (m.id == trimmedCode ||
              m.code.toLowerCase() == trimmedCode.toLowerCase()) {
            machine = m;
            break;
          }
        }
      }

      if (!mounted) return;

      if (machine != null) {
        // Close scanner bottom sheet and show machine details
        Navigator.pop(context);
        MachineDetailModal.show(context, machine);
      } else {
        _showNotFoundDialog(trimmedCode);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi khi tra cứu thiết bị: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = null;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      setState(() {
        _isProcessing = true;
        _statusText = 'Đang đọc mã QR từ ảnh...';
      });

      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        image.path,
      );

      if (capture != null &&
          capture.barcodes.isNotEmpty &&
          capture.barcodes.first.rawValue != null) {
        final code = capture.barcodes.first.rawValue!;
        await _handleBarcodeDetected(code);
      } else {
        if (mounted) {
          _showErrorSnackBar(
            'Không tìm thấy mã QR trong ảnh đã chọn. Vui lòng chọn ảnh khác rõ nét hơn.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Không thể đọc ảnh: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = null;
        });
      }
    }
  }

  void _showNotFoundDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Không tìm thấy', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Không tìm thấy thiết bị nào khớp với mã QR:\n"$code"',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Quét Mã QR Thiết Bị',
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
            const SizedBox(height: 16),

            // Camera Scanner Box
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mobile Scanner View
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (BarcodeCapture capture) {
                        if (capture.barcodes.isNotEmpty) {
                          final barcode = capture.barcodes.first;
                          if (barcode.rawValue != null) {
                            _handleBarcodeDetected(barcode.rawValue!);
                          }
                        }
                      },
                    ),

                    // Viewfinder Scan Box Overlay
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Corner brackets accents
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white, width: 4),
                                  left: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white, width: 4),
                                  right: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white, width: 4),
                                  left: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white, width: 4),
                                  right: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Floating Camera Controls (Flash, Flip)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          // Flash button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isTorchOn
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: _isTorchOn ? Colors.amber : Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                await _scannerController.toggleTorch();
                                setState(() => _isTorchOn = !_isTorchOn);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Camera switch button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.flip_camera_ios_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => _scannerController.switchCamera(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Processing Loading Overlay
                    if (_isProcessing)
                      Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _statusText ?? 'Đang xử lý...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instruction Text
            const Text(
              'Hướng camera vào mã QR trên thân máy hoặc tải ảnh có mã QR từ thư viện',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.mutedForegroundColor,
              ),
            ),

            const SizedBox(height: 16),

            // Pick Image from Gallery Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppTheme.borderColor, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: AppTheme.foregroundColor,
                ),
                onPressed: _isProcessing ? null : _pickImageFromGallery,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                label: const Text(
                  'Tải ảnh QR từ thiết bị',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
