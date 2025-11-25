// lib/widgets/dashboard/common_sidebar_card.dart

import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import '../sidebar/sidebar_card_base.dart';

enum SidebarCardType { header, normal }

class CommonSidebarCard extends StatelessWidget {
  final SidebarCardType type;
  final String title;
  final bool status;
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

    final safeCurrent = current ?? 0;
    final safeTotal = total ?? 0;
    final percent = safeTotal == 0 ? 0.0 : (safeCurrent / safeTotal).clamp(0.0, 1.0);
    final percentText = "${(percent * 100).toStringAsFixed(0)}%";

    return SidebarCardBase(
      isActive: active,
      onTap: onTap,
      child: Row(
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$safeCurrent/$safeTotal", style: T.t12(color: gray)),
                    Text(percentText, style: T.t12(color: active ? white : black, bold: true)),
                  ],
                ),
                const SizedBox(height: 4),

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
