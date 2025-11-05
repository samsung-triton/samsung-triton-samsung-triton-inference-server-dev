import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class FilterText extends StatelessWidget {
  final String label;
  final double? width;
  final double? height;
  final Color? borderColor;
  final TextStyle? textStyle;

  const FilterText({
    super.key,
    required this.label,
    this.width,
    this.height,
    this.borderColor = primaryDarkest, // secondary-darkest
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 128,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                width: 1,
                color: primaryDarkest, // 기존 색상 그대로 사용
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [Text(label, style: T.t12(color: black, bold: false))],
          ),
        ),
      ],
    );
  }
}
