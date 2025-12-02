// 로그인 버튼
import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class LoginButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const LoginButton({super.key, required this.label, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading;

    return SizedBox(
      height: 64,
      width: double.infinity,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primaryNormal,
          foregroundColor: white,
          disabledBackgroundColor: primaryLightest,
          disabledForegroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: T.t20(color: white, bold: true),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.6, color: white))
            : Text(label),
      ),
    );
  }
}
