import 'package:flutter/material.dart';
import 'package:triton/widgets/dashboard/common_metric_header_bar.dart';
import 'package:triton/widgets/dashboard/model_inference_stats_card.dart';
import 'package:triton/widgets/dashboard/model_latency_chart.dart';
import 'package:triton/widgets/dashboard/model_notification_panel.dart';

class ModelDashboardPanel extends StatelessWidget {
  const ModelDashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    const double gap = 8.0;
    const double rightPanelW = 280.0;

    return Padding(
      padding: const EdgeInsets.all(gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ Header (상단 고정)
          const SizedBox(child: CommonMetricHeaderBar()),
          const SizedBox(height: gap),

          // ✅ 아래는 Row로 나눠서 좌/우 분할
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측: 통계 카드 + 차트
                Expanded(
                  child: Column(
                    children: const [
                      Expanded(child: ModelInferenceStatsCard()),
                      SizedBox(height: gap),
                      Expanded(child: ModelLatencyChart()),
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
