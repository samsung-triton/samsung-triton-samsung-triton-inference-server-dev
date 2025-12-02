// 기본 텍스트 인풋
import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class InputType extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool enabled;
  final bool hasError;
  final bool readOnly;
  final bool enableInteractiveSelection;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const InputType({
    super.key,
    this.hintText = '',
    this.controller,
    this.enabled = true,
    this.hasError = false,
    this.readOnly = false,
    this.enableInteractiveSelection = true,
    this.width = 104,
    this.height = 24,
    this.borderRadius = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.onTap,
  });

  Color _borderColor() {
    // 비활성화
    if (!enabled) return lightGray;
    // 에러 상태
    if (hasError) return statusRed;
    // 기본 border
    return lightGray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: _borderColor(), width: 1),
      ),
      padding: padding,
      child: TextField(
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        enableInteractiveSelection: enableInteractiveSelection,
        onTap: onTap,
        style: T.t12(color: darkGray, bold: false),
        cursorColor: primaryNormal,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hintText,
          hintStyle: T.t12(color: gray, bold: false),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
