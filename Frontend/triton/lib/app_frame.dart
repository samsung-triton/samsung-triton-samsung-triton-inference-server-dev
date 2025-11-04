// 헤더 프레임
// 공통 상단 위젯을 모든 페이지에서 띄우기 위한 프레임
import 'package:flutter/material.dart';

import 'package:triton/widgets/header/header_nav.dart';

import 'theme/app_colors.dart';

class AppFrame extends StatelessWidget {
  final Widget child;
  const AppFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: Colors.transparent, //그림자 적용 시, 저절로 톤다운 되는것 막기 위함
        toolbarHeight: 48,
        bottom: PreferredSize(preferredSize: Size.fromHeight(0), child: HeaderNav()),
        elevation: 4,
        shadowColor: black.withValues(alpha: 0.2),
      ),
      body: child,
    );
  }
}
