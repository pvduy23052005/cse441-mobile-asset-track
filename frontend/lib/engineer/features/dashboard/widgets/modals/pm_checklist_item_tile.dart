import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'pm_checklist_modal.dart';

class PMChecklistItemTile extends StatelessWidget {
  final PMChecklistItemData item;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onSimulatePhoto;

  const PMChecklistItemTile({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onSimulatePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: item.isChecked
            ? const Color(0xFFECFDF5)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isChecked
              ? const Color(0xFFA7F3D0)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.isChecked,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  item.taskDescription,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: item.isChecked
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1E293B),
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (item.isRequiredPhoto) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Yêu cầu ảnh minh chứng',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                      if (item.photoUrl != null)
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Đã chụp ảnh',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        )
                      else
                        InkWell(
                          onTap: onSimulatePhoto,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 12,
                                  color: Color(0xFFD97706),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Chụp ảnh',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
