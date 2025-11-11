import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:triton/controller/dashboard/server_ram_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ServerRamUsageChart extends StatelessWidget {
  const ServerRamUsageChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerRamController>();

    return Obx(() {
      final data = controller.ramSeries;
      if (data.isEmpty) {
        return const Center(child: Text('No RAM data available'));
      }

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(8)),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 21,
            minY: 0,
            maxY: 100,
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(color: primaryNormal, strokeWidth: 1, dashArray: [3, 3]),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(radius: 3, color: primaryNormal, strokeWidth: 0),
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => primaryNormal,
                tooltipBorderRadius: BorderRadius.circular(6),
                tooltipPadding: const EdgeInsets.all(6),
                getTooltipItems: (spots) =>
                    spots.map((s) => LineTooltipItem('${s.y.toInt()}%', T.t12(color: white, bold: true))).toList(),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  interval: 6,
                  getTitlesWidget: (value, _) {
                    final hour = value.toInt().toString().padLeft(2, '0');
                    return Text(
                      '$hour:00',
                      style: T.t8(color: darkGray),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: false,
                color: primaryNormal,
                barWidth: 1.2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
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
