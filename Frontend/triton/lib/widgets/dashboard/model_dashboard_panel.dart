import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/widgets/dashboard/common_metric_header_bar.dart';
import 'package:triton/widgets/dashboard/model_inference_stats_card.dart';
import 'package:triton/widgets/dashboard/model_latency_chart.dart';
import 'package:triton/widgets/dashboard/model_notification_panel.dart';

// Controllers
import 'package:triton/controller/dashboard/dashboard_controller.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

/// 🔹 Model Dashboard Panel
/// - Inference Stats, Latency Chart, Notifications
/// - Controller와 연결되어 reactive UI로 동작
class ModelDashboardPanel extends StatelessWidget {
  const ModelDashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    const double gap = 8.0;
    const double rightPanelW = 280.0;

    final dashCtrl = Get.find<DashboardController>();
    final modelCtrl = Get.find<ModelDashboardController>();

    return Padding(
      padding: const EdgeInsets.all(gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ① Header
          CommonMetricHeaderBar(
            onRefresh: () {
              final id = dashCtrl.selectedModelId.value;
              if (id != null) {
                modelCtrl.fetchAll(id.toString());
              }
            },
          ),

          const SizedBox(height: gap),

          // ② Main Body
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Inference Stats + Latency
                Expanded(
                  child: Column(
                    children: [
                      const Expanded(child: ModelInferenceStatsCard()),
                      const SizedBox(height: gap),

                      // 🔹 Latency Chart: 남는 세로 공간을 전부 사용
                      const Expanded(child: ModelLatencyChart()),
                    ],
                  ),
                ),

                const SizedBox(width: gap),

                // Right: Notifications
                const SizedBox(width: rightPanelW, child: ModelNotificationPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
