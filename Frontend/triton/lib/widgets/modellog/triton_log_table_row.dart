import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class TritonLogTableRow extends StatelessWidget {
  final Map<String, String> log;
  const TritonLogTableRow({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: lightGray, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 여러 줄일 때 위로 정렬
        children: [
          _textCell(log['date']!, width: 120),
          _textCell(log['level']!, width: 120),
          _textCell(log['detail']!, expanded: true, textAlign: TextAlign.left),
        ],
      ),
    );
  }

  Widget _textCell(String text, {double? width, bool expanded = false, TextAlign textAlign = TextAlign.center}) {
    final child = Text(text, style: T.t10(), softWrap: true, textAlign: textAlign);

    if (expanded) return Expanded(child: child);
    return SizedBox(width: width, child: child);
  }
}
