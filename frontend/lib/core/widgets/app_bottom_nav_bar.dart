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
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Trang Chủ',
                isSelected: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _buildNavItem(
                icon: Icons.memory_rounded,
                activeIcon: Icons.memory_rounded,
                label: 'Máy Móc',
                isSelected: currentIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _buildCenterQRButton(),
              _buildNavItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                label: 'Nhiệm Vụ',
                isSelected: currentIndex == 2,
                badgeCount: pendingTasksCount,
                onTap: () => onItemSelected(2),
              ),
              _buildNavItem(
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

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final Color color = isSelected
        ? AppTheme.primaryColor
        : AppTheme.mutedForegroundColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isSelected ? activeIcon : icon, size: 22, color: color),
                if (badgeCount > 0)
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
                        '$badgeCount',
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
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterQRButton() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onQRTapped,
        child: SizedBox(
          height: 62,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -16,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF0D9488)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.cardColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 6,
                child: Text(
                  'Quét QR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
