import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AppNotificationsView extends StatefulWidget {
  final String? userRole;
  final String? userId;

  const AppNotificationsView({
    super.key,
    this.userRole = 'ENGINEER',
    this.userId,
  });

  @override
  State<AppNotificationsView> createState() => _AppNotificationsViewState();
}

class _AppNotificationsViewState extends State<AppNotificationsView> {
  final NotificationService _service = NotificationService();
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  String _selectedFilter = 'ALL';

  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

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
          return AppNotification(
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

  Future<void> _handleDeleteSingle(AppNotification item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Xóa thông báo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa thông báo "${item.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteNotification(item.id);
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == item.id);
          _selectedIds.remove(item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã xóa thông báo' : 'Lỗi xóa thông báo'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteBatch() async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Xóa nhiều thông báo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa $count thông báo đã chọn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Xóa $count mục', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final idsToDelete = _selectedIds.toList();
      final success = await _service.deleteMultipleNotifications(idsToDelete);
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => idsToDelete.contains(n.id));
          _selectedIds.clear();
          _isSelectionMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã xóa $count thông báo' : 'Lỗi khi xóa hàng loạt thông báo'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleItemClick(AppNotification item) async {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedIds.contains(item.id)) {
          _selectedIds.remove(item.id);
        } else {
          _selectedIds.add(item.id);
        }
      });
      return;
    }

    if (!item.isRead) {
      await _service.markAsRead(item.id);
      setState(() {
        final index = _notifications.indexWhere((element) => element.id == item.id);
        if (index != -1) {
          _notifications[index] = AppNotification(
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

  void _showNotificationDetailBottomSheet(AppNotification item) {
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleDeleteSingle(item);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Xóa thông báo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
            ],
          ),
        );
      },
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.sos:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
        );
      case NotificationType.pm:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.build_circle_rounded, color: Color(0xFF10B981), size: 22),
        );
      case NotificationType.approval:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.verified_user_rounded, color: Color(0xFFF59E0B), size: 22),
        );
      case NotificationType.system:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.notifications_rounded, color: Color(0xFF3B82F6), size: 22),
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

  Widget _buildFilterChip(String label, String key, IconData icon, Color color) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? color : const Color(0xFF64748B)),
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
    return StreamBuilder<List<AppNotification>>(
      stream: _service.streamNotifications(userRole: widget.userRole, userId: widget.userId),
      builder: (context, snapshot) {
        final rawNotifications = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!
            : _notifications;

        final notifications = rawNotifications.where((n) {
          if (_selectedFilter == 'SOS') return n.type == NotificationType.sos;
          if (_selectedFilter == 'PM') return n.type == NotificationType.pm;
          if (_selectedFilter == 'APPROVAL') return n.type == NotificationType.approval;
          return true;
        }).toList();

        final allSelected = notifications.isNotEmpty &&
            notifications.every((n) => _selectedIds.contains(n.id));

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _loadInitialData,
            color: AppTheme.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

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
                                'THÔNG BÁO THỜI GIAN THỰC (${rawNotifications.length})',
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
                          Text(
                            _isSelectionMode
                                ? 'Đã chọn ${_selectedIds.length}/${notifications.length} mục (Vuốt trái để xóa nhanh)'
                                : 'Vuốt trái 1 mục để xóa hoặc bật chọn nhiều để xóa hàng loạt',
                            style: TextStyle(
                              fontSize: 10,
                              color: _isSelectionMode ? AppTheme.primaryColor : const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        if (_isSelectionMode) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (allSelected) {
                                  _selectedIds.clear();
                                } else {
                                  _selectedIds.addAll(notifications.map((n) => n.id));
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                allSelected ? 'Bỏ chọn hết' : 'Chọn tất cả',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ),
                        ],
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isSelectionMode = !_isSelectionMode;
                              if (!_isSelectionMode) {
                                _selectedIds.clear();
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isSelectionMode
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isSelectionMode
                                    ? const Color(0xFFFCA5A5)
                                    : const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isSelectionMode ? Icons.close_rounded : Icons.checklist_rounded,
                                  size: 14,
                                  color: _isSelectionMode ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isSelectionMode ? 'Thoát' : 'Chọn nhiều',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _isSelectionMode ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!_isSelectionMode) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _handleMarkAllAsRead,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 'ALL', Icons.border_all_rounded, AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      _buildFilterChip('Sự cố SOS', 'SOS', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
                      const SizedBox(width: 6),
                      _buildFilterChip('Bảo trì PM', 'PM', Icons.build_circle_rounded, const Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      _buildFilterChip('Phê duyệt', 'APPROVAL', Icons.verified_user_rounded, const Color(0xFFF59E0B)),
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
                    padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        Icon(Icons.notifications_none_rounded, size: 56, color: Color(0xFFCBD5E1)),
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
                          'Hãy thử chọn bộ lọc khác hoặc vuốt xuống để làm mới dữ liệu',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final isUnread = !item.isRead;
                      final isSelected = _selectedIds.contains(item.id);

                      return Dismissible(
                        key: Key('notification_${item.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Xóa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.delete_forever_rounded, color: Colors.white, size: 22),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Xác nhận xóa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              content: Text('Xóa thông báo "${item.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                                  child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (direction) async {
                          final messenger = ScaffoldMessenger.of(context);
                          await _service.deleteNotification(item.id);
                          if (mounted) {
                            setState(() {
                              _notifications.removeWhere((n) => n.id == item.id);
                              _selectedIds.remove(item.id);
                            });
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa thông báo'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: InkWell(
                          onTap: () => _handleItemClick(item),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFEF2F2)
                                  : (isUnread ? const Color(0xFFF0FDF4) : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFEF4444)
                                    : (isUnread ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                                width: isSelected || isUnread ? 1.4 : 1.0,
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
                                if (_isSelectionMode) ...[
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: const Color(0xFFEF4444),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedIds.add(item.id);
                                        } else {
                                          _selectedIds.remove(item.id);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                _getNotificationIcon(item.type),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                if (isUnread) ...[
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    margin: const EdgeInsets.only(right: 6),
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
                                                      color: const Color(0xFF0F172A),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                _formatTime(item.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF94A3B8),
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                              if (!_isSelectionMode) ...[
                                                const SizedBox(width: 4),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  tooltip: 'Xóa thông báo',
                                                  onPressed: () => _handleDeleteSingle(item),
                                                ),
                                              ],
                                            ],
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
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          bottomNavigationBar: _isSelectionMode && _selectedIds.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã chọn ${_selectedIds.length} thông báo',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _handleDeleteBatch,
                          icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 18),
                          label: Text(
                            'Xóa (${_selectedIds.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
