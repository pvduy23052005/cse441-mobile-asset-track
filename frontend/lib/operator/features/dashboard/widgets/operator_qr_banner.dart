import 'package:flutter/material.dart';
import '../../../../core/utils/storage_service.dart';

class OperatorQRBanner extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onUserManagementTap;
  final VoidCallback? onFilterTap;

  const OperatorQRBanner({
    super.key,
    required this.onTap,
    this.onUserManagementTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final profile = StorageService.getUserProfile();
    final fullName = profile['fullName']?.trim();
    final email = profile['email']?.trim();

    String displayName = 'Công Nhân Vận Hành A';
    if (fullName != null && fullName.isNotEmpty) {
      displayName = fullName;
    } else if (email != null && email.isNotEmpty) {
      displayName = email.split('@').first;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Badge CN
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF059669), // emerald-600
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.center,
            child: const Text(
              'CN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Profile Info (Dynamic Name of Logged In User + Online Dot + Subtitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), // emerald-500 online dot
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email != null && email.isNotEmpty ? email : 'Phân Xưởng A - Cơ Khí Dập & CNC',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // 3 Action Buttons (Image 1 from UI prototype)
          Row(
            children: [
              // Button 1: Green (+) Add / Scan Action
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5), // mint green bg
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // Button 2: Yellow (👥) User / Personnel Action
              InkWell(
                onTap: onUserManagementTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Danh sách nhân sự ca trực phân xưởng'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7), // light yellow bg
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 18,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // Button 3: Grey (🎛️) Sliders / Filter Action
              InkWell(
                onTap: onFilterTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cấu hình bộ lọc & tham số máy'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC), // light grey bg
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
