import 'package:flutter/material.dart';
import '../../theme/typography.dart';

class ButtonSmall extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback? onPressed;

  const ButtonSmall({
    Key? key,
    required this.text,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.borderColor = Colors.black,
    this.width = 56,
    this.height = 28,
    this.borderRadius = 4,
    this.onPressed,
  }) : super(key: key);

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
          child: Text(text, style: T.t12(color: textColor, bold: false)),
        ),
      ),
    );
  }
}
