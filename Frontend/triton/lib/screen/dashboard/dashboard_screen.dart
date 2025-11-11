import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart';
import 'package:triton/widgets/dashboard/dashboard_sidebar.dart';
import 'package:triton/widgets/dashboard/model_dashboard_panel.dart';
import 'package:triton/widgets/dashboard/server_dashboard_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ DashboardController만 등록
    final dashboardController = Get.put(DashboardController());

    return Scaffold(
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
                  return const ModelDashboardPanel(); // ensemble은 일단 공용 처리
              }
            }),
          ),
        ],
      ),
    );
  }
}
