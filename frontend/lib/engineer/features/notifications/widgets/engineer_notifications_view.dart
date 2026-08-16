import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/engineer_notification.dart';
import '../services/engineer_notification_service.dart';

class EngineerNotificationsView extends StatefulWidget {
  const EngineerNotificationsView({super.key});

  @override
  State<EngineerNotificationsView> createState() =>
      _EngineerNotificationsViewState();
}

class _EngineerNotificationsViewState extends State<EngineerNotificationsView> {
  final EngineerNotificationService _service = EngineerNotificationService();
  bool _isLoading = true;
  List<EngineerNotification> _notifications = [];
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final data = await _service.fetchNotificationsFromApi();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    final success = await _service.markAllAsRead();
    if (success && mounted) {
      setState(() {
        _notifications = _notifications.map((n) {
          return EngineerNotification(
            id: n.id,
            userId: n.userId,
            targetRole: n.targetRole,
            title: n.title,
            message: n.message,
            type: n.type,
            targetId: n.targetId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleItemClick(EngineerNotification item) async {
    if (!item.isRead) {
      await _service.markAsRead(item.id);
      setState(() {
        final index =
            _notifications.indexWhere((element) => element.id == item.id);
        if (index != -1) {
          _notifications[index] = EngineerNotification(
            id: item.id,
            userId: item.userId,
            targetRole: item.targetRole,
            title: item.title,
            message: item.message,
            type: item.type,
            targetId: item.targetId,
            isRead: true,
            createdAt: item.createdAt,
          );
        }
      });
    }

    _showNotificationDetailBottomSheet(item);
  }

  void _showNotificationDetailBottomSheet(EngineerNotification item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _getNotificationIcon(item.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(item.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              const Text(
                'NỘI DUNG THÔNG BÁO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.message,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getNotificationIcon(EngineerNotificationType type) {
    switch (type) {
      case EngineerNotificationType.sos:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 22),
        );
      case EngineerNotificationType.pm:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.build_circle_rounded,
              color: Color(0xFF10B981), size: 22),
        );
      case EngineerNotificationType.approval:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.verified_user_rounded,
              color: Color(0xFFF59E0B), size: 22),
        );
      case EngineerNotificationType.system:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.notifications_rounded,
              color: Color(0xFF3B82F6), size: 22),
        );
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildFilterChip(
      String label, String key, IconData icon, Color color) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
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
            Icon(icon,
                size: 13,
                color: isSelected ? color : const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EngineerNotification>>(
      stream: _service.streamNotifications(),
      builder: (context, snapshot) {
        final rawNotifications = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!
            : _notifications;

        final notifications = rawNotifications.where((n) {
          if (_selectedFilter == 'SOS') {
            return n.type == EngineerNotificationType.sos;
          }
          if (_selectedFilter == 'PM') {
            return n.type == EngineerNotificationType.pm;
          }
          if (_selectedFilter == 'APPROVAL') {
            return n.type == EngineerNotificationType.approval;
          }
          return true;
        }).toList();

        return RefreshIndicator(
          onRefresh: _loadInitialData,
          color: AppTheme.primaryColor,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_active_rounded,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'THÔNG BÁO SỰ CỐ (${rawNotifications.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Sự cố máy từ Operator, lịch bảo trì PM & nghiệm thu',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _handleMarkAllAsRead,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        'Đã đọc tất cả',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Filter Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả', 'ALL',
                        Icons.border_all_rounded, AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    _buildFilterChip('Sự cố SOS', 'SOS',
                        Icons.warning_amber_rounded, const Color(0xFFEF4444)),
                    const SizedBox(width: 6),
                    _buildFilterChip('Bảo trì PM', 'PM',
                        Icons.build_circle_rounded, const Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    _buildFilterChip('Phê duyệt', 'APPROVAL',
                        Icons.verified_user_rounded, const Color(0xFFF59E0B)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (_isLoading && rawNotifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (notifications.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 50, horizontal: 20),
                  alignment: Alignment.center,
                  child: Column(
                    children: const [
                      Icon(Icons.notifications_none_rounded,
                          size: 56, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 12),
                      Text(
                        'Không có thông báo phù hợp',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Các thông báo sự cố mới từ Operator sẽ xuất hiện tại đây',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final isUnread = !item.isRead;

                    return InkWell(
                      onTap: () => _handleItemClick(item),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? const Color(0xFFF0FDF4)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUnread
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFE2E8F0),
                            width: isUnread ? 1.2 : 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getNotificationIcon(item.type),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            if (isUnread) ...[
                                              Container(
                                                width: 8,
                                                height: 8,
                                                margin: const EdgeInsets.only(
                                                    right: 6),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isUnread
                                                      ? FontWeight.w900
                                                      : FontWeight.w700,
                                                  color:
                                                      const Color(0xFF0F172A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _formatTime(item.createdAt),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF94A3B8),
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF475569),
                                      height: 1.35,
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
                ),
            ],
          ),
        );
      },
    );
  }
}
