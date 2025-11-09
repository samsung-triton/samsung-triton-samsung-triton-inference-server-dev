import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/widgets/sidebar/sidebar_base.dart';
import 'package:triton/widgets/dashboard/common_sidebar_card.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();

    return Obx(() {
      final current = c.selectedMenu.value;

      return SidebarBase(
        children: [
          // Triton Server (기존 서버 대시보드)
          CommonSidebarCard(
            type: SidebarCardType.header,
            title: 'Triton Server',
            active: current == 'server',
            onTap: () => c.changeMenu('server'),
          ),

          // 모델들
          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Model 1',
            status: true,
            active: current == 'model1',
            current: 2720, // ✅ 현재값
            total: 2894, // ✅ 전체값
            onTap: () => c.changeMenu('model1'),
          ),
          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Model 2',
            status: true,
            active: current == 'model2',
            current: 2720, // ✅ 현재값
            total: 2894, // ✅ 전체값
            onTap: () => c.changeMenu('model2'),
          ),

          // 앙상블
          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Ensemble 1',
            status: false,
            active: current == 'ensemble1',
            current: 2720, // ✅ 현재값
            total: 2894, // ✅ 전체값
            onTap: () => c.changeMenu('ensemble1'),
          ),
          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Ensemble 2',
            status: false,
            active: current == 'ensemble2',
            current: 2720, // ✅ 현재값
            total: 2894, // ✅ 전체값
            onTap: () => c.changeMenu('ensemble2'),
          ),
          CommonSidebarCard(
            type: SidebarCardType.normal,
            title: 'Ensemble 2',
            status: false,
            active: current == 'ensemble2',
            current: 2720, // ✅ 현재값
            total: 2894, // ✅ 전체값
            onTap: () => c.changeMenu('ensemble2'),
          ),
        ],
      );
    });
  }
}
