import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/storage_service.dart';

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final int? index;
  final VoidCallback? onTap;
  final int badgeCount;
  final Color? badgeColor;

  const DrawerMenuItem({
    required this.icon,
    required this.title,
    this.index,
    this.onTap,
    this.badgeCount = 0,
    this.badgeColor,
  });
}

class AppDrawer extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final String roleLabel;
  final String roleBadge;
  final Color? roleColor;
  final int currentIndex;
  final List<DrawerMenuItem>? mainNavItems;
  final List<DrawerMenuItem>? toolNavItems;
  final ValueChanged<int>? onIndexSelected;
  final VoidCallback? onLogout;

  const AppDrawer({
    super.key,
    this.userName,
    this.userEmail,
    this.roleLabel = 'Hệ Thống Quản Lý',
    this.roleBadge = 'NHÂN VIÊN',
    this.roleColor,
    this.currentIndex = 0,
    this.mainNavItems,
    this.toolNavItems,
    this.onIndexSelected,
    this.onLogout,
  });

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.errorColor),
            SizedBox(width: 10),
            Text(
              'Đăng Xuất',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
          style: TextStyle(color: AppTheme.mutedForegroundColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppTheme.mutedForegroundColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 40),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close drawer if open
              await StorageService.clearSession();
              if (onLogout != null) {
                onLogout!();
              } else if (context.mounted) {
                context.go(AppRoutes.loginPortal);
              }
            },
            child: const Text('Đăng Xuất'),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotice(BuildContext context, String featureName) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName đang được phát triển.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeThemeColor = roleColor ?? AppTheme.primaryColor;

    return Drawer(
      backgroundColor: AppTheme.cardColor,
      child: Column(
        children: [
          _buildDrawerHeader(activeThemeColor),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // Optional Main Nav Items (if explicitly passed)
                if (mainNavItems != null && mainNavItems!.isNotEmpty) ...[
                  _buildSectionHeader('ĐIỀU HÀNH MỞ RỘNG'),
                  ...mainNavItems!.map(
                    (item) => _buildMenuItem(
                      context: context,
                      item: item,
                      isSelected:
                          item.index != null && item.index == currentIndex,
                      activeColor: activeThemeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    color: AppTheme.borderColor,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: 12),
                ],

                // 2.1 Tools & Utilities Section
                if (toolNavItems != null && toolNavItems!.isNotEmpty) ...[
                  _buildSectionHeader('CÔNG CỤ & TIỆN ÍCH'),
                  ...toolNavItems!.map(
                    (item) => _buildMenuItem(
                      context: context,
                      item: item,
                      isSelected: false,
                      activeColor: activeThemeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    color: AppTheme.borderColor,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: 12),
                ],

                // 2.2 Account & System Section
                _buildSectionHeader('TÀI KHOẢN & CÀI ĐẶT'),
                _buildMenuItem(
                  context: context,
                  item: DrawerMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Hồ Sơ Cá Nhân',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.profile);
                    },
                  ),
                  isSelected: false,
                  activeColor: activeThemeColor,
                ),
                _buildMenuItem(
                  context: context,
                  item: DrawerMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Bảo Mật & Mật Khẩu',
                    onTap: () => _showFeatureNotice(context, 'Tính năng Bảo Mật & Mật Khẩu'),
                  ),
                  isSelected: false,
                  activeColor: activeThemeColor,
                ),
                _buildMenuItem(
                  context: context,
                  item: DrawerMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Cài Đặt Thông Báo',
                    onTap: () => _showFeatureNotice(context, 'Cài Đặt Thông Báo'),
                  ),
                  isSelected: false,
                  activeColor: activeThemeColor,
                ),
                _buildMenuItem(
                  context: context,
                  item: DrawerMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Hướng Dẫn & Trợ Giúp',
                    onTap: () => _showFeatureNotice(context, 'Tài liệu Hướng Dẫn'),
                  ),
                  isSelected: false,
                  activeColor: activeThemeColor,
                ),
              ],
            ),
          ),

          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(Color themeColor) {
    final profile = StorageService.getUserProfile();
    final effectiveName = (userName != null && userName!.isNotEmpty)
        ? userName!
        : (profile['fullName']?.isNotEmpty == true
            ? profile['fullName']!
            : 'Người Dùng');
    final effectiveEmail = (userEmail != null && userEmail!.isNotEmpty)
        ? userEmail!
        : (profile['email']?.isNotEmpty == true
            ? profile['email']!
            : 'user@factory.com');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor,
            Color.lerp(themeColor, Colors.black, 0.25) ?? themeColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    effectiveName.isNotEmpty
                        ? effectiveName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        roleBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      effectiveName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 14,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  effectiveEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80), // Online green
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Online',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.mutedForegroundColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required DrawerMenuItem item,
    required bool isSelected,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? activeColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          dense: true,
          leading: Icon(
            item.icon,
            color: isSelected ? activeColor : AppTheme.foregroundColor,
            size: 22,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : AppTheme.foregroundColor,
            ),
          ),
          trailing: item.badgeCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.badgeColor ?? AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () {
            if (item.onTap != null) {
              item.onTap!();
            } else if (item.index != null) {
              Navigator.pop(context); // Close drawer
              if (onIndexSelected != null) {
                onIndexSelected!(item.index!);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderColor, width: 1)),
      ),
      child: Column(
        children: [
          Material(
            color: AppTheme.errorColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _handleLogout(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Đăng Xuất Khỏi Thiết Bị',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AssetTrack Mobile • v1.0.0',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.mutedForegroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
