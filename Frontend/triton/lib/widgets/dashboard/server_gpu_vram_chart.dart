// 서버 GPU VRAM 시계열 차트

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';
import 'package:intl/intl.dart';

class ServerGpuResourceChart extends StatelessWidget {
  const ServerGpuResourceChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerDashboardController>();

    // GPU VRAM 리스트 / timestamp
    return Obx(() {
      final data = controller.gpuVramSeries;
      final timestamps = controller.gpuVramTimestamps;

      // 데이터 없음
      if (data.isEmpty) {
        return const Center(child: Text('No VRAM data available'));
      }

      // X축 범위
      final minX = 0.0;
      final maxX = (data.length - 1).toDouble();

      return Container(
        padding: const EdgeInsets.all(8),
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: 0,
            maxY: 100,

            // 그리드 라인
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: true,
              horizontalInterval: 25,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: darkGray.withOpacity(0.3), strokeWidth: 1, dashArray: [6, 6]),
              getDrawingVerticalLine: (value) =>
                  FlLine(color: darkGray.withOpacity(0.25), strokeWidth: 1, dashArray: [6, 6]),
            ),

            // 터치 / 툴팁
            lineTouchData: LineTouchData(
              enabled: true,
              getTouchedSpotIndicator: (barData, idxList) => idxList.map((idx) {
                return TouchedSpotIndicatorData(FlLine(color: primaryNormal, dashArray: [3, 3]), FlDotData(show: true));
              }).toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) =>
                    spots.map((s) => LineTooltipItem('${s.y.toStringAsFixed(2)}%', T.t12(color: white))).toList(),
              ),
            ),

            // 축 라벨
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 25,
                  getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: T.t8(color: darkGray)),
                ),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= timestamps.length) return const SizedBox.shrink();

                    // timestamp → HH:mm
                    final t = timestamps[idx].toLocal();
                    return Text(DateFormat("HH:mm").format(t), style: T.t8(color: darkGray));
                  },
                ),
              ),

              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),

            // 라인 그래프 데이터
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: false,
                color: primaryNormal,
                barWidth: 1.2,
                dotData: FlDotData(show: false),

                // 라인 하단 영역(그라데이션)
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [primaryLighter.withOpacity(0.8), primaryLighter.withOpacity(0.05)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
