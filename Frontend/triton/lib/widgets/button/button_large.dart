// 큰 크기 버튼
import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ButtonLarge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final bool isbold;
  final VoidCallback? onPressed;

  const ButtonLarge({
    super.key,
    required this.text,
    this.backgroundColor = primaryNormal,
    this.textColor = Colors.white,
    this.borderColor,
    this.width = 88,
    this.height = 44,
    this.borderRadius = 4,
    this.isbold = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
          ),
          child: Text(
            text,
            style: T.t16(color: textColor, bold: isbold),
          ),
        ),
      ),
    );
  }
}
