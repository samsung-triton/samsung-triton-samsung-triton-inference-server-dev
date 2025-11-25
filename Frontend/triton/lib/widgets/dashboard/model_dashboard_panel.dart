// lib/widgets/dashboard/model_dashboard_panel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/widgets/dashboard/common_metric_header_bar.dart';
import 'package:triton/widgets/dashboard/model_inference_stats_card.dart';
import 'package:triton/widgets/dashboard/model_latency_chart.dart';
import 'package:triton/widgets/dashboard/model_notification_panel.dart';

import 'package:triton/controller/dashboard/dashboard_controller.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

class ModelDashboardPanel extends StatefulWidget {
  const ModelDashboardPanel({super.key});

  @override
  State<ModelDashboardPanel> createState() => _ModelDashboardPanelState();
}

class _ModelDashboardPanelState extends State<ModelDashboardPanel> {
  @override
  void initState() {
    super.initState();

    final dashCtrl = Get.find<DashboardController>();
    final modelCtrl = Get.find<ModelDashboardController>();

    // 화면 진입 시 SSE 자동 시작
    final id = dashCtrl.selectedModelId.value;
    if (id != null) {
      modelCtrl.restartSse(id);
    }
  }

  @override
  void dispose() {
    // 화면 떠날 때 SSE 자동 해제
    final modelCtrl = Get.find<ModelDashboardController>();
    modelCtrl.onClose();

    super.dispose();
  }

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
          /// Header
          CommonMetricHeaderBar(
            onRefresh: () {
              final id = dashCtrl.selectedModelId.value;
              if (id != null) {
                modelCtrl.restartSse(id);
              }
            },
          ),

          const SizedBox(height: gap),

          /// Main Body
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Left (Inference Stats + Latency Chart)
                Expanded(
                  child: Column(
                    children: [
                      const Expanded(child: ModelInferenceStatsCard()),
                      const SizedBox(height: gap),
                      const Expanded(child: ModelLatencyChart()),
                    ],
                  ),
                ),

                const SizedBox(width: gap),

                /// Right (Notifications Panel)
                const SizedBox(width: rightPanelW, child: ModelNotificationPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
