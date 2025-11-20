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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: active ? primaryDarkest : white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 4)],
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: T.t20(color: active ? white : primaryDarkest, bold: true),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // ───────────────────────────────
    // 안전한 계산 추가 (NULL SAFE)
    // ───────────────────────────────
    final safeCurrent = current ?? 0;
    final safeTotal = total ?? 0;

    // 0/0이면 percent = 0
    double percent;
    if (safeTotal == 0) {
      percent = 0.0;
    } else {
      percent = (safeCurrent / safeTotal).clamp(0.0, 1.0);
    }

    final percentText = "${(percent * 100).toStringAsFixed(0)}%";

    // UI 렌더링
    return SidebarCardBase(
      isActive: active,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: T.t20(color: active ? white : primaryDarkest, bold: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // current / total + percent
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$safeCurrent/$safeTotal", style: T.t12(color: gray)),
                        Text(percentText, style: T.t12(color: active ? white : black, bold: true)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Progress bar
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
