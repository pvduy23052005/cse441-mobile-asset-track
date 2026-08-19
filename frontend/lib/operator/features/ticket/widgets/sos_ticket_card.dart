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
    final rawStatus = ticket['status']?.toString().toUpperCase() ?? 'PENDING';
    final ticketCode = _formatTicketCode(ticket, index);
    final machineName =
        ticket['machine_name']?.toString() ??
        (ticket['machine_code']?.toString() ?? 'Thiết bị');
    final description = ticket['description']?.toString() ?? '';

    Color badgeBg;
    Color badgeText;
    Color badgeBorder;
    String displayStatus;

    final engineerName = ticket['engineer_name']?.toString() ?? '';

    switch (rawStatus) {
      case 'IN_PROGRESS':
        badgeBg = const Color(0xFFE0F2FE);
        badgeBorder = const Color(0xFFBAE6FD);
        badgeText = const Color(0xFF0284C7);
        displayStatus = 'Đang xử lý';
        break;
      case 'CLOSED':
      case 'COMPLETED':
      case 'APPROVED':
        badgeBg = const Color(0xFFECFDF5);
        badgeBorder = const Color(0xFFA7F3D0);
        badgeText = const Color(0xFF059669);
        displayStatus = 'Đã hoàn thành';
        break;
      case 'REJECTED':
        badgeBg = const Color(0xFFFEF2F2);
        badgeBorder = const Color(0xFFFECACA);
        badgeText = const Color(0xFFDC2626);
        displayStatus = 'Bị từ chối';
        break;
      case 'CANCELLED':
        badgeBg = const Color(0xFFF1F5F9);
        badgeBorder = const Color(0xFFCBD5E1);
        badgeText = const Color(0xFF64748B);
        displayStatus = 'Đã hủy';
        break;
      case 'OPEN':
      case 'PENDING':
      default:
        badgeBg = const Color(0xFFFEF3C7);
        badgeBorder = const Color(0xFFFDE68A);
        badgeText = const Color(0xFFD97706);
        displayStatus = 'Chờ tiếp nhận';
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
                    Row(
                      children: [
                        if (ticket['sync_status'] == 'PENDING' ||
                            ticket['is_local'] == true) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 11,
                                  color: Color(0xFFD97706),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Chờ đồng bộ',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
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
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  machineName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 4),

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

                if (engineerName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.engineering_rounded,
                          size: 13,
                          color: Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Kỹ sư tiếp nhận: $engineerName',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
