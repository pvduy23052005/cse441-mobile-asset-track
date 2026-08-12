import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/user_service.dart';

class AddUserModal extends StatefulWidget {
  final VoidCallback onUserCreated;

  const AddUserModal({
    super.key,
    required this.onUserCreated,
  });

  @override
  State<AddUserModal> createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '123456');
  final _userService = UserService();

  String _selectedRole = 'operator';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await _userService.createUser(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
        role: _selectedRole,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onUserCreated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo tài khoản thành công! Người dùng có thể đăng nhập ngay.'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thêm Tài Khoản Nhân Sự Mới',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.foregroundColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Cấp tài khoản cho Công Nhân hoặc Kỹ Sư để đăng nhập hệ thống',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedForegroundColor),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên nhân viên *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email đăng nhập *',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'vidu: operator1@factory.com',
                ),
                validator: (v) => v == null || !v.contains('@') ? 'Vui lòng nhập email hợp lệ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu khởi tạo *',
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Mặc định: 123456',
                ),
                validator: (v) => v == null || v.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò phân quyền *',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'operator',
                    child: Row(
                      children: [
                        Icon(Icons.engineering_outlined, size: 18, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text('Công Nhân Vận Hành (Operator)'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'engineer',
                    child: Row(
                      children: [
                        Icon(Icons.build_outlined, size: 18, color: Color(0xFF0369A1)),
                        SizedBox(width: 8),
                        Text('Kỹ Sư Cơ Điện (ME Engineer)'),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Xác Nhận Tạo Người Dùng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
