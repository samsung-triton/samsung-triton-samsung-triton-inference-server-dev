// lib/widgets/dashboard/common_info_card_base.dart

import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class CommonInfoCardBase extends StatelessWidget {
  final String title;
  final String? usageText;
  final Widget child;

  const CommonInfoCardBase({super.key, required this.title, this.usageText, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryDarkest, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: T.t20(color: black, bold: true)),
                if (usageText != null) Text(usageText!, style: T.t16(color: black)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
