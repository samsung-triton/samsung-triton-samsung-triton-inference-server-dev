// 헤더 프레임
// 공통 상단 위젯을 모든 페이지에서 띄우기 위한 프레임
import 'package:flutter/material.dart';
import 'package:triton/widgets/button/button_medium.dart';

import 'package:triton/widgets/header/header_nav.dart';
import 'package:triton/widgets/header/server_status.dart';
import 'package:triton/widgets/header/server_control.dart';
import 'package:triton/widgets/header/name_text.dart';
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
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(right: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeaderNav(),
                Row(
                  children: [
                    ServerStatus(status: "running", startTime: DateTime.now().subtract(const Duration(seconds: 25))),
                    const SizedBox(width: 16),
                    ServerControl(
                      //모달 연결
                      onStart: () => print("서버 시작"),
                      onStop: () => print("서버 중지"),
                      onRestart: () => print("서버 재시작"),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 2, height: 24, color: black),
                    const SizedBox(width: 16),
                    const NameText(name: "tester1"),
                    const SizedBox(width: 8),
                    const ButtonMedium(text: "Log Out", backgroundColor: black, textColor: white),
                  ],
                ),
              ],
            ),
          ),
        ),
        elevation: 4,
        shadowColor: black.withValues(alpha: 0.2),
      ),
      body: SafeArea(child: child),
    );
  }
}
