// lib/widgets/header/server_status_chip.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/controller/server/server_controller.dart';

import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

/// 서버 상태 배지
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
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: running ? statusGreen : statusRed, shape: BoxShape.circle),
            ),
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
