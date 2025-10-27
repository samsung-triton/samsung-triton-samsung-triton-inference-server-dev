// 서버 로그 화면 위젯
import 'package:flutter/material.dart';

class ServerLogScreen extends StatefulWidget {
  const ServerLogScreen({super.key});

  @override
  State<ServerLogScreen> createState() => _ServerLogScreenState();
}

class _ServerLogScreenState extends State<ServerLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("Server Log"));
  }
}
