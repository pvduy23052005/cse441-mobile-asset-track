import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/user_service.dart';
import 'add_user_dialog.dart';

class SupervisorUserManageView extends StatefulWidget {
  const SupervisorUserManageView({super.key});

  @override
  State<SupervisorUserManageView> createState() => _SupervisorUserManageViewState();
}

class _SupervisorUserManageViewState extends State<SupervisorUserManageView> {
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _selectedRoleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final allUsers = await _userService.getUsers();
      final operationalUsers = allUsers.where((u) {
        final r = (u['role'] ?? '').toString().toLowerCase();
        return r == 'operator' || r == 'engineer';
      }).toList();

      if (mounted) {
        setState(() {
          _users = operationalUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final role = (user['role'] ?? '').toString().toLowerCase();
      return _selectedRoleFilter == 'ALL' || role == _selectedRoleFilter.toLowerCase();
    }).toList();
  }

  void _showAddUserDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddUserModal(
        onUserCreated: _fetchUsers,
      ),
    );
  }

  void _confirmDeleteUser(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa tài khoản'),
        content: Text('Bạn có chắc chắn muốn xóa tài khoản của "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _userService.deleteUser(id);
                _fetchUsers();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa người dùng thành công'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${e.toString().replaceAll("Exception: ", "")}'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Xóa Tài Khoản'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Filter Chips Header
          Container(
            width: double.infinity,
            color: AppTheme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'Tất Cả (${_users.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('OPERATOR', 'Công Nhân', icon: Icons.engineering_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip('ENGINEER', 'Kỹ Sư ME', icon: Icons.build_outlined),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppTheme.borderColor),

          // User List Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: AppTheme.mutedForegroundColor.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              'Không có nhân sự nào',
                              style: TextStyle(color: AppTheme.mutedForegroundColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            final role = (user['role'] ?? 'operator').toString().toLowerCase();

                            final bool isEngineer = role == 'engineer';
                            final Color roleBgColor = isEngineer ? const Color(0xFFF0F9FF) : const Color(0xFFECFDF5);
                            final Color roleTextColor = isEngineer ? const Color(0xFF0369A1) : AppTheme.primaryColor;
                            final String roleLabel = isEngineer ? 'Kỹ Sư ME' : 'Công Nhân';
                            final IconData roleIcon = isEngineer ? Icons.build_outlined : Icons.engineering_outlined;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: roleBgColor,
                                      child: Icon(roleIcon, color: roleTextColor, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  user['fullName'] ?? 'Chưa đặt tên',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: AppTheme.foregroundColor,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: roleBgColor,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: roleTextColor.withValues(alpha: 0.3)),
                                                ),
                                                child: Text(
                                                  roleLabel,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: roleTextColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.email_outlined, size: 14, color: AppTheme.mutedForegroundColor),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  user['email'] ?? '',
                                                  style: const TextStyle(fontSize: 13, color: AppTheme.mutedForegroundColor),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
                                      onPressed: () => _confirmDeleteUser(
                                        user['id'] ?? user['uid'] ?? '',
                                        user['fullName'] ?? user['email'] ?? '',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Thêm Nhân Viên', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String roleKey, String label, {IconData? icon}) {
    final isSelected = _selectedRoleFilter == roleKey;
    return ChoiceChip(
      showCheckmark: false,
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryColor : AppTheme.mutedForegroundColor,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedRoleFilter = roleKey),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppTheme.primaryColor : AppTheme.mutedForegroundColor,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
      ),
    );
  }
}
