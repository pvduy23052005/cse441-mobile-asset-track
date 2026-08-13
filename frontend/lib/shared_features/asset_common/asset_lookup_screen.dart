import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../../engineer/features/machines/models/machine_model.dart';
import '../../engineer/features/machines/services/engineer_machine_service.dart';
import '../../engineer/features/machines/widgets/modals/machine_passport_modal.dart';

class AssetLookupScreen extends StatefulWidget {
  const AssetLookupScreen({super.key});

  @override
  State<AssetLookupScreen> createState() => _AssetLookupScreenState();
}

class _AssetLookupScreenState extends State<AssetLookupScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final ImagePicker _imagePicker = ImagePicker();
  final EngineerMachineService _machineService = EngineerMachineService();

  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  List<MachineModel> _machines = [];
  bool _isLoadingMachines = true;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _hasCameraError = false;
  String? _statusText;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    _loadMachinesFromApi();
  }

  Future<void> _loadMachinesFromApi() async {
    setState(() => _isLoadingMachines = true);
    try {
      final list = await _machineService.fetchMachinesFromApi();
      if (mounted) {
        setState(() {
          _machines = list;
          _isLoadingMachines = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMachines = false);
      }
    }
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  String _extractMachineCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final data = jsonDecode(trimmed);
        if (data is Map) {
          return (data['code'] ?? data['id'] ?? data['machineId'] ?? trimmed).toString().trim();
        }
      } catch (_) {}
    }
    return trimmed;
  }

  Future<void> _handleDecodedCode(String rawCode) async {
    if (_isProcessing) return;

    final targetCode = _extractMachineCode(rawCode);
    if (targetCode.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'Đang tìm thông tin máy: $targetCode...';
    });

    try {
      try {
        await _scannerController.stop();
      } catch (_) {}

      MachineModel? found;
      for (final m in _machines) {
        if (m.code.toLowerCase() == targetCode.toLowerCase() ||
            m.id.toLowerCase() == targetCode.toLowerCase()) {
          found = m;
          break;
        }
      }

      if (mounted) {
        if (found != null) {
          _openMachinePassport(found);
        } else {
          _showNotFoundDialog(targetCode);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tra cứu thiết bị: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
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
            Text('Không tìm thấy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Không tìm thấy thiết bị nào trong hệ thống khớp với mã QR:\n"$code"',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              try {
                _scannerController.start();
              } catch (_) {}
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _openMachinePassport(MachineModel machine) {
    MachinePassportModal.show(
      context,
      machine: machine,
      onSaveTroubleshooting: (updatedList) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật cẩm nang lỗi cho ${machine.code}!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
        _statusText = 'Đang đọc mã QR từ ảnh...';
      });

      final capture = await _scannerController.analyzeImage(image.path);
      final barcodes = capture?.barcodes ?? [];
      String? foundCode;
      for (final b in barcodes) {
        final val = b.rawValue ?? b.displayValue;
        if (val != null && val.trim().isNotEmpty) {
          foundCode = val.trim();
          break;
        }
      }

      if (foundCode != null) {
        _isProcessing = false;
        await _handleDecodedCode(foundCode);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy mã QR trong ảnh đã chọn.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể đọc ảnh: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB30F172A), // bg-slate-900/70 backdrop overlay
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                border: Border.all(color: const Color(0xFFE2E8F0)), // border-slate-200
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Camera Header (px-5 py-4 border-b border-slate-100 bg-white)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.qr_code_rounded,
                                color: Color(0xFF059669), // text-emerald-600
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Quét Mã QR thông tin máy',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900, // font-extrabold
                                  color: Color(0xFF0F172A), // text-slate-900
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Flash Button (Zap icon)
                              InkWell(
                                onTap: () async {
                                  await _scannerController.toggleTorch();
                                  setState(() => _isTorchOn = !_isTorchOn);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _isTorchOn
                                        ? const Color(0xFFFACC15) // bg-amber-400
                                        : const Color(0xFFF1F5F9), // bg-slate-100
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    size: 16,
                                    color: _isTorchOn
                                        ? const Color(0xFF020617)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Close Button (X icon)
                              InkWell(
                                onTap: () => Navigator.maybePop(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 2. Viewfinder Camera Box (h-64 bg-slate-900 = 256px)
                    SizedBox(
                      height: 256,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: MobileScanner(
                              controller: _scannerController,
                              errorBuilder: (context, error) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (!_hasCameraError && mounted) {
                                    setState(() => _hasCameraError = true);
                                  }
                                });
                                return Container(
                                  color: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.all(16),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.videocam_off_rounded,
                                          color: Color(0xFFF59E0B),
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Chưa cấp quyền Camera',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Vui lòng chọn ảnh từ thư viện hoặc chọn máy ở danh sách bên dưới',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              onDetect: (capture) {
                                if (capture.barcodes.isNotEmpty) {
                                  final barcode = capture.barcodes.first;
                                  if (barcode.rawValue != null) {
                                    _handleDecodedCode(barcode.rawValue!);
                                  }
                                }
                              },
                            ),
                          ),

                          if (_isTorchOn)
                            Positioned.fill(
                              child: Container(
                                color: const Color(0xFFFACC15).withValues(alpha: 0.18),
                              ),
                            ),

                          // Reticle Box (w-48 h-48 border-2 border-emerald-400/60 rounded-xl = 192px)
                          Container(
                            width: 192,
                            height: 192,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF34D399).withValues(alpha: 0.6),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                _buildCornerBracket(Alignment.topLeft, top: true, left: true),
                                _buildCornerBracket(Alignment.topRight, top: true, left: false),
                                _buildCornerBracket(Alignment.bottomLeft, top: false, left: true),
                                _buildCornerBracket(Alignment.bottomRight, top: false, left: false),

                                AnimatedBuilder(
                                  animation: _laserAnimation,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 192 * _laserAnimation.value,
                                      left: 8,
                                      right: 8,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Color(0xFF34D399),
                                              Color(0xFF10B981),
                                              Color(0xFF34D399),
                                              Colors.transparent,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF34D399).withValues(alpha: 0.9),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                if (!_hasCameraError)
                                  const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          color: Color(0xFF34D399),
                                          size: 32,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Căn mã QR dán trên thân máy',
                                          style: TextStyle(
                                            color: Color(0xFFCBD5E1),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (_isProcessing)
                            Positioned.fill(
                              child: Container(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(color: Color(0xFF10B981)),
                                      const SizedBox(height: 14),
                                      Text(
                                        _statusText ?? 'Đang xử lý...',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 3. Simulator Selection Bar (p-4 bg-slate-50 border-t border-slate-100)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC), // bg-slate-50
                        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gallery Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isProcessing ? null : _pickImageFromGallery,
                              icon: const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF059669)),
                              label: const Text(
                                'Tải ảnh QR từ thư viện',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Header danh sách thiết bị
                          const Row(
                            children: [
                              Icon(Icons.precision_manufacturing_rounded, size: 15, color: Color(0xFF059669)),
                              SizedBox(width: 6),
                              Text(
                                'Danh sách thiết bị máy móc:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Simulator Machine List (space-y-2)
                          if (_isLoadingMachines)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(color: AppTheme.primaryColor),
                              ),
                            )
                          else if (_machines.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Text(
                                'Hiện chưa có thiết bị nào trong CSDL Backend API.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 180),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _machines.map((machine) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: InkWell(
                                        onTap: () => _openMachinePassport(machine),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x05000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
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
                                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFD1FAE5), // bg-emerald-100
                                                            borderRadius: BorderRadius.circular(4),
                                                            border: Border.all(color: const Color(0xFFA7F3D0)),
                                                          ),
                                                          child: Text(
                                                            machine.code,
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w900,
                                                              fontFamily: 'monospace',
                                                              color: Color(0xFF065F46),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            machine.name,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF0F172A),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      machine.location,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 16,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerBracket(Alignment alignment, {required bool top, required bool left}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: Color(0xFF34D399), width: 4) : BorderSide.none,
            bottom: !top ? const BorderSide(color: Color(0xFF34D399), width: 4) : BorderSide.none,
            left: left ? const BorderSide(color: Color(0xFF34D399), width: 4) : BorderSide.none,
            right: !left ? const BorderSide(color: Color(0xFF34D399), width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
