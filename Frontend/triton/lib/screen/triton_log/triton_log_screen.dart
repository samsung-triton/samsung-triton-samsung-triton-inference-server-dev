// 모델 로그 화면 위젯
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_log/model_log_controller.dart';
import 'package:triton/widgets/modellog/triton_log_table.dart';
import 'package:triton/widgets/modellog/tritonlog_header.dart';

class ModelLogScreen extends StatefulWidget {
  const ModelLogScreen({super.key});

  @override
  State<ModelLogScreen> createState() => _ModelLogScreenState();
}

class _ModelLogScreenState extends State<ModelLogScreen> {
  late final ModelLogController modelLogController;

  @override
  void initState() {
    super.initState();

    // 페이지 단위로 컨트롤러 주입
    modelLogController = Get.put(ModelLogController(), permanent: false);
  }

  @override
  void dispose() {
    // 페이지 나갈 때 컨트롤러 메모리 해제
    Get.delete<ModelLogController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ModelLogController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            TritonLogHeader(),
            Expanded(child: TritonLogTable()), // 테이블이 아래 전체 채움
          ],
        ),
      ),
    );
  }
}
