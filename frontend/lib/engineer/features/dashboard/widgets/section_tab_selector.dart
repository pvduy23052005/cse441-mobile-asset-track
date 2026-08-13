import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum DashboardSection { sos, pm }

class SectionTabSelector extends StatelessWidget {
  final DashboardSection activeSection;
  final int sosCount;
  final int pmCount;
  final ValueChanged<DashboardSection> onSectionChanged;

  const SectionTabSelector({
    super.key,
    required this.activeSection,
    required this.sosCount,
    required this.pmCount,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTabItem(
            section: DashboardSection.sos,
            label: 'Sự Cố Khẩn Cấp ($sosCount)',
            isSelected: activeSection == DashboardSection.sos,
          ),
          const SizedBox(width: 20),
          _buildTabItem(
            section: DashboardSection.pm,
            label: 'Bảo Trì Định Kỳ ($pmCount)',
            isSelected: activeSection == DashboardSection.pm,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required DashboardSection section,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onSectionChanged(section),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF0284C7) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0284C7) : AppTheme.mutedForegroundColor,
          ),
        ),
      ),
    );
  }
}
