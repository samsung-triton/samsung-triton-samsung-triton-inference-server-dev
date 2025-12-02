//트리톤 서버 로그의 열
import 'package:flutter/material.dart';
import 'package:triton/controller/model_log/triton_server_log_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class TritonServerLogTableRow extends StatelessWidget {
  final TritonLogItem log;

  const TritonServerLogTableRow({super.key, required this.log});

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
          _textCell(log.ts, width: 120),
          _textCell(log.level, width: 120),
          _textCell(log.message, expanded: true, textAlign: TextAlign.left),
        ],
      ),
    );
  }

  //textCell 위젯
  Widget _textCell(String text, {double? width, bool expanded = false, TextAlign textAlign = TextAlign.center}) {
    final child = Text(text, style: T.t10(), softWrap: true, textAlign: textAlign);

    if (expanded) return Expanded(child: child);
    return SizedBox(width: width, child: child);
  }
}
