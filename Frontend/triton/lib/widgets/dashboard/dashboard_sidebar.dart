// 대시보드 사이드바

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

    // 사이드바는 SSE 기반 모델 리스트를 실시간 표시
    return Obx(() {
      return SidebarBase(
        children: [
          // Triton Server 카드(헤더)
          CommonSidebarCard(
            type: SidebarCardType.header,
            title: 'Triton Server',
            active: controller.selectedType.value == DashboardType.server,
            onTap: () => controller.changeType(DashboardType.server),
          ),

          // 모델 리스트 (SSE 실시간 업데이트)
          ...controller.modelList.map((m) {
            return CommonSidebarCard(
              type: SidebarCardType.normal,
              title: m.modelName,
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
