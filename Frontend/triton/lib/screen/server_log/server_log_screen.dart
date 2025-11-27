// 서버 로그 화면
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/server_log/server_log_controller.dart';
import 'package:triton/widgets/serverlog/server_log_table.dart';
import 'package:triton/widgets/serverlog/server_log_header.dart';

class ServerLogScreen extends StatefulWidget {
  const ServerLogScreen({super.key});

  @override
  State<ServerLogScreen> createState() => _ServerLogScreenState();
}

class _ServerLogScreenState extends State<ServerLogScreen> {
  late final ServerLogController controller;

  @override
  void initState() {
    super.initState();

    // 페이지 단위로 컨트롤러 주입
    controller = Get.put(ServerLogController(), permanent: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //위젯 렌더링 후 필터 적용
      controller.applyFilter();
    });
  }

  @override
  void dispose() {
    Get.delete<ServerLogController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServerLogHeader(),
            const Expanded(child: ServerLogTable()),
          ],
        ),
      ),
    );
  }
}
