// 모델 로그 화면 위젯
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_log/filter_controller.dart';
import 'package:triton/widgets/modellog/model_log_table.dart';
import 'package:triton/widgets/modellog/modellog_header.dart';

class ModelLogScreen extends StatefulWidget {
  const ModelLogScreen({super.key});

  @override
  State<ModelLogScreen> createState() => _ModelLogScreenState();
}

class _ModelLogScreenState extends State<ModelLogScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FilterController>()) {
      //한번 등록된 컨트롤러는 재사용됨
      Get.put(FilterController());
    }

    // 페이지 진입 시 필터 초기화
    final controller = Get.find<FilterController>();
    controller.resetFilter();
  }

  Widget build(BuildContext context) {
    Get.put(FilterController());
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
