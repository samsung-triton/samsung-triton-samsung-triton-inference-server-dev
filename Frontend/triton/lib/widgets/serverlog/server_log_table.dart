import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/serverlog/server_log_table_row.dart';
import 'package:triton/widgets/serverlog/server_log_table_header.dart';
import 'package:triton/controller/server_log/server_log_controller.dart';

class ServerLogTable extends StatefulWidget {
  const ServerLogTable({super.key});

  @override
  State<ServerLogTable> createState() => _ServerLogTableState();
}

class _ServerLogTableState extends State<ServerLogTable> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final serverController = Get.find<ServerLogController>();

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500) {
        serverController.fetchMoreLogs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverController = Get.find<ServerLogController>();

    return Container(
      //margin: EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      color: white,
      child: Column(
        children: [
          const ServerLogTableHeader(),
          Expanded(
            child: Obx(() {
              final logs = serverController.filteredLogs; // 필터링된 로그 가져오기

              if (serverController.isLoading.value && serverController.filteredLogs.isEmpty) {
                return Center(
                  child: Text("Loading...", style: T.t12(color: gray, bold: false)),
                );
              }

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
                thickness: 8, // 두께
                thumbVisibility: false, // 항상 보이게
                interactive: true, // 드래그로 스크롤 가능
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: logs.length,
                  itemBuilder: (context, i) {
                    return ServerLogTableRow(log: logs[i]);
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
