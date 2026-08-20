import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onQRTapped;
  final int pendingTasksCount;
  final int unreadNotificationsCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onQRTapped,
    this.pendingTasksCount = 0,
    this.unreadNotificationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Trang Chủ',
                isSelected: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _NavBarItem(
                icon: Icons.memory_rounded,
                activeIcon: Icons.memory_rounded,
                label: 'Máy Móc',
                isSelected: currentIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _CenterQRButton(onTap: onQRTapped),
              _NavBarItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                label: 'Nhiệm Vụ',
                isSelected: currentIndex == 2,
                badgeCount: pendingTasksCount,
                onTap: () => onItemSelected(2),
              ),
              _NavBarItem(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                label: 'Thông Báo',
                isSelected: currentIndex == 3,
                badgeCount: unreadNotificationsCount,
                onTap: () => onItemSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isSelected
        ? AppTheme.primaryColor
        : (_isHovered ? const Color(0xFF0F172A) : AppTheme.mutedForegroundColor);

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : (_isHovered ? 1.05 : 1.0),
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _isHovered && !widget.isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          widget.isSelected ? widget.activeIcon : widget.icon,
                          key: ValueKey('${widget.label}_${widget.isSelected}'),
                          size: 22,
                          color: color,
                        ),
                      ),
                      if (widget.badgeCount > 0)
                        Positioned(
                          top: -4,
                          right: -7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 15,
                              minHeight: 15,
                            ),
                            child: Text(
                              '${widget.badgeCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: color,
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterQRButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CenterQRButton({required this.onTap});

  @override
  State<_CenterQRButton> createState() => _CenterQRButtonState();
}

class _CenterQRButtonState extends State<_CenterQRButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? 0.90 : (_isHovered ? 1.08 : 1.0);

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: SizedBox(
            height: 62,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -16,
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF059669),
                            Color(0xFF10B981),
                            Color(0xFF0D9488),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF059669).withValues(
                              alpha: _isHovered ? 0.55 : 0.35,
                            ),
                            blurRadius: _isHovered ? 16 : 10,
                            spreadRadius: _isHovered ? 2 : 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedRotation(
                          turns: _isHovered ? 0.033 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _isHovered
                          ? const Color(0xFF047857)
                          : AppTheme.primaryColor,
                      letterSpacing: -0.2,
                    ),
                    child: const Text('Quét QR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
