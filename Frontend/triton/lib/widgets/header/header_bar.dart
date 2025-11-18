// 전체 헤더 바
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:triton/router.dart';
import 'package:triton/controller/auth/auth_controller.dart';
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
  final ServerController serverController = Get.put(ServerController(), permanent: true);
  final _auth = Get.find<AuthController>();
  final _authStorage = GetStorage('auth');

  @override
  void dispose() {
    Get.delete<ServerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            if (role == 'DEVEL') const HeaderNav() else const SizedBox(width: 300),

            Row(
              children: [
                const ServerStatusContainer(),
                const SizedBox(width: 16),
                const ServerControl(),
                const SizedBox(width: 16),
                Container(width: 2, height: 24, color: black),
                const SizedBox(width: 16),
                const NameText(),
                const SizedBox(width: 8),
                ButtonMedium(
                  text: 'Log Out',
                  onPressed: () {
                    _auth.logout(); // 여기서 Storage도 같이 정리됨
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
