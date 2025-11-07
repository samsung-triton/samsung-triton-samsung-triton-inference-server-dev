// 서버 로그 화면 위젯
import 'package:flutter/material.dart';
import 'package:triton/widgets/serverlog/server_log_table.dart';
import 'package:triton/widgets/serverlog/serverlog_header.dart';

class ServerLogScreen extends StatefulWidget {
  const ServerLogScreen({super.key});

  @override
  State<ServerLogScreen> createState() => _ServerLogScreenState();
}

class _ServerLogScreenState extends State<ServerLogScreen> {
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
