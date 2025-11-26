// 로그인 텍스트 입력칸 (ID, PW)
import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class LoginTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool hasError;
  final double borderRadius;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  // 비밀번호 입력 확인 속성
  final bool isPassword;
  final bool initialObscure;

  const LoginTextField({
    super.key,
    this.controller,
    this.label = '',
    this.hintText = '',
    this.hasError = false,
    this.borderRadius = 8,
    this.textInputAction,
    this.onSubmitted,
    this.isPassword = false,
    this.initialObscure = true,
  });

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  late final TextEditingController _controller;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _obscure = widget.isPassword ? widget.initialObscure : false;
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.label, style: T.t20(color: darkGray)),
          ),

        // 입력 필드
        Container(
          width: double.infinity,
          height: 64,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(widget.borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controller,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            textAlignVertical: TextAlignVertical.center,

            // PW 마스킹
            obscureText: widget.isPassword ? _obscure : false,

            keyboardType: TextInputType.text,
            maxLines: 1,

            style: T.t20(color: darkGray),

            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: T.t20(color: gray),
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              counterText: '',

              // 비밀번호 보임/안보인 아이콘
              suffixIcon: widget.isPassword
                  ? SizedBox(
                      height: 40,
                      child: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: darkGray, size: 24),
                      ),
                    )
                  : const SizedBox(height: 40, width: 40),
            ),
          ),
        ),
      ],
    );
  }
}
