// 서버 CPU 사용률 차트

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';

class ServerCpuUsageChart extends StatelessWidget {
  const ServerCpuUsageChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerDashboardController>();

    // CPU 사용률을 파이차트로 표시
    return Obx(() {
      final usage = controller.metrics.value.cpuUsage;

      return Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 차트 크기 기준값
            final side = constraints.biggest.shortestSide;

            // 차트 반지름
            final radius = side / 4;

            // 파이 두께
            final ringThickness = 10;

            // 가운데 여백 크기
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

                      // 사용률 / 나머지 비율
                      sections: [
                        PieChartSectionData(color: Colors.green, value: usage, title: '', radius: radius),
                        PieChartSectionData(
                          color: lightGray,
                          value: (100 - usage).clamp(0, 100).toDouble(),
                          title: '',
                          radius: radius,
                        ),
                      ],
                    ),
                  ),
                ),

                // CPU Usage 텍스트
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CPU Usage', style: T.t12(color: darkGray)),
                    Text('${usage.toStringAsFixed(2)}%', style: T.t16(color: primaryDarker, bold: true)),
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
