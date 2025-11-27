// 공통 사이드바 카드

import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import '../sidebar/sidebar_card_base.dart';

enum SidebarCardType { header, normal }

class CommonSidebarCard extends StatelessWidget {
  // 카드 타입 (header / normal)
  final SidebarCardType type;

  // 카드 타이틀
  final String title;

  // 현재 선택된 카드인지 여부
  final bool active;

  // 클릭 이벤트
  final VoidCallback? onTap;

  // 진행도 계산용 현재/전체
  final int? current;
  final int? total;

  const CommonSidebarCard({
    super.key,
    required this.type,
    required this.title,
    this.active = false,
    this.onTap,
    this.current,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    // 헤더 카드 (굵은 타이틀 스타일)
    if (type == SidebarCardType.header) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: active ? primaryDarkest : white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 4)],
            ),
            alignment: Alignment.center,
            child: Text(title, style: T.t20(color: active ? white : primaryDarkest, bold: true)),
          ),
        ),
      );
    }

    // 안전값 처리
    final safeCurrent = current ?? 0;
    final safeTotal = total ?? 0;

    // 진행률
    final percent = safeTotal == 0 ? 0.0 : (safeCurrent / safeTotal).clamp(0.0, 1.0);
    final percentText = "${(percent * 100).toStringAsFixed(0)}%";

    // 일반 카드 (진행률 바 포함)
    return SidebarCardBase(
      isActive: active,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀
                Text(
                  title,
                  style: T.t20(color: active ? white : primaryDarkest, bold: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // 현재 / 전체 + 퍼센트
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$safeCurrent/$safeTotal", style: T.t12(color: gray)),
                    Text(percentText, style: T.t12(color: active ? white : black, bold: true)),
                  ],
                ),

                const SizedBox(height: 4),

                // 진행률 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: lightGray.withOpacity(0.5),
                    color: primaryNormal,
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
