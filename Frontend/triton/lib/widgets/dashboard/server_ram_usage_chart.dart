import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';
import 'package:intl/intl.dart';

class ServerRamUsageChart extends StatelessWidget {
  const ServerRamUsageChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerDashboardController>();

    return Obx(() {
      final data = controller.ramSeries;
      final timestamps = controller.ramTimestamps;

      if (data.isEmpty) {
        return const Center(child: Text('No RAM data available'));
      }

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

            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: true,
              horizontalInterval: 25, // 0, 25, 50, 75, 100%
              verticalInterval: 1, // x축 5등분
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: darkGray.withOpacity(0.3), strokeWidth: 1, dashArray: [6, 6]),
              getDrawingVerticalLine: (value) =>
                  FlLine(color: darkGray.withOpacity(0.25), strokeWidth: 1, dashArray: [6, 6]),
            ),

            lineTouchData: LineTouchData(
              enabled: true,
              getTouchedSpotIndicator: (barData, idx) => idx.map((index) {
                return TouchedSpotIndicatorData(FlLine(color: primaryNormal, dashArray: [3, 3]), FlDotData(show: true));
              }).toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) =>
                    spots.map((s) => LineTooltipItem('${s.y.toStringAsFixed(2)}%', T.t12(color: white))).toList(),
              ),
            ),

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
                  interval: 1, // 🔥 고정 간격 대신 자동 조정
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= timestamps.length) return const SizedBox.shrink();

                    final t = timestamps[index];
                    return Text(DateFormat("HH:mm").format(t), style: T.t8(color: darkGray));
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),

            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: false,
                color: primaryNormal,
                barWidth: 1.2,
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
