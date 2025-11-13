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

    return Obx(() {
      final usage = controller.metrics.value.cpuUsage;
      final loading = controller.loading.value;

      return Center(
        child: loading
            ? const CircularProgressIndicator()
            : LayoutBuilder(
                builder: (context, constraints) {
                  final side = constraints.biggest.shortestSide;
                  final radius = side / 4;
                  final ringThickness = 10;
                  final centerSpaceRadius = radius - ringThickness;
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('CPU Usage', style: T.t12(color: darkGray)),
                          Text('${usage.toStringAsFixed(1)}%', style: T.t16(color: primaryDarker, bold: true)),
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
