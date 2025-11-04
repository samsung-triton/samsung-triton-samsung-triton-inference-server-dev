//메뉴 텍스트
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

class MenuText extends StatelessWidget {
  final String label;
  final String to;
  final bool selected;

  const MenuText({super.key, required this.label, required this.to, required this.selected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(to),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 140,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        //margin: const EdgeInsets.only(right: 8),
        child: selected
            ? Text(label, style: T.t16(color: primaryNormal, bold: true))
            : Text(label, style: T.t16(color: black, bold: false)),
      ),
    );
  }
}
