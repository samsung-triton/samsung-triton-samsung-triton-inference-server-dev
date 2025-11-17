import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart';
import 'package:triton/widgets/dashboard/dashboard_sidebar.dart';
import 'package:triton/widgets/dashboard/model_dashboard_panel.dart';
import 'package:triton/widgets/dashboard/server_dashboard_panel.dart';

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

    // 이전 컨트롤러가 살아있으면 제거
    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>(force: true);
    }

    // 🔥 Controller 등록
    dashboardController = Get.put(DashboardController());

    // 🔥 Dashboard 화면 들어오면 polling 시작
    dashboardController.startPolling();
  }

  @override
  void dispose() {
    // 🔥 Dashboard 화면 벗어나면 polling 중단
    dashboardController.stopPolling();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
