import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ServerLogTableRow extends StatelessWidget {
  final Map<String, String> log;
  const ServerLogTableRow({super.key, required this.log});

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
          Expanded(
            flex: 2,
            child: Text(
              log['username']!,
              textAlign: TextAlign.center,
              style: T.t10(color: black, bold: false),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              log['date']!,
              textAlign: TextAlign.center,
              style: T.t10(color: black, bold: false),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log['type']!,
              textAlign: TextAlign.center,
              style: T.t10(color: black, bold: false),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log['detail']!,
              textAlign: TextAlign.center,
              style: T.t10(color: black, bold: false),
            ),
          ),
          Expanded(
            flex: 20,
            child: Text(
              log['description']!,
              softWrap: true, // 자동 줄바꿈 허용
              overflow: TextOverflow.visible, // 잘리지 않게
              style: T.t10(color: black, bold: false),
            ),
          ),
        ],
      ),
    );
  }
}
