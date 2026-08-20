import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RoleHeader extends StatelessWidget {
  final String roleName;
  final String userEmail;
  final IconData roleIcon;
  final Color roleColor;
  final VoidCallback? onChangeAccount;

  const RoleHeader({
    super.key,
    required this.roleName,
    required this.userEmail,
    this.roleIcon = Icons.build_rounded,
    this.roleColor = const Color(0xFF0284C7),
    this.onChangeAccount,
  });

  @override
  Widget build(BuildContext context) {
    final String shortName = userEmail.contains('@')
        ? userEmail.split('@')[0]
        : userEmail;

    return Container(
      color: AppTheme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'AT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AssetTrack Mobile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.foregroundColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Hệ Thống Lý Lịch & Bảo Trì Máy',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          InkWell(
            onTap: onChangeAccount,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.login_rounded, size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 4),
                  Text(
                    shortName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
