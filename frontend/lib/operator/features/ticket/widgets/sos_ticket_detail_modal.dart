import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/operator_tickets_provider.dart';

class SosTicketDetailModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> ticket;
  final int index;

  const SosTicketDetailModal({
    super.key,
    required this.ticket,
    required this.index,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> ticket,
    required int index,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SosTicketDetailModal(ticket: ticket, index: index),
    );
  }

  @override
  ConsumerState<SosTicketDetailModal> createState() =>
      _SosTicketDetailModalState();
}

class _SosTicketDetailModalState extends ConsumerState<SosTicketDetailModal> {
  bool _isDeleting = false;

  String _formatTicketCode(Map<String, dynamic> ticket, int index) {
    final createdAt = ticket['created_at']?.toString() ?? '';
    String year = '2026';
    if (createdAt.isNotEmpty && createdAt.length >= 4) {
      year = createdAt.substring(0, 4);
    }
    final numStr = (index + 1).toString().padLeft(3, '0');
    return 'SOS-$year-$numStr';
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'Chưa ghi nhận';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute - $day/$month/$year';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _handleDeleteTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text(
              'Xác nhận hủy phiếu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn hủy phiếu báo sự cố này không? Thao tác này sẽ xóa phiếu và hoàn trả trạng thái ban đầu của thiết bị.',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF475569),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Đóng',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hủy phiếu',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final ticketId = widget.ticket['id']?.toString() ?? '';
      final isLocal = widget.ticket['is_local'] == true ||
          widget.ticket['sync_status'] == 'PENDING';

      if (ticketId.isNotEmpty) {
        await ref
            .read(operatorTicketsProvider.notifier)
            .deleteTicket(ticketId, isLocal: isLocal);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Đã hủy phiếu sự cố thành công!'),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi hủy phiếu: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final ticketCode = _formatTicketCode(ticket, widget.index);
    final rawStatus = ticket['status']?.toString().toUpperCase() ?? 'PENDING';
    final machineName = ticket['machine_name']?.toString() ??
        (ticket['machine_code']?.toString() ?? 'Thiết bị');
    final machineCode = ticket['machine_code']?.toString() ?? '';
    final description = ticket['description']?.toString() ?? '';
    final engineerName = ticket['engineer_name']?.toString() ?? '';
    final downtimeStart = ticket['downtime_start']?.toString() ??
        ticket['created_at']?.toString();
    final isPendingSync = ticket['sync_status'] == 'PENDING' ||
        ticket['is_local'] == true;

    Color badgeBg;
    Color badgeText;
    Color badgeBorder;
    String displayStatus;

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

    final bool canCancel = rawStatus == 'PENDING' ||
        rawStatus == 'OPEN' ||
        rawStatus == 'REJECTED' ||
        rawStatus == 'CANCELLED';

    final List<dynamic> imagesUrls = (ticket['images_urls'] as List?) ?? [];
    final List<dynamic> localImages =
        (ticket['local_image_paths'] as List?) ?? [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      ticketCode,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isPendingSync)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 12, color: Color(0xFFD97706)),
                            SizedBox(width: 4),
                            Text(
                              'Chưa đồng bộ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.precision_manufacturing_rounded,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    machineName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (machineCode.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Mã máy: $machineCode',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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
                        if (engineerName.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.engineering_rounded,
                                    size: 15, color: Color(0xFF0284C7)),
                                const SizedBox(width: 6),
                                Text(
                                  'Kỹ sư tiếp nhận: $engineerName',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        const Text(
                          'Thời gian phát sinh: ',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _formatDateTime(downtimeStart),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Mô tả sự cố',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      description.isNotEmpty
                          ? description
                          : 'Không có mô tả chi tiết.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),

                  if (imagesUrls.isNotEmpty || localImages.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Hình ảnh đính kèm',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...localImages.map(
                            (path) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1)),
                                image: DecorationImage(
                                  image: FileImage(File(path.toString())),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          ...imagesUrls.map(
                            (url) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1)),
                                image: DecorationImage(
                                  image: NetworkImage(url.toString()),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: canCancel
                ? SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting ? null : _handleDeleteTicket,
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFDC2626),
                              ),
                            )
                          : const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 18,
                            ),
                      label: Text(
                        _isDeleting ? 'Đang hủy...' : 'Hủy Phiếu Báo Hỏng',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        side: const BorderSide(
                            color: Color(0xFFFECACA), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 6),
                        Text(
                          'Phiếu đang được xử lý hoặc đã kết thúc',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
