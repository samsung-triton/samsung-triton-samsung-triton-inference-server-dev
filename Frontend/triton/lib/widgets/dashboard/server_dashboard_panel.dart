// lib/widgets/dashboard/server_dashboard_panel.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:triton/theme/typography.dart';
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
    final serverCtrl = Get.find<ServerDashboardController>();
    const gap = 8.0;

    return Padding(
      padding: const EdgeInsets.all(gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Header (Reset Time / Update 버튼)
          CommonMetricHeaderBar(onRefresh: () => serverCtrl.restartSse()),

          const SizedBox(height: gap),

          /// Upper Row — GPU Utilization + GPU VRAM
          Expanded(
            child: Row(
              children: [
                /// GPU Utilization
                Expanded(
                  child: Obx(() {
                    if (serverCtrl.gpuError.value != null) {
                      return CommonInfoCardBase(
                        title: "GPU Utilization",
                        child: Text(serverCtrl.gpuError.value!, style: T.t12(color: Colors.red)),
                      );
                    }

                    return CommonInfoCardBase(
                      title: 'GPU Utilization',
                      usageText: '${serverCtrl.latestGpuUtil.toStringAsFixed(2)}% Usage',
                      child: const ServerGpuUtilizationChart(),
                    );
                  }),
                ),

                const SizedBox(width: gap),

                /// GPU VRAM Chart
                Expanded(
                  child: Obx(() {
                    if (serverCtrl.vramError.value != null) {
                      return CommonInfoCardBase(
                        title: "GPU VRAM",
                        child: Text(serverCtrl.vramError.value!, style: T.t12(color: Colors.red)),
                      );
                    }

                    return CommonInfoCardBase(
                      title: 'GPU VRAM',
                      usageText: '${serverCtrl.latestGpuVram.toStringAsFixed(2)}% Utilization',
                      child: const ServerGpuResourceChart(),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: gap),

          /// Lower Row — CPU + RAM
          Expanded(
            child: Row(
              children: [
                /// CPU Usage
                Expanded(
                  child: Obx(() {
                    if (serverCtrl.cpuError.value != null) {
                      return CommonInfoCardBase(
                        title: "CPU",
                        child: Text(serverCtrl.cpuError.value!, style: T.t12(color: Colors.red)),
                      );
                    }

                    return CommonInfoCardBase(
                      title: 'CPU',
                      usageText: '${serverCtrl.latestCpuUsage.toStringAsFixed(2)}% Usage',
                      child: const ServerCpuUsageChart(),
                    );
                  }),
                ),

                const SizedBox(width: gap),

                /// RAM Usage
                Expanded(
                  child: Obx(() {
                    if (serverCtrl.ramError.value != null) {
                      return CommonInfoCardBase(
                        title: "RAM",
                        child: Text(serverCtrl.ramError.value!, style: T.t12(color: Colors.red)),
                      );
                    }

                    return CommonInfoCardBase(
                      title: 'RAM',
                      usageText: '${serverCtrl.latestRamUsage.toStringAsFixed(2)}% Memory Usage',
                      child: const ServerRamUsageChart(),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
