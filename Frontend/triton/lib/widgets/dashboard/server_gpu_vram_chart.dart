// lib/widgets/dashboard/server_gpu_vram_chart.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/controller/dashboard/server_gpu_controller.dart';

class ServerGpuResourceChart extends StatelessWidget {
  const ServerGpuResourceChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerGpuController>();

    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.vramSeries;

      return Padding(
        padding: const EdgeInsets.all(8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 21,
            minY: 0,
            maxY: 100,
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: primaryDarker, strokeWidth: 1, dashArray: [3, 3]),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(radius: 3, color: primaryDarker, strokeWidth: 0),
                  ),
                );
              }).toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => primaryDarker,
                tooltipBorderRadius: BorderRadius.circular(6),
                tooltipPadding: const EdgeInsets.all(6),
                getTooltipItems: (spots) =>
                    spots.map((s) => LineTooltipItem('${s.y.toInt()}%', T.t12(color: white, bold: true))).toList(),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: lightGray.withOpacity(0.5), strokeWidth: 0.5),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 25,
                  getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: T.t8(color: darkGray)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget: (value, _) {
                    final hour = value.toInt().toString().padLeft(2, '0');
                    return Text('$hour:00', style: T.t8(color: darkGray));
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: false,
                color: primaryDarker,
                barWidth: 1.2,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [primaryDarker.withOpacity(0.9), primaryDarker.withOpacity(0.05)],
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
