import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/serverlog/server_log_table_row.dart';
import 'package:triton/widgets/serverlog/server_log_table_header.dart';
import 'package:triton/controller/server_log/filter_controller_server.dart';

class ServerLogTable extends StatelessWidget {
  const ServerLogTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilterControllerServer>();

    return Container(
      //margin: EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      color: white,
      child: Column(
        children: [
          const ServerLogTableHeader(),
          Expanded(
            child: Obx(() {
              // 모델 선택 안한 경우
              if (controller.serverName.value.isEmpty) {
                return Center(
                  child: Text('Please select a server.', style: T.t12(color: gray, bold: false)),
                );
              }

              final logs = controller.filteredLogs; // 필터링된 로그 가져오기

              // 필터링 결과가 없는 경우
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    'There are no logs matching the selected conditions.',
                    style: T.t12(color: gray, bold: false),
                  ),
                );
              }
              return RawScrollbar(
                thumbColor: lightGray, // 스크롤 색상 지정
                radius: const Radius.circular(4), // 둥근 모서리
                thickness: 8, // ✅ 두께
                thumbVisibility: false, // 항상 보이게
                interactive: true, // 드래그로 스크롤 가능
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, i) {
                    final log = logs[i];
                    return ServerLogTableRow(
                      log: {
                        // 기존 구조에 맞게 변환
                        'username': log['username'],
                        'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(log['date'])), //출력 파싱
                        'type': log['type'],
                        'detail': log['detail'],
                        'description': log['description'],
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
