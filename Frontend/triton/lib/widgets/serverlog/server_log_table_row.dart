//서버 로그 테이블의 열
import 'package:flutter/material.dart';
import 'package:triton/controller/server_log/server_log_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ServerLogTableRow extends StatelessWidget {
  final ServerLogItem log;
  const ServerLogTableRow({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: lightGray, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textCell(log.date, width: 150),
          _textCell(log.type, width: 150),
          _textCell(log.username, width: 150),
          _textCell(log.description, expanded: true, textAlign: TextAlign.left), //expanded
        ],
      ),
    );
  }

  //textCell 위엣
  Widget _textCell(String text, {double? width, bool expanded = false, TextAlign textAlign = TextAlign.center}) {
    final child = Text(text, style: T.t10(), softWrap: true, textAlign: textAlign);

    if (expanded) return Expanded(child: child);
    return SizedBox(width: width, child: child);
  }
}
