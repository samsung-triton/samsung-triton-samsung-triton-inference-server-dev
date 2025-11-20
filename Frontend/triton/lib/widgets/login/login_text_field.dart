// 로그인 텍스트 입력칸 (ID, PW)
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

class LoginTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool hasError;
  final double borderRadius;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  // 비밀번호 관련 세팅
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

  // 초기화
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _obscure = widget.isPassword ? widget.initialObscure : false;
  }

  // 삭제
  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  // 생성 빌드
  @override
  Widget build(BuildContext context) {
    // 텍스트 필드
    final textField = Container(
      width: double.infinity,
      height: 64,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(widget.borderRadius)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,

        // 중앙정렬
        textAlignVertical: TextAlignVertical.center,

        // PW일 때만 마스킹
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
    );

    // 최종 위젯 리턴
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨이 있으면 라벨 표시
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.label, style: T.t20(color: darkGray)),
          ),
        textField,
      ],
    );
  }
}
