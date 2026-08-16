import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/user_service.dart';
import 'add_user_dialog.dart';
import 'user_card.dart';

class SupervisorUserManageView extends StatefulWidget {
  const SupervisorUserManageView({super.key});

  @override
  State<SupervisorUserManageView> createState() =>
      _SupervisorUserManageViewState();
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
      return _selectedRoleFilter == 'ALL' ||
          role == _selectedRoleFilter.toLowerCase();
    }).toList();
  }

  void _showAddUserDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddUserModal(onUserCreated: _fetchUsers),
    );
  }

  void _confirmDeleteUser(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận xóa tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text('Bạn có chắc chắn muốn xóa tài khoản của "$name"?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: AppTheme.borderColor),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      color: AppTheme.mutedForegroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                          content: Text(
                            'Lỗi: ${e.toString().replaceAll("Exception: ", "")}',
                          ),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Xác Nhận',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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
                  _buildFilterChip(
                    'OPERATOR',
                    'Công Nhân',
                    icon: Icons.engineering_outlined,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'ENGINEER',
                    'Kỹ Sư ME',
                    icon: Icons.build_outlined,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.mutedForegroundColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không có nhân sự nào',
                          style: TextStyle(
                            color: AppTheme.mutedForegroundColor,
                            fontWeight: FontWeight.w600,
                          ),
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
                        return UserCard(
                          user: user,
                          onDelete: () => _confirmDeleteUser(
                            user['id'] ?? user['uid'] ?? '',
                            user['fullName'] ?? user['email'] ?? '',
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_rounded),
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
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.mutedForegroundColor,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedRoleFilter = roleKey),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? AppTheme.primaryColor
            : AppTheme.mutedForegroundColor,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
      ),
    );
  }
}
