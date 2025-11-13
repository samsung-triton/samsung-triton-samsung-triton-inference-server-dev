import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'dart:math' as math;

class ModelGaugeCard extends StatelessWidget {
  final String title;
  final int total;
  final int success;
  final int fail;
  final double percent;

  const ModelGaugeCard({
    super.key,
    required this.title,
    required this.total,
    required this.success,
    required this.fail,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lightGray),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ 왼쪽 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Requests, Total 가운데 정렬
              children: [
                Text(title, style: T.t16(bold: true)),
                const SizedBox(height: 4),
                Text("Total : $total", style: T.t12(color: gray)),
                const SizedBox(height: 8),
                // 회색 실선
                Container(height: 1, width: 500, color: lightGray),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // success, fail 가운데 정렬
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("Success: $success", style: T.t12(color: statusGreen)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("Fail: $fail", style: T.t12(color: statusRed)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ 오른쪽 반원 게이지 (CustomPaint)
          SizedBox(
            width: 160,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(160, 80), painter: _HalfGaugePainter(percent)),
                Positioned(bottom: 6, child: Text("${percent.toStringAsFixed(0)}%", style: T.t20(bold: true))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ 정확한 반원 게이지 Painter
class _HalfGaugePainter extends CustomPainter {
  final double percent;

  _HalfGaugePainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF7EBE1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..color = statusGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // 전체 반원 (배경)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // 시작 각도 (180도)
      math.pi, // 전체 180도
      false,
      backgroundPaint,
    );

    // 채워지는 부분 (퍼센트)
    final sweep = math.pi * (percent / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, sweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(_HalfGaugePainter oldDelegate) => oldDelegate.percent != percent;
}
