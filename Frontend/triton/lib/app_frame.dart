// 헤더 프레임
// 공통 상단 위젯을 모든 페이지에서 띄우기 위한 프레임
import 'package:flutter/material.dart';

import 'package:triton/widgets/header/header_nav.dart';
import 'package:triton/widgets/header/server_status.dart';
import 'package:triton/widgets/header/server_control.dart';
import 'package:triton/widgets/header/name_text.dart';
import 'package:triton/widgets/button/button_small.dart';
import 'theme/app_colors.dart';

class AppFrame extends StatelessWidget {
  final Widget child;
  const AppFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, //safearea 무시
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: Colors.transparent, //그림자 적용 시, 저절로 톤다운 되는것 막기 위함
        toolbarHeight: 48,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(right: 32), //수평 padding 주면서 오른쪽 값은 덮어쓰기
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ---------------- LEFT: 메뉴바 ----------------
                const HeaderNav(),

                // ---------------- RIGHT: 서버상태 + 제어 + 유저정보 ----------------
                Row(
                  children: [
                    const ServerStatus(status: "stopped"),
                    const SizedBox(width: 16),
                    ServerControl(
                      onStart: () => print("서버 시작"),
                      onStop: () => print("서버 중지"),
                      onRestart: () => print("서버 재시작"),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 2, height: 24, color: black), // 구분선
                    const SizedBox(width: 16),
                    const NameText(name: "tester1"),
                    const SizedBox(width: 8),
                    const ButtonSmall(text: "Log Out", backgroundColor: black, textColor: white),
                  ],
                ),
              ],
            ),
          ),
        ),
        elevation: 4,
        shadowColor: black.withValues(alpha: 0.2),
      ),
      body: child,
    );
  }
}
