// 사이드바 베이스
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SidebarBase extends StatelessWidget {
  final List<Widget> children;

  // 아이템 사이 간격
  final double gap = 16;

  const SidebarBase({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    // children 사이 gap 추가
    final content = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      content.add(children[i]);
      if (i != children.length - 1) {
        content.add(SizedBox(height: gap));
      }
    }

    return Container(
      width: 300,
      height: double.infinity, // 높이도 화면에 맞춰주기
      color: primaryLightest,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content),
        ),
      ),
    );
  }
}
