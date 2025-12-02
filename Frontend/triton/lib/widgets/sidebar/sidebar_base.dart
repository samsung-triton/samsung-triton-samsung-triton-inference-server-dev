// 사이드바 베이스
import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';

class SidebarBase extends StatelessWidget {
  final List<Widget> children;

  // 카드 사이 간격
  final double gap = 16;

  const SidebarBase({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    // 카드 사이 gap 추가
    final content = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      content.add(children[i]);
      if (i != children.length - 1) {
        content.add(SizedBox(height: gap));
      }
    }

    return Container(
      width: 300,
      height: double.infinity,
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
