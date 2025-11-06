import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ModelLogTableRow extends StatelessWidget {
  final Map<String, String> log;
  const ModelLogTableRow({super.key, required this.log});

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
            flex: 6,
            child: Text(
              log['date']!,
              textAlign: TextAlign.center,
              style: T.t10(color: black, bold: false),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              log['level']!,
              textAlign: TextAlign.center,
              style: T.t10(color: black, bold: false),
            ),
          ),
          Expanded(
            flex: 58,
            child: Text(
              log['detail']!,
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
