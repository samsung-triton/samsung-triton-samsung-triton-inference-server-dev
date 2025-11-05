import 'package:flutter/material.dart';
import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

class NameText extends StatelessWidget {
  final String name;

  const NameText({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final displayName = name;

    return Text(displayName, style: T.t20(color: black, bold: false));
  }
}
