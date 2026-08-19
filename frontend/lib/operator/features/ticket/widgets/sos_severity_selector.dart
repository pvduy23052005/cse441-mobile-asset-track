import 'package:flutter/material.dart';

class SosSeveritySelector extends StatelessWidget {
  final String selectedSeverity;
  final ValueChanged<String> onSeverityChanged;

  static const List<Map<String, dynamic>> severityConfig = [
    {
      'key': 'LOW',
      'label': 'Thấp',
      'subtitle': 'Lỗi nhỏ, máy vẫn chạy',
      'icon': Icons.info_outline_rounded,
      'color': Color(0xFF059669),
      'bgColor': Color(0xFFECFDF5),
    },
    {
      'key': 'MEDIUM',
      'label': 'Trung bình',
      'subtitle': 'Giảm tốc độ / Rung',
      'icon': Icons.warning_amber_rounded,
      'color': Color(0xFFD97706),
      'bgColor': Color(0xFFFFFBEB),
    },
    {
      'key': 'HIGH',
      'label': 'Cao',
      'subtitle': 'Có nguy cơ dừng máy',
      'icon': Icons.error_outline_rounded,
      'color': Color(0xFFEA580C),
      'bgColor': Color(0xFFFFF7ED),
    },
    {
      'key': 'CRITICAL',
      'label': 'Khẩn cấp',
      'subtitle': 'Máy đã dừng hoàn toàn',
      'icon': Icons.dangerous_rounded,
      'color': Color(0xFFDC2626),
      'bgColor': Color(0xFFFEF2F2),
    },
  ];

  const SosSeveritySelector({
    super.key,
    required this.selectedSeverity,
    required this.onSeverityChanged,
  });

  static Color getSeverityColor(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return const Color(0xFF059669);
      case 'MEDIUM':
        return const Color(0xFFD97706);
      case 'HIGH':
        return const Color(0xFFEA580C);
      case 'CRITICAL':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.35,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: severityConfig.length,
          itemBuilder: (context, index) {
            final item = severityConfig[index];
            final key = item['key'] as String;
            final isSelected = selectedSeverity.toUpperCase() == key;
            final color = item['color'] as Color;
            final bgColor = item['bgColor'] as Color;
            final icon = item['icon'] as IconData;
            final label = item['label'] as String;
            final subtitle = item['subtitle'] as String;

            return InkWell(
              onTap: () => onSeverityChanged(key),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? bgColor : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? color.withValues(alpha: 0.3)
                              : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: isSelected ? color : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? color
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($key)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? color.withValues(alpha: 0.8)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isSelected
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF64748B),
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
