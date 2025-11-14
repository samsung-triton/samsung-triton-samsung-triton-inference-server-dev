import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:triton/widgets/dashboard/common_metric_header_bar.dart';
import 'package:triton/widgets/dashboard/server_gpu_utilization_card.dart';
import 'package:triton/widgets/dashboard/server_gpu_vram_chart.dart';
import 'package:triton/widgets/dashboard/server_cpu_usage_chart.dart';
import 'package:triton/widgets/dashboard/server_ram_usage_chart.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';

class ServerDashboardPanel extends StatelessWidget {
  const ServerDashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 하위 컨트롤러 찾기 (이미 DashboardController에서 lazyPut 등록됨)
    final serverCtrl = Get.find<ServerDashboardController>();

    const gap = 8.0;

    return Padding(
      padding: const EdgeInsets.all(gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(child: CommonMetricHeaderBar()),
          const SizedBox(height: gap),

          // ✅ 상단: CUDA Info + GPU VRAM
          Expanded(
            child: Row(
              children: [
                // CUDA Info
                Expanded(
                  child: Obx(
                    () => CommonInfoCardBase(
                      title: 'GPU Utilization',
                      usageText: '${serverCtrl.latestGpuUtil.toStringAsFixed(0)}% Usage',
                      child: const ServerGpuUtilizationChart(),
                    ),
                  ),
                ),
                const SizedBox(width: gap),

                // GPU VRAM Chart
                Expanded(
                  child: Obx(
                    () => CommonInfoCardBase(
                      title: 'GPU VRAM',
                      usageText: '${serverCtrl.latestGpuVram.toStringAsFixed(0)}% Utilization',
                      child: const ServerGpuResourceChart(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: gap),

          // ✅ 하단: CPU + RAM
          Expanded(
            child: Row(
              children: [
                // CPU Usage
                Expanded(
                  child: Obx(
                    () => CommonInfoCardBase(
                      title: 'CPU',
                      usageText: '${serverCtrl.latestCpuUsage.toStringAsFixed(0)}% Usage',
                      child: const ServerCpuUsageChart(),
                    ),
                  ),
                ),
                const SizedBox(width: gap),

                // RAM Usage
                Expanded(
                  child: Obx(
                    () => CommonInfoCardBase(
                      title: 'RAM',
                      usageText: '${serverCtrl.latestRamUsage.toStringAsFixed(0)}% Memory Usage',
                      child: const ServerRamUsageChart(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
