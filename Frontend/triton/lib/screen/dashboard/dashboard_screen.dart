// lib/screen/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart';
import 'package:triton/screen/dashboard/dashboard_sidebar.dart';
import 'package:triton/widgets/dashboard/model_dashboard_panel.dart';
import 'package:triton/widgets/dashboard/server_dashboard_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.put(DashboardController());

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSidebar(),
          Expanded(
            child: Obx(() {
              final selected = dashboardController.selectedMenu.value;
              if (selected == 'server') {
                return const ServerDashboardPanel();
              } else {
                return const ModelDashboardPanel();
              }
            }),
          ),
        ],
      ),
    );
  }
}
