// lib/widgets/dashboard/model_latency_chart.dart

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

  static const double minYAxisRange = 100;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ModelDashboardController>();

    return Obx(() {
      final queue = c.queueLatency;
      final input = c.inputLatency;
      final infer = c.inferLatency;
      final output = c.outputLatency;

      final len = queue.length;

      if (len == 0) {
        return const CommonInfoCardBase(
          title: 'Model Latency',
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final totalLatencies = List.generate(len, (i) => queue[i] + input[i] + infer[i] + output[i]);

      final maxVal = totalLatencies.reduce(math.max);
      final niceMaxY = _calcNiceMaxY(maxVal);
      final intervalY = _calcNiceInterval(niceMaxY);

      return CommonInfoCardBase(
        title: 'Model Latency',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        horizontalInterval: intervalY,
                        getDrawingHorizontalLine: (v) => FlLine(color: lightGray.withOpacity(0.4), strokeWidth: 1),
                      ),

                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: intervalY,
                            getTitlesWidget: (val, _) {
                              if ((val % intervalY).abs() > 0.001) {
                                return const SizedBox.shrink();
                              }
                              return Text(val.toInt().toString(), style: T.t8(color: gray));
                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= len) return const SizedBox.shrink();

                              if (c.latencyTimestamps.isEmpty) {
                                return Text("T${idx + 1}", style: T.t12(color: gray));
                              }

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
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: primaryNormal),
                          ),
                          spots: List.generate(len, (i) => FlSpot(i.toDouble(), totalLatencies[i])),
                        ),
                      ],

                      lineTouchData: LineTouchData(
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchCallback: (event, response) {
                          if (!event.isInterestedForInteractions ||
                              response?.lineBarSpots == null ||
                              response!.lineBarSpots!.isEmpty) {
                            setState(() => touchedIndex = null);
                            return;
                          }

                          final idx = response.lineBarSpots!.first.x.round();
                          if (idx >= 0 && idx < len) {
                            setState(() => touchedIndex = idx);
                          }
                        },
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => primaryNormal.withOpacity(0.85),
                          tooltipMargin: 8,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (spots) {
                            if (spots.isEmpty) return [];

                            final idx = spots.first.x.toInt();
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

  double _calcNiceMaxY(double maxVal) {
    final effectiveMax = maxVal < minYAxisRange ? minYAxisRange : maxVal;

    const targetLines = 6;
    final rawStep = effectiveMax / targetLines;

    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final residual = rawStep / magnitude;

    double step;
    if (residual <= 1)
      step = magnitude;
    else if (residual <= 2)
      step = 2 * magnitude;
    else if (residual <= 5)
      step = 5 * magnitude;
    else
      step = 10 * magnitude;

    final maxY = (effectiveMax / step).ceil() * step;
    return maxY < minYAxisRange ? minYAxisRange : maxY;
  }

  double _calcNiceInterval(double maxY) {
    final effectiveMax = maxY < minYAxisRange ? minYAxisRange : maxY;

    const targetLines = 6;
    final rawStep = effectiveMax / targetLines;

    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final residual = rawStep / magnitude;

    if (residual <= 1) return magnitude;
    if (residual <= 2) return 2 * magnitude;
    if (residual <= 5) return 5 * magnitude;
    return 10 * magnitude;
  }

  Widget _buildTooltip({required double queue, required double input, required double infer, required double output}) {
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
