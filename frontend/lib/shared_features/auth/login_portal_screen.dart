import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_service.dart';

class LoginPortalScreen extends StatefulWidget {
  const LoginPortalScreen({super.key});

  @override
  State<LoginPortalScreen> createState() => _LoginPortalScreenState();
}

class _LoginPortalScreenState extends State<LoginPortalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'supervisor.a@factory.com');
  final _passwordController = TextEditingController(text: '12345678');
  final _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    await StorageService.init();
    final isRemembered = StorageService.getIsRememberMe();
    if (isRemembered) {
      final savedEmail = StorageService.getSavedEmail();
      final savedPassword = await StorageService.getSavedPassword();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        _passwordController.text = savedPassword;
      }
      if (mounted) setState(() => _rememberMe = true);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final accessToken = response['accessToken']?.toString();
      final userData = (response['user'] as Map<String, dynamic>?) ?? {};
      final userRole = userData['role']?.toString();

      try {
        await StorageService.saveRememberedCredentials(
          rememberMe: _rememberMe,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } catch (err) {
        debugPrint('[Auth] Lỗi lưu credentials: $err');
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          await StorageService.saveAuthSession(
            token: accessToken,
            userData: userData,
          );
        } catch (err) {
          debugPrint('[Auth] Lỗi lưu session: $err');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Đăng nhập thành công!',
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      AppRouter.navigateByRole(context, userRole);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thất bại: $errorMessage'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Banner Header Gradient (Wireframe K match)
            _HeaderBanner(height: screenHeight * 0.34),

            // 2. Form Đăng nhập
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _LoginFormCard(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isPasswordVisible: _isPasswordVisible,
                  rememberMe: _rememberMe,
                  isLoading: _isLoading,
                  onTogglePassword: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  onToggleRememberMe: () =>
                      setState(() => _rememberMe = !_rememberMe),
                  onSubmit: _handleLogin,
                ),
              ),
            ),

            const SizedBox(height: 20),
            // 3. Footer Hỗ trợ kỹ thuật
            const _FooterSection(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final double height;
  const _HeaderBanner({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF0F766E), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.0)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'AT',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ASSETTRACK',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Hệ thống Quản lý Lý lịch & Bảo trì Nhà máy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool rememberMe;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleRememberMe;
  final VoidCallback onSubmit;

  const _LoginFormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.rememberMe,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleRememberMe,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Email / Mã nhân viên',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'supervisor.a@factory.com',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
                  ),
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Vui lòng nhập Email hoặc Mã nhân viên'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Mật khẩu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (val.length < 6) return 'Mật khẩu phải từ 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Remember me & Version
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: onToggleRememberMe,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            rememberMe
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 18,
                            color: rememberMe
                                ? const Color(0xFF059669)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Ghi nhớ đăng nhập',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'v1.2.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF059669).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'ĐĂNG NHẬP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_in_talk_rounded,
            size: 15,
            color: Color(0xFF64748B),
          ),
          SizedBox(width: 6),
          Text(
            'Hỗ trợ kỹ thuật: ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            '1900-8888',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
