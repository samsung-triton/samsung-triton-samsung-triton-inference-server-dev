import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';
import 'package:triton/widgets/dashboard/model_metrics.dart';

class ModelNotificationPanel extends StatelessWidget {
  const ModelNotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ModelDashboardController>();

    return CommonInfoCardBase(
      title: "Notification",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Scrollbar(
          thumbVisibility: true,
          child: Obx(() {
            final List<NotificationLog> data = c.notifications;

            if (data.isEmpty) {
              return const Center(child: Text("No notifications available"));
            }

            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final log = data[index];
                final color = _levelColor(log.level);

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
                      // LEVEL (INFO / WARN / ERROR)
                      Text(log.level, style: T.t12(color: color, bold: true)),
                      const SizedBox(height: 4),

                      // MESSAGE
                      Text(log.message, style: T.t12(color: black)),

                      const SizedBox(height: 4),

                      // Timestamp (optional)
                      Text(_formatTimeAgo(log.timestamp), style: T.t12(color: gray)),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

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

  String _formatTimeAgo(String isoString) {
    if (isoString.isEmpty) return "-";

    final time = DateTime.tryParse(isoString);
    if (time == null) return "-";

    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    return "${diff.inDays} days ago";
  }
}
