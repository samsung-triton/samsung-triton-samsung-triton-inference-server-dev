// 서버 로그 화면 위젯
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/server_log/filter_controller_server.dart';
import 'package:triton/widgets/serverlog/server_log_table.dart';
import 'package:triton/widgets/serverlog/serverlog_header.dart';

class ServerLogScreen extends StatefulWidget {
  const ServerLogScreen({super.key});

  @override
  State<ServerLogScreen> createState() => _ServerLogScreenState();
}

class _ServerLogScreenState extends State<ServerLogScreen> {
  late final FilterControllerServer filterControllerServer;

  @override
  void initState() {
    super.initState();

    // 페이지 단위로 컨트롤러 주입
    filterControllerServer = Get.put(FilterControllerServer(), permanent: false);
  }

  @override
  void dispose() {
    // 페이지 나갈 때 컨트롤러 메모리 해제
    Get.delete<FilterControllerServer>();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   if (!Get.isRegistered<FilterControllerServer>()) {
  //     //한번 등록된 컨트롤러는 재사용됨
  //     Get.put(FilterControllerServer());
  //   }

  //   // 페이지 진입 시 필터 초기화
  //   final controller = Get.find<FilterControllerServer>();
  //   controller.resetFilter();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ServerLogHeader(),
            Expanded(child: ServerLogTable()), // 테이블이 아래 전체 채움
          ],
        ),
      ),
    );
  }
}
