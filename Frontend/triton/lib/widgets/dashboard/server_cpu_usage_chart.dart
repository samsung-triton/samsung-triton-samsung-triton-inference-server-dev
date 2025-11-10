import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import '../../model/dashboard/server_metrics.dart';

class ServerCpuUsageChart extends StatelessWidget {
  final ServerMetrics metrics;
  const ServerCpuUsageChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final double usage = metrics.cpuUsage;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 부모의 가용 크기 중 더 작은 값으로 정사각 사이즈 결정
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final side = math.min(w, h);

        // 도넛 두께/간격을 사이즈에 비례해서 설정
        final radius = side / 4; // 바깥 반지름
        final ringThickness = 10;
        final centerSpaceRadius = radius - ringThickness;
        final sectionGap = side * 0.01; // 섹션 사이 간격

        return Center(
          child: Stack(
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
          ),
        );
      },
    );
  }
}
