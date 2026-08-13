import 'package:flutter/material.dart';

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
    final bool canPrev = currentPage > 0 && onPrevPressed != null;
    final bool canNext =
        currentPage < totalPages - 1 && onNextPressed != null;

    return Row(
      children: [
        // Button Trang trước
        Expanded(
          flex: 4,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(
                color: canPrev
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFFF1F5F9),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: canPrev ? Colors.white : const Color(0xFFF8FAFC),
            ),
            onPressed: canPrev ? onPrevPressed : null,
            child: Text(
              '← Trang trước',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: canPrev
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ),

        // Center Text
        Expanded(
          flex: 4,
          child: Center(
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
        ),

        // Button Trang sau
        Expanded(
          flex: 4,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(
                color: canNext
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFFF1F5F9),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: canNext ? Colors.white : const Color(0xFFF8FAFC),
            ),
            onPressed: canNext ? onNextPressed : null,
            child: Text(
              'Trang sau →',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: canNext
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
