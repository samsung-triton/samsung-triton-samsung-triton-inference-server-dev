// 트리톤 서버 상태 좋회
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/server/server_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ServerStatusContainer extends StatelessWidget {
  const ServerStatusContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final serverController = Get.find<ServerController>();

    return Obx(() {
      final status = serverController.serverStatus.value?.status ?? 'stopped';
      final running = status == 'running';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: running ? black : lightGray, borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // on/off 색상
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: running ? statusGreen : statusRed, shape: BoxShape.circle),
            ),

            // 서버 작동 시간
            Text(
              running ? serverController.uptimeHms.value : 'stopped',
              style: T.t16(color: running ? white : black, bold: false),
            ),
          ],
        ),
      );
    });
  }
}
