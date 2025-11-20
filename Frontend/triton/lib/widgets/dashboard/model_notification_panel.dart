import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';
import 'package:triton/utils/show_alert.dart'; // 🔥 ModalAlert 사용을 위한 import 추가

class ModelNotificationPanel extends StatelessWidget {
  const ModelNotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ModelDashboardController>();

    const double itemHeight = 78;
    const double maxHeight = itemHeight * 10;

    return CommonInfoCardBase(
      title: "Server Notifications",
      child: SizedBox(
        height: maxHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Obx(() {
            final data = c.serverNotifications;

            if (data.isEmpty) {
              return const Center(child: Text("No notifications available"));
            }

            return Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, index) {
                  final log = data[index];

                  // ANSI escape 제거
                  final cleanMessage = log.message.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');

                  final color = _levelColor(log.level);
                  final ts = _formatDateTime(log.ts);

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      border: Border(left: BorderSide(color: color, width: 3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// LEVEL
                        Text(log.level, style: T.t12(color: color, bold: true)),
                        const SizedBox(height: 4),

                        /// MESSAGE (2줄 제한 + 클릭 시 ModalAlert 상세 표시)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              // 🔥 ModalAlert 직접 띄움 (전역 사용)
                              ShowAlert.show(title: log.level, message: cleanMessage);
                            },
                            child: Text(
                              cleanMessage,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: T.t12(color: black),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// TIMESTAMP
                        Text(ts, style: T.t12(color: gray)),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _levelColor(String level) {
    switch (level.toUpperCase()) {
      case "ERROR":
        return statusRed;
      case "WARN":
      case "WARNING":
        return statusYellow;
      default:
        return statusGreen;
    }
  }

  String _formatDateTime(DateTime ts) {
    return "${ts.year}-${ts.month.toString().padLeft(2, '0')}"
        "-${ts.day.toString().padLeft(2, '0')} "
        "${ts.hour.toString().padLeft(2, '0')}:"
        "${ts.minute.toString().padLeft(2, '0')}:"
        "${ts.second.toString().padLeft(2, '0')}";
  }
}
