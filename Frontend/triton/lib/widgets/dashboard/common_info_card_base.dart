// 공통 정보 카드 베이스

import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class CommonInfoCardBase extends StatelessWidget {
  // 카드 제목
  final String title;

  // 우측 상단 보조 텍스트 (usage, 단위 등)
  final String? usageText;

  // 카드 내부 위젯
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

        // 상단 제목 / 보조 텍스트 + 내부 콘텐츠
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: T.t20(color: black, bold: true)),

                // 사용량/단위 문구
                if (usageText != null) Text(usageText!, style: T.t16(color: black)),
              ],
            ),

            const SizedBox(height: 12),

            // 내부 콘텐츠 영역 (child)
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
