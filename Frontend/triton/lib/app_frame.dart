// 프로젝트 공통 프레임: 헤더 고정
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

import './widgets/header/header_bar.dart';

class AppFrame extends StatelessWidget {
  const AppFrame({super.key, required this.child});
  final Widget child;

  // 화면과 헤더 최소 가로/세로 설정
  static const double minW = 1280;
  static const double minH = 720;
  static const double headerH = 48;

  @override
  Widget build(BuildContext context) {
    // 로그인 스크린인지 확인 후 헤더 유무 설정
    final loc = GoRouterState.of(context).matchedLocation;
    final bool showHeader = !loc.startsWith(Routes.login);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          // 스크롤이 필요한지 계산
          final bool needsW = c.maxWidth < minW;
          final bool needsH = c.maxHeight < (minH - (showHeader ? headerH : 0));

          // 실제 크기 계산
          final double targetW = needsW ? minW : c.maxWidth;
          final double usableH = needsH ? (minH - (showHeader ? headerH : 0)) : c.maxHeight;

          // 헤더를 포함한 전체 페이지
          Widget page = SizedBox(
            width: targetW,
            height: usableH + (showHeader ? headerH : 0),
            child: Stack(
              children: [
                // 헤더 위치 고정
                if (showHeader)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: headerH,
                    child: HeaderBar(headerH: headerH),
                  ),

                // 자식 페이지
                Positioned.fill(
                  // 헤더가 있는 경우 위를 벌려줌
                  top: showHeader ? headerH : 0,
                  // 수직 스크롤
                  child: needsH
                      ? Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: targetW,
                              height: usableH,
                              child: child, // 라우트된 자식 페이지
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(width: targetW, height: usableH, child: child),
                        ),
                ),
              ],
            ),
          );

          // 리턴 + 수평 스크롤
          final Widget content = needsW
              ? Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: page),
                )
              : Align(alignment: Alignment.topCenter, child: page);

          return SafeArea(child: content);
        },
      ),
    );
  }
}
