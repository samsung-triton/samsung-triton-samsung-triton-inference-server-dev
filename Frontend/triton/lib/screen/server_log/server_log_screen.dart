// 서버 로그 화면 위젯
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/server_log/server_log_controller.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/serverlog/server_log_table_server.dart';
import 'package:triton/widgets/serverlog/serverlog_header.dart';
import '../../theme/app_colors.dart';

class ServerLogScreen extends StatefulWidget {
  const ServerLogScreen({super.key});

  @override
  State<ServerLogScreen> createState() => _ServerLogScreenState();
}

class _ServerLogScreenState extends State<ServerLogScreen> {
  late final ServerLogController serverLogController;

  @override
  void initState() {
    super.initState();

    // 페이지 단위로 컨트롤러 주입
    serverLogController = Get.put(ServerLogController(), permanent: false);
  }

  @override
  void dispose() {
    // 페이지 나갈 때 컨트롤러 메모리 해제
    Get.delete<ServerLogController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = serverLogController;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServerLogHeader(),
            Expanded(
              child: Obx(() {
                final target = controller.serverName.value;

                if (target.isEmpty) {
                  return Center(
                    child: Text("Please select a server.", style: T.t12(color: gray)),
                  );
                }

                if (target == 'triton') {
                  //return const ServerLogTableTriton(); // Triton UI
                } else if (target == 'server') {
                  return const ServerLogTableServer();
                }

                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
