import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import '../../model/dashboard/server_metrics.dart';

class ServerGpuResourceChart extends StatelessWidget {
  final ServerMetrics metrics;
  const ServerGpuResourceChart({super.key, required this.metrics});

  // ✅ 임시 GPU VRAM 데이터 (시계열 Mock Data)
  List<FlSpot> _mockData() {
    return const [
      FlSpot(0, 15),
      FlSpot(3, 35),
      FlSpot(6, 65),
      FlSpot(9, 80),
      FlSpot(12, 55),
      FlSpot(15, 45),
      FlSpot(18, 60),
      FlSpot(21, 75),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 21,
          minY: 0,
          maxY: 100,

          // ✅ hover / click 시 tooltip + line + point 표시 (RAM 그래프 동일 스타일)
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,

            // 🔹 세로선 + 포인트(dot) 스타일
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: primaryDarker, // GPU용 진한 보라톤
                    strokeWidth: 1,
                    dashArray: [3, 3], // 점선
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(radius: 3, color: primaryDarker, strokeWidth: 0),
                  ),
                );
              }).toList();
            },

            // 🔹 tooltip 스타일
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => primaryDarker,
              tooltipBorderRadius: BorderRadius.circular(6),
              tooltipPadding: const EdgeInsets.all(6),
              getTooltipItems: (spots) =>
                  spots.map((s) => LineTooltipItem('${s.y.toInt()}%', T.t12(color: white, bold: true))).toList(),
            ),
          ),

          // ✅ 그래프 축 / 데이터
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
                  return Text(
                    '$hour:00',
                    style: T.t8(color: darkGray),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),

          // ✅ GPU 시계열 데이터
          lineBarsData: [
            LineChartBarData(
              spots: _mockData(),
              isCurved: false, // ✅ 각진 꺾은선 그래프
              color: primaryDarker,
              barWidth: 1.2,
              isStrokeCapRound: false,
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
  }
}
