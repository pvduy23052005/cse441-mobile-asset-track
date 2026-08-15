import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/symptom_category_model.dart';

class SosSymptomSelector extends StatefulWidget {
  final Set<String> selectedSymptoms;
  final ValueChanged<String> onSymptomToggled;
  final VoidCallback onClearAll;
  final List<SymptomCategoryModel> categories;

  const SosSymptomSelector({
    super.key,
    required this.selectedSymptoms,
    required this.onSymptomToggled,
    required this.onClearAll,
    this.categories = defaultSymptomCategories,
  });

  @override
  State<SosSymptomSelector> createState() => _SosSymptomSelectorState();
}

class _SosSymptomSelectorState extends State<SosSymptomSelector> {
  String _activeCategoryTab = 'ALL';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề mục & Nút xóa chọn
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  size: 16,
                  color: Color(0xFF0284C7),
                ),
                SizedBox(width: 6),
                Text(
                  'Triệu Chứng Sự Cố (Chọn nhanh)',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            if (widget.selectedSymptoms.isNotEmpty)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onClearAll();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Xóa chọn (${widget.selectedSymptoms.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // 2. Thanh Tab chuyển đổi danh mục
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryTab(
                id: 'ALL',
                title: 'Tất cả',
                icon: Icons.grid_view_rounded,
                color: const Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              ...widget.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildCategoryTab(
                    id: category.id,
                    title: category.title,
                    icon: category.icon,
                    color: category.color,
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 3. Danh sách các nhóm danh mục tương ứng
        ...widget.categories
            .where((category) =>
                _activeCategoryTab == 'ALL' ||
                _activeCategoryTab == category.id)
            .map((category) {
          final selectedInCatCount = category.symptoms
              .where((symptom) => widget.selectedSymptoms.contains(symptom))
              .length;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedInCatCount > 0
                    ? category.color.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header của từng danh mục
                Row(
                  children: [
                    Icon(
                      category.icon,
                      size: 14,
                      color: category.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.title,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: category.color,
                      ),
                    ),
                    if (selectedInCatCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$selectedInCatCount',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Danh sách chip triệu chứng trong danh mục
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: category.symptoms.map((symptom) {
                    final isSelected =
                        widget.selectedSymptoms.contains(symptom);

                    return FilterChip(
                      label: Text(symptom),
                      selected: isSelected,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        widget.onSymptomToggled(symptom);
                      },
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? category.color
                            : const Color(0xFF334155),
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: category.color.withValues(alpha: 0.12),
                      checkmarkColor: category.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? category.color
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.3 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryTab({
    required String id,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _activeCategoryTab == id;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _activeCategoryTab = id;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? color : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
