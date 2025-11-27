// 서버 GPU Utilization 차트

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';

class ServerGpuUtilizationChart extends StatelessWidget {
  const ServerGpuUtilizationChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerDashboardController>();

    // GPU 사용률 파이차트로 표시
    return Obx(() {
      final gpu = controller.metrics.value.gpuUtilization;

      return Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 차트 크기 기준값
            final side = constraints.biggest.shortestSide;

            // 차트 반지름
            final radius = side / 4;

            // 파이 두께
            final ringThickness = 10;

            // 가운데 공간 크기
            final centerSpaceRadius = radius - ringThickness;

            // 섹션 간격
            final sectionGap = side * 0.01;

            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: side,
                  height: side,
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      centerSpaceRadius: centerSpaceRadius,
                      sectionsSpace: sectionGap,

                      // GPU 사용률 / 잔여 비율
                      sections: [
                        PieChartSectionData(color: primaryNormal, value: gpu, title: '', radius: radius),
                        PieChartSectionData(
                          color: lightGray,
                          value: (100 - gpu).clamp(0, 100).toDouble(),
                          title: '',
                          radius: radius,
                        ),
                      ],
                    ),
                  ),
                ),

                // 중앙 텍스트 표시
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('GPU Util', style: T.t12(color: darkGray)),
                    Text('${gpu.toStringAsFixed(2)}%', style: T.t16(color: primaryDarker, bold: true)),
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
