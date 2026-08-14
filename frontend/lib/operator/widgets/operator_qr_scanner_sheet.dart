import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/models/machine_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../supervisor/features/machine_management/services/machine_service.dart';

class OperatorQRScannerSheet extends StatefulWidget {
  const OperatorQRScannerSheet({super.key});

  static Future<MachineModel?> show(BuildContext context) {
    return showModalBottomSheet<MachineModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OperatorQRScannerSheet(),
    );
  }

  @override
  State<OperatorQRScannerSheet> createState() => _OperatorQRScannerSheetState();
}

class _OperatorQRScannerSheetState extends State<OperatorQRScannerSheet>
    with TickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final MachineService _machineService = MachineService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _manualIdController = TextEditingController();

  late TabController _tabController;
  late AnimationController _animController;
  int _selectedTabIndex = 0;

  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _statusText;

  List<MachineModel> _allMachines = [];
  List<MachineModel> _filteredMachines = [];
  bool _isLoadingMachines = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
      if (_tabController.index == 1 && _allMachines.isEmpty) {
        _fetchAllMachines();
      }
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    try {
      _scannerController.dispose();
    } catch (_) {}
    _manualIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllMachines() async {
    setState(() {
      _isLoadingMachines = true;
    });
    try {
      final list = await _machineService.getMachines();
      if (mounted) {
        setState(() {
          _allMachines = list;
          _filteredMachines = list;
          _isLoadingMachines = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMachines = false;
        });
      }
    }
  }

  void _onSearchQueryChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredMachines = _allMachines;
      } else {
        _filteredMachines = _allMachines.where((m) {
          return m.name.toLowerCase().contains(q) ||
              m.code.toLowerCase().contains(q) ||
              m.location.toLowerCase().contains(q) ||
              m.id.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  String _extractMachineId(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final data = jsonDecode(trimmed);
        if (data is Map) {
          return (data['id'] ?? data['machineId'] ?? data['code'] ?? trimmed)
              .toString()
              .trim();
        }
      } catch (_) {}
    }
    if (trimmed.contains('/')) {
      final segments = Uri.tryParse(trimmed)?.pathSegments;
      if (segments != null && segments.isNotEmpty) {
        return segments.last.trim();
      }
    }
    return trimmed;
  }

  Future<void> _handleBarcodeDetected(String rawCode) async {
    if (_isProcessing) return;
    HapticFeedback.mediumImpact();
    await _processDecodedCode(rawCode);
  }

  Future<void> _processDecodedCode(String rawCode) async {
    final targetId = _extractMachineId(rawCode);
    if (targetId.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'Đang nhận diện thiết bị: $targetId...';
    });

    try {
      try {
        await _scannerController.stop();
      } catch (_) {}

      debugPrint(
        '[QR Scanner] Looking up machine with ID/Code: $targetId (Raw: $rawCode)',
      );

      MachineModel? machine;

      // 1. Try to fetch directly by ID
      try {
        machine = await _machineService.getMachineById(targetId);
      } catch (e) {
        debugPrint(
          '[QR Scanner] getMachineById fallback to list search: $e',
        );
        try {
          final machines = await _machineService.getMachines();
          for (final m in machines) {
            if (m.id.toLowerCase() == targetId.toLowerCase() ||
                m.code.toLowerCase() == targetId.toLowerCase()) {
              machine = m;
              break;
            }
          }
        } catch (_) {}
      }

      if (!mounted) return;

      if (machine != null) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context, machine);
      } else {
        _showNotFoundDialog(targetId);
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
        _statusText = 'Đang giải mã QR từ ảnh...';
      });

      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        image.path,
      );

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
        await _processDecodedCode(foundCode);
      } else {
        if (mounted) {
          _showErrorSnackBar(
            'Không tìm thấy mã QR trong ảnh. Vui lòng chọn ảnh rõ nét hơn.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Không thể đọc ảnh: $e');
      }
    } finally {
      if (mounted && _statusText != null) {
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
            Text('Không tìm thấy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Không tìm thấy thiết bị nào khớp với mã:\n"$code"\n\nBạn có thể thử nhập mã thủ công ở tab kế bên.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tabController.animateTo(1);
            },
            child: const Text('Nhập mã thủ công'),
          ),
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
            child: const Text('Quét lại'),
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
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Quét & Nhận Diện Thiết Bị',
                        style: TextStyle(
                          fontSize: 17.5,
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
            ),

            // Segmented Tab Switcher
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Camera Quét QR'),
                      ],
                    ),
                  ),
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_alt_outlined, size: 16),
                        SizedBox(width: 6),
                        Text('Nhập Mã Máy'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content using IndexedStack for smooth performance
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  // Tab 0: Camera Scanner
                  _buildCameraScannerTab(),

                  // Tab 1: Manual ID Lookup
                  _buildManualLookupTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraScannerTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mobile Scanner
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

                  // Viewfinder Frame
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Animated Scanning Line
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Positioned(
                              top: _animController.value * 210,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF10B981),
                                      Colors.white,
                                      Color(0xFF10B981),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Corner Brackets
                        _buildCorner(Alignment.topLeft, true, true),
                        _buildCorner(Alignment.topRight, true, false),
                        _buildCorner(Alignment.bottomLeft, false, true),
                        _buildCorner(Alignment.bottomRight, false, false),
                      ],
                    ),
                  ),

                  // Floating Controls (Torch, Flip)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Row(
                      children: [
                        _buildFloatingIcon(
                          icon: _isTorchOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: _isTorchOn ? Colors.amber : Colors.white,
                          tooltip: 'Đèn Flash',
                          onTap: () async {
                            await _scannerController.toggleTorch();
                            setState(() => _isTorchOn = !_isTorchOn);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFloatingIcon(
                          icon: Icons.flip_camera_ios_rounded,
                          color: Colors.white,
                          tooltip: 'Đổi Camera',
                          onTap: () => _scannerController.switchCamera(),
                        ),
                      ],
                    ),
                  ),

                  // Processing Overlay
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF10B981),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _statusText ?? 'Đang nhận diện thiết bị...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
          const SizedBox(height: 12),
          const Text(
            'Hướng camera vào mã QR trên thân máy hoặc tải ảnh từ thư viện',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppTheme.mutedForegroundColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                'Tải ảnh QR từ thư viện máy',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualLookupTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          // Search Input Field
          TextField(
            controller: _manualIdController,
            onChanged: _onSearchQueryChanged,
            decoration: InputDecoration(
              hintText: 'Nhập mã máy (VD: CNC-01, ROBOT-02)...',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
              suffixIcon: _manualIdController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _manualIdController.clear();
                        _onSearchQueryChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Machine Matching List
          Expanded(
            child: _isLoadingMachines
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : _filteredMachines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Không tìm thấy thiết bị phù hợp',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredMachines.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (ctx, index) {
                          final m = _filteredMachines[index];
                          return InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context, m);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.precision_manufacturing_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.name,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                m.code,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                m.location,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, bool isTop, bool isLeft) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFF10B981), width: 3.5)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF10B981), width: 3.5)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF10B981), width: 3.5)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF10B981), width: 3.5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
