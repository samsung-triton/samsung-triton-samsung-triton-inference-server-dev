// 대시보드 화면

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/controller/dashboard/dashboard_controller.dart';
import 'package:triton/widgets/dashboard/dashboard_sidebar.dart';
import 'package:triton/widgets/dashboard/model_dashboard_panel.dart';
import 'package:triton/widgets/dashboard/server_dashboard_panel.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController dashboardController;

  @override
  void initState() {
    super.initState();

    // 기존 컨트롤러 제거 후 재등록
    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>(force: true);
    }
    dashboardController = Get.put(DashboardController());

    // 초기 진입 시 SSE 재연결
    Get.find<ServerDashboardController>().restartSse();

    // 모델 탭 진입 시 모델 SSE 재연결
    final modelId = dashboardController.selectedModelId.value;
    if (modelId != null) {
      Get.find<ModelDashboardController>().restartSse(modelId);
    }
  }

  @override
  void dispose() {
    // 화면 종료 시 대시보드 컨트롤러 제거
    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // 좌측: 사이드바 / 우측: 패널 영역
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSidebar(),

          Expanded(
            child: Obx(() {
              switch (dashboardController.selectedType.value) {
                case DashboardType.server:
                  return const ServerDashboardPanel();
                case DashboardType.model:
                case DashboardType.ensemble:
                  return const ModelDashboardPanel();
              }
            }),
          ),
        ],
      ),
    );
  }
}
