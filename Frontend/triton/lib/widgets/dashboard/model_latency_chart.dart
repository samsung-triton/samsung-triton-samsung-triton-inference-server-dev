import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';

class ModelLatencyChart extends StatefulWidget {
  const ModelLatencyChart({super.key});

  @override
  State<ModelLatencyChart> createState() => _ModelLatencyChartState();
}

class _ModelLatencyChartState extends State<ModelLatencyChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final List<ModelLatencyData> latencyList = [
      ModelLatencyData('08:00', 20, 40, 120, 30),
      ModelLatencyData('08:10', 25, 30, 100, 25),
      ModelLatencyData('08:20', 10, 30, 40, 20),
      ModelLatencyData('08:30', 15, 50, 90, 25),
      ModelLatencyData('08:40', 5, 20, 30, 15),
    ];

    final totalLatencies = latencyList.map((e) => e.totalLatency).toList();
    final maxVal = totalLatencies.reduce(math.max);
    final niceMaxY = ((maxVal / 50).ceil() * 50).toDouble();

    return CommonInfoCardBase(
      title: 'Model Latency',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ ① 왼쪽 그래프 영역 (오른쪽 padding 추가)
            Expanded(
              flex: 7, // 전체의 약 70%
              child: Padding(
                padding: const EdgeInsets.only(right: 24), // ✅ 오른쪽 여백 추가
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: niceMaxY,
                    minX: 0,
                    maxX: (latencyList.length - 1).toDouble(), // ✅ 실제 데이터까지만 (겹침 방지)
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => FlLine(color: lightGray.withOpacity(0.4), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 50,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            if ((value % 50).abs() > 0.001) {
                              return const SizedBox.shrink();
                            }
                            return Text(value.toInt().toString(), style: T.t12(color: gray));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            // ✅ index 유효 범위만 표시
                            final i = value.round();
                            if (i < 0 || i >= latencyList.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(latencyList[i].time, style: T.t12(color: gray)),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),

                    // ✅ 라인 그래프 데이터
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: false,
                        color: primaryNormal,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(radius: 4, color: primaryNormal, strokeWidth: 0),
                        ),
                        belowBarData: BarAreaData(show: false),
                        spots: List.generate(latencyList.length, (i) => FlSpot(i.toDouble(), totalLatencies[i])),
                      ),
                    ],

                    // ✅ 터치 이벤트 (오른쪽 박스 업데이트)
                    lineTouchData: LineTouchData(
                      enabled: true, // (기본 true지만 명시)
                      handleBuiltInTouches: true, // 내장 터치 처리 유지 (상단 작은 툴팁)
                      // ✅ 오른쪽 고정 박스 갱신: 여기서 touchedIndex를 업데이트
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.lineBarSpots == null ||
                            response.lineBarSpots!.isEmpty) {
                          setState(() => touchedIndex = null);
                          return;
                        }
                        setState(() {
                          touchedIndex = response.lineBarSpots!.first.x.toInt();
                        });
                      },
                      // ✅ 그래프 위 기본 툴팁 스타일(1.1.x 문법)
                      touchTooltipData: LineTouchTooltipData(
                        // tooltipRoundedRadius / tooltipBgColor 는 1.1.x에 없음!
                        getTooltipColor: (_) => primaryNormal.withOpacity(0.85), // 배경색
                        tooltipMargin: 8,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItems: (touchedSpots) {
                          if (touchedSpots.isEmpty) return [];
                          final s = touchedSpots.first;
                          return [
                            LineTooltipItem(
                              s.y.toInt().toString(), // 표시할 값
                              T.t12(color: white, bold: true), // 텍스트 스타일
                            ),
                          ];
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ✅ ② 오른쪽 고정 툴팁 영역
            Expanded(
              flex: 3, // 오른쪽 영역 30%
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryNormal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryNormal.withOpacity(0.4)),
                ),
                child: touchedIndex != null
                    ? _buildTooltip(latencyList[touchedIndex!])
                    : Center(
                        child: Text("데이터를 터치하세요", style: T.t12(color: gray)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 오른쪽 툴팁 내용
  Widget _buildTooltip(ModelLatencyData d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목 부분
        Text("Total Latency", style: T.t16(color: primaryDarker, bold: true)),
        // const SizedBox(height: 2),
        Text(
          "${d.totalLatency.toInt()} ms",
          style: T.t20(color: primaryNormal, bold: true), // ✅ 숫자 강조
        ),
        const SizedBox(height: 12),
        Divider(color: lightGray, thickness: 1),

        // 항목별 상세
        _buildDetailRow("Queue", d.queue),
        _buildDetailRow("Input", d.input),
        _buildDetailRow("Infer", d.infer),
        _buildDetailRow("Output", d.output),
      ],
    );
  }

  // ✅ 세부 항목 행 스타일
  Widget _buildDetailRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: T.t12(color: gray)),
          Text("${value.toInt()} ms", style: T.t12(color: primaryDarker, bold: true)),
        ],
      ),
    );
  }
}

// ✅ 데이터 클래스
class ModelLatencyData {
  final String time;
  final double queue;
  final double input;
  final double infer;
  final double output;

  double get totalLatency => queue + input + infer + output;

  ModelLatencyData(this.time, this.queue, this.input, this.infer, this.output);
}
