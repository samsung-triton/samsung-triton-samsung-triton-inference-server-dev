import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';

class ModelNotificationPanel extends StatelessWidget {
  const ModelNotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      ModelNotification(
        'Inference Success',
        'Inference completed successfully for request #147',
        '8 minutes ago',
        statusGreen,
      ),
      ModelNotification('Performance Alert', 'GPU out of memory (Model: ResNet50)', '16 minutes ago', statusYellow),
      ModelNotification('Inference Failure', 'Inference failed for request #132', '24 minutes ago', statusRed),
      ModelNotification(
        'Inference Success',
        'Inference completed successfully for request #123',
        '1 hours ago',
        statusGreen,
      ),
      ModelNotification(
        'Inference Success',
        'Inference completed successfully for request #120',
        '2 hours ago',
        statusGreen,
      ),
    ];

    return CommonInfoCardBase(
      title: "Notification",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: log.color.withOpacity(0.08),
                  border: Border(left: BorderSide(color: log.color, width: 3)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.title, style: T.t12(color: log.color, bold: true)),
                    const SizedBox(height: 4),
                    Text(log.message, style: T.t12(color: black)),
                    const SizedBox(height: 4),
                    Text(log.timeAgo, style: T.t12(color: gray)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ModelNotification {
  final String title;
  final String message;
  final String timeAgo;
  final Color color;

  ModelNotification(this.title, this.message, this.timeAgo, this.color);
}
