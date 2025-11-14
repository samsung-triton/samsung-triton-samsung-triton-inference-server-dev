import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/widgets/sidebar/sidebar_base.dart';
import 'package:triton/widgets/dashboard/common_sidebar_card.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 이제 DashboardController만 사용
    final controller = Get.find<DashboardController>();
    final serverCtrl = Get.find<ServerDashboardController>();

    return Obx(() {
      final serverCtrl = Get.find<ServerDashboardController>();

      return SidebarBase(
        children: [
          // Server Header
          CommonSidebarCard(
            type: SidebarCardType.header,
            title: 'Triton Server',
            active: controller.selectedType.value == DashboardType.server,
            onTap: () => controller.changeType(DashboardType.server, item: 'server'),
          ),

          // 🔥 Model cards (dynamic)
          ...serverCtrl.metrics.value.models.map((m) {
            return CommonSidebarCard(
              type: SidebarCardType.normal,
              title: m.name,
              status: m.percent > 90, // 예시: 90% 이상이면 green
              active: controller.selectedItem.value == m.key,
              current: m.success,
              total: m.total,
              onTap: () => controller.changeType(DashboardType.model, item: m.key),
            );
          }).toList(),
        ],
      );
    });
  }
}
