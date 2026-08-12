import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onDelete;

  const UserCard({super.key, required this.user, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final role = (user['role'] ?? 'operator').toString().toLowerCase();
    final bool isEngineer = role == 'engineer';

    final Color roleBgColor = isEngineer
        ? const Color(0xFFF0F9FF)
        : const Color(0xFFECFDF5);
    final Color roleTextColor = isEngineer
        ? const Color(0xFF0369A1)
        : AppTheme.primaryColor;
    final IconData roleIcon = isEngineer
        ? Icons.build_outlined
        : Icons.engineering_outlined;

    final String fullName =
        user['fullName'] ?? user['full_name'] ?? 'Chưa đặt tên';
    final String email = user['email'] ?? '';
    final String userKey =
        (user['id'] ?? user['uid'] ?? user['email'] ?? '').toString();

    return Dismissible(
      key: ValueKey(userKey),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          onDelete!();
        }
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(width: 6),
            Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: roleBgColor,
                child: Icon(roleIcon, color: roleTextColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.foregroundColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppTheme.mutedForegroundColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.mutedForegroundColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Xóa tài khoản',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
