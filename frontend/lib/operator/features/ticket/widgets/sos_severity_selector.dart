import 'package:flutter/material.dart';

class SosSeveritySelector extends StatelessWidget {
  final String selectedSeverity;
  final ValueChanged<String> onSeverityChanged;

  static const List<String> severityLevels = [
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
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
    return Row(
      children: severityLevels.map((level) {
        final isSelected = selectedSeverity.toUpperCase() == level;
        final activeColor = getSeverityColor(level);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: InkWell(
              onTap: () => onSeverityChanged(level),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
