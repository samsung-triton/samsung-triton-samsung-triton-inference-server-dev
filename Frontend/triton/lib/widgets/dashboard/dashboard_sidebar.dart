import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/widgets/sidebar/sidebar_base.dart';
import 'package:triton/widgets/dashboard/common_sidebar_card.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 이제 DashboardController만 사용
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final selectedType = controller.selectedType.value;

      return SidebarBase(
        children: [
          // ✅ Triton Server (서버 대시보드)
          CommonSidebarCard(
            type: SidebarCardType.header,
            title: 'Triton Server',
            active: controller.selectedType.value == DashboardType.server,
            onTap: () => controller.changeType(DashboardType.server, item: 'server'),
          ),

          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Model 1',
            status: true,
            active: controller.selectedItem.value == 'model1',
            current: 2720,
            total: 2894,
            onTap: () => controller.changeType(DashboardType.model, item: 'model1'),
          ),

          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Model 2',
            status: true,
            active: controller.selectedItem.value == 'model2',
            current: 2650,
            total: 2894,
            onTap: () => controller.changeType(DashboardType.model, item: 'model2'),
          ),

          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Ensemble 1',
            status: false,
            active: controller.selectedItem.value == 'ensemble1',
            current: 2500,
            total: 2894,
            onTap: () => controller.changeType(DashboardType.ensemble, item: 'ensemble1'),
          ),
        ],
      );
    });
  }
}
