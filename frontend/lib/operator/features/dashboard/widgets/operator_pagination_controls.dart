import 'package:flutter/material.dart';

class OperatorPaginationDots extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onDotTapped;

  const OperatorPaginationDots({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isSelected = index == currentPage;
        return GestureDetector(
          onTap: () => onDotTapped?.call(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isSelected ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class OperatorPaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevPressed;
  final VoidCallback? onNextPressed;

  const OperatorPaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevPressed,
    this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final bool canPrev = currentPage > 0 && onPrevPressed != null;
    final bool canNext = currentPage < totalPages - 1 && onNextPressed != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button Trang trước (Chỉ giữ Icon)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canPrev ? onPrevPressed : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: canPrev ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canPrev
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: canPrev
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Center Text: Trang X / Y
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
              children: [
                const TextSpan(text: 'Trang '),
                TextSpan(
                  text: '${currentPage + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const TextSpan(text: '  /  '),
                TextSpan(
                  text: '$totalPages',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Button Trang sau (Chỉ giữ Icon)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canNext ? onNextPressed : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: canNext ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canNext
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: canNext
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
