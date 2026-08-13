import 'package:flutter/material.dart';

class SosTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final int index;
  final VoidCallback? onTap;

  const SosTicketCard({
    super.key,
    required this.ticket,
    required this.index,
    this.onTap,
  });

  String _formatTicketCode(Map<String, dynamic> ticket, int index) {
    final createdAt = ticket['created_at']?.toString() ?? '';
    String year = '2026';
    if (createdAt.isNotEmpty && createdAt.length >= 4) {
      year = createdAt.substring(0, 4);
    }
    final numStr = (index + 1).toString().padLeft(3, '0');
    return 'SOS-$year-$numStr';
  }

  @override
  Widget build(BuildContext context) {
    final rawStatus = ticket['status']?.toString().toUpperCase() ?? 'OPEN';
    final ticketCode = _formatTicketCode(ticket, index);
    final machineName = ticket['machine_name']?.toString() ??
        (ticket['machine_code']?.toString() ?? 'Thiết bị');
    final description = ticket['description']?.toString() ?? '';

    // Status Badge Configuration
    Color badgeBg;
    Color badgeText;
    Color badgeBorder;
    String displayStatus;

    switch (rawStatus) {
      case 'IN_PROGRESS':
        badgeBg = const Color(0xFFF1F5F9);
        badgeBorder = const Color(0xFFCBD5E1);
        badgeText = const Color(0xFF334155);
        displayStatus = 'IN_PROGRESS';
        break;
      case 'CLOSED':
        badgeBg = const Color(0xFFECFDF5);
        badgeBorder = const Color(0xFFA7F3D0);
        badgeText = const Color(0xFF059669);
        displayStatus = 'CLOSED';
        break;
      case 'CANCELLED':
      case 'REJECTED':
        badgeBg = const Color(0xFFFEF2F2);
        badgeBorder = const Color(0xFFFECACA);
        badgeText = const Color(0xFFDC2626);
        displayStatus = 'CANCELLED';
        break;
      case 'OPEN':
      case 'PENDING':
      default:
        badgeBg = const Color(0xFFFEF3C7);
        badgeBorder = const Color(0xFFFDE68A);
        badgeText = const Color(0xFFD97706);
        displayStatus = 'PENDING';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Code + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ticketCode,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                        letterSpacing: 0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeBorder),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Row 2: Machine Name
                Text(
                  machineName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 4),

                // Row 3: Description
                if (description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
