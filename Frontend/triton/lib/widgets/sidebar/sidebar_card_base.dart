// 사이드바 카드 베이스
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SidebarCardBase extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onTap;

  const SidebarCardBase({super.key, required this.child, this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    // 활성화 비활성화 배경 색상
    const Color baseBg = white;
    const Color activeBg = primaryDarkest;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        // 카드 디자인
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isActive ? activeBg : baseBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: gray, offset: Offset(4, 4), blurRadius: 4)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          // 카드 내용
          child: child,
        ),
      ),
    );
  }
}
