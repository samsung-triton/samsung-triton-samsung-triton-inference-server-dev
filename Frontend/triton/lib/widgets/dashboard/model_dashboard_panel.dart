// 모델 대시보드 패널

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

    final id = dashCtrl.selectedModelId.value;
    if (id != null) {
      modelCtrl.restartSse(id);
    }
  }

  @override
  void dispose() {
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

      // 상단 헤더 + 좌측 통계 / 우측 알림 패널
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 상단 헤더 (Reset Time / Last Updated / Update)
          CommonMetricHeaderBar(
            onRefresh: () {
              final id = dashCtrl.selectedModelId.value;
              if (id != null) {
                modelCtrl.restartSse(id);
              }
            },
          ),

          const SizedBox(height: gap),

          // 메인 영역
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측: 추론 통계 + 지연시간 차트
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

                // 우측: 알림 패널
                const SizedBox(width: rightPanelW, child: ModelNotificationPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
