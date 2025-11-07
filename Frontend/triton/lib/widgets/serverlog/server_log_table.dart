import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/widgets/serverlog/server_log_table_header.dart';
import 'package:triton/widgets/serverlog/server_log_table_row.dart';

class ServerLogTable extends StatelessWidget {
  const ServerLogTable({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = List.generate(
      30,
      (i) => {
        'username': 'tester1',
        'date': '2025-03-28 15:39:${i.toString().padLeft(2, '0')}',
        'type': 'triton',
        'detail': 'server restart',
        'description': 'Server restarted due to an error.',
      },
    );

    return Container(
      //margin: EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      color: white,
      child: Column(
        children: [
          const ServerLogTableHeader(),
          Expanded(
            child: RawScrollbar(
              thumbColor: lightGray, // 스크롤 색상 지정
              radius: const Radius.circular(4), // 둥근 모서리
              thickness: 8, // ✅ 두께
              thumbVisibility: false, // 항상 보이게
              interactive: true, // 드래그로 스크롤 가능
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, i) => ServerLogTableRow(log: logs[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
