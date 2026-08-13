import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import 'machine_history_tab.dart';
import 'machine_specs_tab.dart';
import 'machine_troubleshoot_tab.dart';

class MachinePassportModal extends StatefulWidget {
  final MachineModel machine;
  final ValueChanged<List<TroubleshootingItem>> onSaveTroubleshooting;

  const MachinePassportModal({
    super.key,
    required this.machine,
    required this.onSaveTroubleshooting,
  });

  static Future<void> show(
    BuildContext context, {
    required MachineModel machine,
    required ValueChanged<List<TroubleshootingItem>> onSaveTroubleshooting,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'MachinePassportModal',
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.6), // bg-slate-900/60
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: MachinePassportModal(
            machine: machine,
            onSaveTroubleshooting: onSaveTroubleshooting,
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic));

        final fadeAnimation = CurvedAnimation(parent: anim1, curve: Curves.easeOut);

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<MachinePassportModal> createState() => _MachinePassportModalState();
}

class _MachinePassportModalState extends State<MachinePassportModal> {
  int _activeTab = 0; // 0: SPECS, 1: TROUBLESHOOT, 2: HISTORY

  @override
  Widget build(BuildContext context) {
    final machine = widget.machine;
    final unitLabel = machine.trackingUnit == 'KM' ? 'Km' : 'Giờ';

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0), // rounded-2xl
        border: Border.all(color: const Color(0xFFE2E8F0)), // border-slate-200
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header (p-3.5 border-b border-slate-100 bg-slate-50/60)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Color(0x99F8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusBadge(machine.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        machine.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800, // font-extrabold
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        machine.location,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),

          // 2. Running hours / Km quick bar (mx-3.5 my-2 p-2.5 rounded-xl)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.unitLabel.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          machine.runningHours.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unitLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Navigation Tabs (px-4 border-b border-slate-100 flex gap-4)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Thông Số Kỹ Thuật'),
                const SizedBox(width: 14),
                _buildTabButton(1, 'Cẩm Nang Lỗi Nhanh'),
                const SizedBox(width: 14),
                _buildTabButton(2, 'Lịch Sử Bảo Trì (3)'),
              ],
            ),
          ),

          // 4. Tab Content Scrollable Area
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14.0),
              child: IndexedStack(
                index: _activeTab,
                children: [
                  MachineSpecsTab(machine: machine),
                  MachineTroubleshootTab(
                    machine: machine,
                    onSaveTroubleshooting: widget.onSaveTroubleshooting,
                  ),
                  MachineHistoryTab(machine: machine),
                ],
              ),
            ),
          ),

          // 5. Footer Action với nút Pulsing Animation [🚨 BÁO LỖI SOS KHẨN CẤP 🚨]
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
            ),
            child: _PulsingSosButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🚨 Đã kích hoạt lệnh Báo Lỗi SOS Khẩn Cấp cho ${machine.code}!'),
                    backgroundColor: const Color(0xFFE11D48),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isActive = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF059669) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isActive ? const Color(0xFF047857) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MachineStatus status) {
    Color bg = const Color(0xFFECFDF5);
    Color text = const Color(0xFF047857);
    Color border = const Color(0xFFA7F3D0);
    String label = 'HOẠT ĐỘNG';

    if (status == MachineStatus.repairing) {
      bg = const Color(0xFFFFE4E6);
      text = const Color(0xFF9F1239);
      border = const Color(0xFFFECDD3);
      label = 'SỬA CHỮA (SOS)';
    } else if (status == MachineStatus.maintenance) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFF92400E);
      border = const Color(0xFFFDE68A);
      label = 'BẢO TRÌ PM';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Text(
        '● $label',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }
}

class _PulsingSosButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PulsingSosButton({required this.onPressed});

  @override
  State<_PulsingSosButton> createState() => _PulsingSosButtonState();
}

class _PulsingSosButtonState extends State<_PulsingSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: const Text(
                  '[🚨 BÁO LỖI SOS KHẨN CẤP 🚨]',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48), // Rose-600
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFFE11D48).withValues(alpha: 0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
