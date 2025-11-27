// 트리톤 서버 컨트롤러
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:triton/controller/server/server_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/utils/modal_util.dart';
import 'package:triton/widgets/modal/modal_confirmation_password.dart';

class ServerControl extends StatelessWidget {
  const ServerControl({super.key});

  @override
  Widget build(BuildContext context) {
    final serverControl = Get.find<ServerController>();

    return Obx(() {
      // 서버 작동 상태
      final status = serverControl.serverStatus.value?.status;
      final busy = serverControl.isBusy.value;

      final isRunning = status == 'running';
      final isStopped = status == 'stopped';

      // 활성/비활성 결정
      final startDisabled = busy || isRunning || status == null;
      final stopDisabled = busy || isStopped || status == null;
      final restartDisabled = busy || isStopped || status == null;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 시작 버튼
          _iconInkButton(
            'assets/icons/start_black.svg',
            disabled: startDisabled,
            onTap: () => serverControl.startServer(),
          ),

          // 정지 버튼
          const SizedBox(width: 12),
          _iconInkButton(
            'assets/icons/stop_black.svg',
            disabled: stopDisabled,
            onTap: () => ModalPortal.open(
              context,
              builder: (context) => const ModalConfirmationPassword(kind: ControlKind.stop),
            ),
          ),

          // 재시작 버튼
          const SizedBox(width: 12),
          _iconInkButton(
            'assets/icons/restart_black.svg',
            disabled: restartDisabled,
            onTap: () => ModalPortal.open(
              context,
              builder: (context) => const ModalConfirmationPassword(kind: ControlKind.restart),
            ),
          ),
        ],
      );
    });
  }

  // 아이콘 버튼틀
  Widget _iconInkButton(String assetPath, {required bool disabled, required VoidCallback onTap}) {
    final svg = SvgPicture.asset(
      assetPath,
      fit: BoxFit.contain,
      colorFilter: disabled ? ColorFilter.mode(lightGray, BlendMode.srcIn) : null,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        hoverColor: Colors.transparent,
        child: Container(width: 24, height: 24, alignment: Alignment.center, child: svg),
      ),
    );
  }
}
