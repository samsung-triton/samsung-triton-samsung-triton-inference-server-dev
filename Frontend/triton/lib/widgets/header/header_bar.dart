// lib/widgets/frame/header_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/controller/server/server_controller.dart';

import '../../theme/app_colors.dart';

import 'package:triton/widgets/header/header_nav.dart';
import 'package:triton/widgets/header/server_status_container.dart';
import 'package:triton/widgets/header/server_control.dart';
import 'package:triton/widgets/header/name_text.dart';
import 'package:triton/widgets/button/button_medium.dart';

class HeaderBar extends StatefulWidget {
  final double headerH;
  const HeaderBar({super.key, required this.headerH});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  late final ServerController serverController;

  @override
  void initState() {
    super.initState();
    // 헤더 전용 컨트롤러 주입
    serverController = Get.put(ServerController(), permanent: false);
    // 필요 시 최초 상태 조회
    // _hc.refreshStatus();
  }

  @override
  void dispose() {
    // 헤더 영역 벗어날 때 컨트롤러 정리
    Get.delete<ServerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.headerH, maxHeight: widget.headerH),
      child: Container(
        height: widget.headerH,
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
                const ServerStatusContainer(),
                const SizedBox(width: 16),
                const ServerControl(),
                const SizedBox(width: 16),
                // 원래처럼 Container로 구분선
                Container(width: 2, height: 24, color: black),
                const SizedBox(width: 16),
                const NameText(),
                const SizedBox(width: 8),
                const ButtonMedium(text: "Log Out", backgroundColor: black, textColor: white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
