import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

class ModelLatencyChart extends StatefulWidget {
  const ModelLatencyChart({super.key});

  @override
  State<ModelLatencyChart> createState() => _ModelLatencyChartState();
}

class _ModelLatencyChartState extends State<ModelLatencyChart> {
  int? touchedIndex;

  // Y축 최소 범위
  static const double minYAxisRange = 100;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ModelDashboardController>();

    return Obx(() {
      final queue = c.queueLatency;
      final input = c.inputLatency;
      final infer = c.inferLatency;
      final output = c.outputLatency;

      final int len = queue.length;
      if (len == 0) {
        return const CommonInfoCardBase(
          title: 'Model Latency',
          child: Center(child: Text('No latency data')),
        );
      }

      // Time Labels
      final timeLabels = List.generate(len, (i) => "T${i + 1}");

      // Total Latency (cap 제거)
      final totalLatencies = List.generate(len, (i) {
        final raw = queue[i] + input[i] + infer[i] + output[i];
        return raw;
      });

      // max값 계산
      final maxVal = totalLatencies.reduce(math.max);

      // Y축 최대/간격을 데이터 기반으로 동적으로 계산
      final niceMaxY = _calcNiceMaxY(maxVal);
      final intervalY = _calcNiceInterval(niceMaxY);

      return CommonInfoCardBase(
        title: 'Model Latency',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ① Line Chart
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: niceMaxY,

                      minX: 0,
                      maxX: (len - 1).toDouble(),

                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: intervalY, // 동적 interval
                        getDrawingHorizontalLine: (v) => FlLine(color: lightGray.withOpacity(0.4), strokeWidth: 1),
                      ),

                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: intervalY, // 동적 interval
                            getTitlesWidget: (val, meta) {
                              if (intervalY <= 0) {
                                return const SizedBox.shrink(); // 방어 코드
                              }
                              // ✅ 변경: intervalY 기준으로 라벨 표시
                              if ((val % intervalY).abs() > 0.001) {
                                return const SizedBox.shrink();
                              }
                              return Text(val.toInt().toString(), style: T.t8(color: gray));
                            },
                          ),
                        ),

                        // 🔥 bottom time axis (그대로)
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= len) return const SizedBox.shrink();
                              final dt = c.latencyTimestamps[idx].toLocal();
                              return Text(DateFormat('HH:mm').format(dt), style: T.t12(color: gray));
                            },
                          ),
                        ),
                      ),

                      borderData: FlBorderData(show: false),

                      lineBarsData: [
                        LineChartBarData(
                          isCurved: false,
                          color: primaryNormal,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(radius: 4, color: primaryNormal),
                          ),
                          spots: List.generate(len, (i) => FlSpot(i.toDouble(), totalLatencies[i])),
                        ),
                      ],

                      lineTouchData: LineTouchData(
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchCallback: (event, response) {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.lineBarSpots == null ||
                              response.lineBarSpots!.isEmpty) {
                            setState(() => touchedIndex = null);
                            return;
                          }

                          final idx = response.lineBarSpots!.first.x.round();
                          if (idx >= 0 && idx < len) {
                            setState(() => touchedIndex = idx);
                          }
                        },

                        // ↓ 이하 tooltip 쪽은 그대로
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => primaryNormal.withOpacity(0.85),
                          tooltipMargin: 8,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (spots) {
                            if (spots.isEmpty) return [];

                            final idx = spots.first.x.toInt();

                            // RAW 값으로 다시 계산
                            final rawTotal = queue[idx] + input[idx] + infer[idx] + output[idx];

                            return [LineTooltipItem(rawTotal.toStringAsFixed(0), T.t12(color: white, bold: true))];
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ② 오른쪽 상세 박스 (그대로)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryNormal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryNormal.withOpacity(0.4)),
                  ),
                  child: touchedIndex != null
                      ? _buildTooltip(
                          time: timeLabels[touchedIndex!],
                          queue: queue[touchedIndex!],
                          input: input[touchedIndex!],
                          infer: infer[touchedIndex!],
                          output: output[touchedIndex!],
                        )
                      : Center(
                          child: Text("Click on the latency to check", style: T.t12(color: gray)),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Y축 최대값을 데이터 기반 + 최소 100으로 보장
  double _calcNiceMaxY(double maxVal) {
    // 최소 범위 100 보장
    final effectiveMax = maxVal < minYAxisRange ? minYAxisRange : maxVal;

    if (effectiveMax <= 0) return minYAxisRange;

    const targetLines = 6; // 대략 5~7개 정도의 눈금
    final rawStep = effectiveMax / targetLines;

    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final residual = rawStep / magnitude;

    double niceStep;
    if (residual <= 1) {
      niceStep = 1 * magnitude;
    } else if (residual <= 2) {
      niceStep = 2 * magnitude;
    } else if (residual <= 5) {
      niceStep = 5 * magnitude;
    } else {
      niceStep = 10 * magnitude;
    }

    final steps = (effectiveMax / niceStep).ceil();
    final maxY = (steps * niceStep).toDouble();
    return maxY < minYAxisRange ? minYAxisRange : maxY;
  }

  // Y축 눈금 간격도 최소 100 범위 기준으로 계산
  double _calcNiceInterval(double maxY) {
    // 최소 범위 100 보장
    final effectiveMax = maxY < minYAxisRange ? minYAxisRange : maxY;
    if (effectiveMax <= 0) return minYAxisRange / 5;

    const targetLines = 6;
    final rawStep = effectiveMax / targetLines;

    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final residual = rawStep / magnitude;

    double niceStep;
    if (residual <= 1) {
      niceStep = 1 * magnitude;
    } else if (residual <= 2) {
      niceStep = 2 * magnitude;
    } else if (residual <= 5) {
      niceStep = 5 * magnitude;
    } else {
      niceStep = 10 * magnitude;
    }

    return niceStep.toDouble();
  }

  // ---- 오른쪽 상세 박스 ----
  Widget _buildTooltip({
    required String time,
    required double queue,
    required double input,
    required double infer,
    required double output,
  }) {
    final total = queue + input + infer + output;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total Latency", style: T.t16(color: primaryDarker, bold: true)),
        Text("${total.toInt()} ms", style: T.t20(color: primaryNormal, bold: true)),
        const SizedBox(height: 12),
        Divider(color: lightGray),
        _buildRow("Queue", queue),
        _buildRow("Input", input),
        _buildRow("Infer", infer),
        _buildRow("Output", output),
      ],
    );
  }

  Widget _buildRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: T.t12(color: gray)),
          Text("${val.toInt()} ms", style: T.t12(color: primaryDarker, bold: true)),
        ],
      ),
    );
  }
}
