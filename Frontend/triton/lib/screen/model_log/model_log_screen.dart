// 모델 로그 화면 위젯
import 'package:flutter/material.dart';
import 'package:triton/widgets/modellog/model_log_table.dart';
import 'package:triton/widgets/modellog/modellog_header.dart';

class ModelLogScreen extends StatefulWidget {
  const ModelLogScreen({super.key});

  @override
  State<ModelLogScreen> createState() => _ModelLogScreenState();
}

class _ModelLogScreenState extends State<ModelLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ModelLogHeader(),
            Expanded(child: ModelLogTable()), // 테이블이 아래 전체 채움
          ],
        ),
      ),
    );
  }
}
