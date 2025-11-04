import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import 'package:flutter/services.dart'; // ← 중요: MaxLengthEnforcement 사용

class InputMedium extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool enabled;
  final bool hasError;
  final double width;
  final double borderRadius;
  final EdgeInsets padding;
  final int maxLength;

  const InputMedium({
    Key? key,
    this.hintText = '',
    this.controller,
    this.enabled = true,
    this.hasError = false,
    this.width = 236,
    this.borderRadius = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.maxLength = 200,
  }) : super(key: key);

  @override
  State<InputMedium> createState() => _InputMediumState();
}

class _InputMediumState extends State<InputMedium> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Color _borderColor() {
    if (!widget.enabled) return lightGray;
    if (widget.hasError) return statusRed;
    return lightGray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: _borderColor(), width: 1),
      ),
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 1,
        maxLines: 5,
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced, // 초과 입력 금지
        style: T.t12(color: darkGray),
        cursorColor: primaryNormal,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: T.t12(color: gray),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }
}
