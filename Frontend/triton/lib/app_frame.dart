// 프로젝트 공통 프레임: 헤더 고정
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:triton/widgets/header/header_nav.dart';
import 'package:triton/widgets/header/server_status.dart';
import 'package:triton/widgets/header/server_control.dart';
import 'package:triton/widgets/header/name_text.dart';
import 'package:triton/widgets/button/button_medium.dart';

import 'router.dart';
import 'theme/app_colors.dart';

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
                if (showHeader) Positioned(left: 0, right: 0, top: 0, height: headerH, child: _HeaderBar()),

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

// 헤더바
class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppFrame.minW,
        minHeight: AppFrame.headerH,
        maxHeight: AppFrame.headerH,
      ),
      child: Container(
        height: AppFrame.headerH,
        padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(right: 32),
        decoration: BoxDecoration(
          color: white,
          boxShadow: [BoxShadow(color: black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const HeaderNav(),
            Row(
              children: [
                ServerStatus(status: "running", startTime: DateTime.now().subtract(const Duration(seconds: 25))),
                const SizedBox(width: 16),
                // TODO: 임시 콜백(서버 제어 API 연동 전)
                ServerControl(
                  onStart: () => print("서버 시작"),
                  onStop: () => print("서버 중지"),
                  onRestart: () => print("서버 재시작"),
                ),
                const SizedBox(width: 16),
                Container(width: 2, height: 24, color: black),
                const SizedBox(width: 16),
                const NameText(),
                const SizedBox(width: 16),
                const ButtonMedium(text: "Log Out", backgroundColor: black, textColor: white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
