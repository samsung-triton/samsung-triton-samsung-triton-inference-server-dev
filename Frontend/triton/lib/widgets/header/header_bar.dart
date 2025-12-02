// 전체 헤더 바
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:triton/controller/auth/auth_controller.dart';
import 'package:triton/controller/server/server_controller.dart';
import 'package:triton/router.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/widgets/button/button_medium.dart';
import 'package:triton/widgets/header/header_nav.dart';
import 'package:triton/widgets/header/name_text.dart';
import 'package:triton/widgets/header/server_control.dart';
import 'package:triton/widgets/header/server_status_container.dart';

class HeaderBar extends StatefulWidget {
  final double headerH;
  const HeaderBar({super.key, required this.headerH});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  final ServerController serverController = Get.put(ServerController(), permanent: true);
  final _auth = Get.find<AuthController>();

  // 계정 정보 확인을 위한 저장소
  final _authStorage = GetStorage('auth');

  @override
  void dispose() {
    Get.delete<ServerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // role 확인
    final role = _authStorage.read<String>('role') ?? '';

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
            // 좌측 네비게이션 (DEVEL인 경우에만 보임)
            if (role == 'DEVEL') const HeaderNav() else const SizedBox(width: 300),

            // 우측 서버 관리
            Row(
              children: [
                // 트리톤 서버 상태 확인
                const ServerStatusContainer(),
                const SizedBox(width: 16),

                // 트리톤 서버 컨트롤
                const ServerControl(),
                const SizedBox(width: 16),
                Container(width: 2, height: 24, color: black),
                const SizedBox(width: 16),

                // 유저 아이디
                const NameText(),
                const SizedBox(width: 8),

                // 로그아웃 버튼
                ButtonMedium(
                  text: 'Log Out',
                  onPressed: () {
                    _auth.logout();
                    if (mounted) {
                      context.go(Routes.login);
                    }
                  },
                  backgroundColor: black,
                  textColor: white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
