// 로그인 화면
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import '../../widgets/login/login_text_field.dart';
import '../../widgets/login/login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: 서버 로그인 API 연동
      await Future.delayed(const Duration(milliseconds: 300));
      final ok = _idCtrl.text.trim() == 'admin' && _pwCtrl.text == 'admin';

      if (!ok) {
        setState(() => _error = 'Check your account again.');
        return;
      }
      if (mounted) context.go('/dashboard');
    } catch (_) {
      setState(() => _error = 'Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 왼쪽 로고 패널
            if (isWide) ...[
              SizedBox(
                width: 480,
                height: 480,
                child: ClipRRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/login_panel.png',
                        fit: BoxFit.cover, // 패널을 꽉 채우도록
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
            ],

            // 오른쪽 로그인 폼
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Center(child: Text('Welcome', style: T.t20(bold: true).copyWith(fontSize: 40))),
                  const SizedBox(height: 32),

                  LoginTextField(
                    label: 'ID',
                    hintText: 'Please enter your ID.',
                    controller: _idCtrl,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  LoginTextField(
                    label: 'Password',
                    hintText: 'Please enter your Password.',
                    controller: _pwCtrl,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 40),

                  // 에러용 공간 확보
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      height: 24,
                      child: Center(
                        child: _error == null ? const SizedBox.shrink() : Text(_error!, style: T.t16(color: statusRed)),
                      ),
                    ),
                  ),
                  LoginButton(label: 'Login', isLoading: _isLoading, onPressed: _handleLogin),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
