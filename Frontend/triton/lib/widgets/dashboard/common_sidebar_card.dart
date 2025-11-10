import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import '../sidebar/sidebar_card_base.dart';

enum SidebarCardType { header, normal }

class CommonSidebarCard extends StatelessWidget {
  final SidebarCardType type;
  final String title;
  final bool status; // true=green, false=red
  final bool active;
  final VoidCallback? onTap;

  final int? current;
  final int? total;

  const CommonSidebarCard({
    super.key,
    required this.type,
    required this.title,
    this.status = true,
    this.active = false,
    this.onTap,
    this.current,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    // ───────────────────────────────
    // Triton Server 카드 (헤더)
    // ───────────────────────────────
    if (type == SidebarCardType.header) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap, // ✅ 클릭 가능
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: active ? primaryDarkest : white, // ✅ 선택 시 색상 반전
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 4)],
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: T.t20(
                color: active ? white : primaryDarkest, // ✅ 선택 시 글자색 반전
                bold: true,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // ───────────────────────────────
    // 일반 Model / Ensemble 카드
    // ───────────────────────────────
    return SidebarCardBase(
      isActive: active,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ 상태 원
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: status ? statusGreen : statusRed, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),

          // ✅ 오른쪽 전체 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 상단: 모델 이름 (크게)
                Text(
                  title,
                  style: T.t20(color: active ? white : primaryDarkest, bold: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // 하단: 진행 정보 + 바
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 진행 수치 + 퍼센트
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$current/$total", style: T.t12(color: gray)),
                        Text(
                          "${((current! / total!) * 100).toStringAsFixed(0)}%",
                          style: T.t12(color: active ? white : black, bold: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 진행률 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (current! / total!).clamp(0.0, 1.0),
                        backgroundColor: lightGray.withOpacity(0.5),
                        color: primaryNormal,
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
