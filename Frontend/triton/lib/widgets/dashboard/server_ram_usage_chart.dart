import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import '../../model/dashboard/server_metrics.dart';

class ServerRamUsageChart extends StatelessWidget {
  final ServerMetrics metrics;
  const ServerRamUsageChart({super.key, required this.metrics});

  // ✅ 임시 RAM 시계열 데이터 (Mock)
  List<FlSpot> _mockData() {
    return const [
      FlSpot(0, 10),
      FlSpot(3, 25),
      FlSpot(6, 55),
      FlSpot(9, 75),
      FlSpot(12, 45),
      FlSpot(15, 60),
      FlSpot(18, 40),
      FlSpot(21, 70),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(8)),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 21,
          minY: 0,
          maxY: 100,

          // ✅ hover / click 시 tooltip + line + point 표시
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,

            // 🔹 세로선 + 포인트(dot) 스타일
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: primaryNormal, // 세로선 색상
                    strokeWidth: 1, // 얇게
                    dashArray: [3, 3], // 점선
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3, // 포인트 크기 작게
                      color: primaryNormal, // 포인트 색상
                      strokeWidth: 0, // 외곽선 없음
                    ),
                  ),
                );
              }).toList();
            },

            // 🔹 숫자 박스(tooltip)r
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => primaryNormal,
              tooltipBorderRadius: BorderRadius.circular(6),
              tooltipPadding: const EdgeInsets.all(6),
              getTooltipItems: (spots) =>
                  spots.map((s) => LineTooltipItem('${s.y.toInt()}%', T.t12(color: white, bold: true))).toList(),
            ),
          ),

          // ✅ 그래프 축 / 데이터
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
              spots: _mockData(),
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
  }
}
