// lib/widgets/dashboard/model_notification_panel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';
import 'package:triton/utils/show_alert.dart';

class ModelNotificationPanel extends StatelessWidget {
  const ModelNotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ModelDashboardController>();
    final scrollController = ScrollController();

    const double itemHeight = 78;
    const double maxHeight = itemHeight * 10;

    return CommonInfoCardBase(
      title: "Server Notifications",
      child: SizedBox(
        height: maxHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Obx(() {
            final items = c.serverNotifications;

            if (items.isEmpty) {
              return const Center(child: Text("No notifications available"));
            }

            return Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: scrollController,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, index) {
                  final log = items[index];
                  final cleanMessage = log.message.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _levelColor(log.level).withOpacity(0.08),
                      border: Border(left: BorderSide(color: _levelColor(log.level), width: 3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.level, style: T.t12(color: _levelColor(log.level), bold: true)),
                        const SizedBox(height: 4),

                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
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
                        Text(_formatDateTime(log.ts), style: T.t12(color: gray)),
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

  // -------------------------------------------------------
  // Helpers
  // -------------------------------------------------------

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
    return "${ts.year}-${ts.month.toString().padLeft(2, '0')}-"
        "${ts.day.toString().padLeft(2, '0')} "
        "${ts.hour.toString().padLeft(2, '0')}:"
        "${ts.minute.toString().padLeft(2, '0')}:"
        "${ts.second.toString().padLeft(2, '0')}";
  }
}
