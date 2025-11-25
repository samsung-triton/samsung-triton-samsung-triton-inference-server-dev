// lib/widgets/dashboard/model_gauge_card.dart
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lightGray),
      ),
      child: Row(
        children: [
          /// ------------------------------
          /// Left Text Column
          /// ------------------------------
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: T.t16(bold: true)),
                Text("Total : $total", style: T.t12(color: gray)),
                const SizedBox(height: 8),

                Container(height: 1, width: double.infinity, color: lightGray),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tag("Success: $success", statusGreen),
                    const SizedBox(width: 8),
                    _tag("Fail: $fail", statusRed),
                  ],
                ),
              ],
            ),
          ),

          /// ------------------------------
          /// Right Gauge
          /// ------------------------------
          SizedBox(
            width: 160,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(160, 70), painter: _HalfGaugePainter(percent)),
                Positioned(bottom: 6, child: Text("${percent.toStringAsFixed(0)}%", style: T.t20(bold: true))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: T.t12(color: color)),
    );
  }
}

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

    // 배경 반원
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi, false, backgroundPaint);

    // 퍼센트 반원
    final sweep = math.pi * (percent / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, sweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(_HalfGaugePainter oldDelegate) => oldDelegate.percent != percent;
}
