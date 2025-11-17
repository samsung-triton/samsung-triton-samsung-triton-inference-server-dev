import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/widgets/sidebar/sidebar_base.dart';
import 'package:triton/widgets/dashboard/common_sidebar_card.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      return SidebarBase(
        children: [
          // ───────────────────────────────
          // Triton Server Header
          // ───────────────────────────────
          CommonSidebarCard(
            type: SidebarCardType.header,
            title: 'Triton Server',
            active: controller.selectedType.value == DashboardType.server,
            onTap: () => controller.changeType(DashboardType.server),
          ),

          // ───────────────────────────────
          // 모델 목록 (대시보드 모델 리스트 API 기반)
          // ───────────────────────────────
          ...controller.modelList.map((m) {
            return CommonSidebarCard(
              type: SidebarCardType.normal,
              title: m.modelName,
              status: m.okRatio > 0.9,
              active: controller.selectedModelId.value == m.modelId,
              current: m.inferenceOk,
              total: m.inferenceTotal,
              onTap: () => controller.changeType(DashboardType.model, modelId: m.modelId),
            );
          }).toList(),
        ],
      );
    });
  }
}
