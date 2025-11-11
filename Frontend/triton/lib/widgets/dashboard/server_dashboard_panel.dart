import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:triton/widgets/dashboard/common_metric_header_bar.dart';
import 'package:triton/widgets/dashboard/server_cuda_info_card.dart';
import 'package:triton/widgets/dashboard/server_gpu_vram_chart.dart';
import 'package:triton/widgets/dashboard/server_cpu_usage_chart.dart';
import 'package:triton/widgets/dashboard/server_ram_usage_chart.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/controller/dashboard/server_cpu_controller.dart';
import 'package:triton/controller/dashboard/server_gpu_controller.dart';
import 'package:triton/controller/dashboard/server_cuda_controller.dart';
import 'package:triton/controller/dashboard/server_ram_controller.dart';

class ServerDashboardPanel extends StatelessWidget {
  const ServerDashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 하위 컨트롤러 찾기 (이미 DashboardController에서 lazyPut 등록됨)
    final cudaController = Get.find<ServerCudaController>();
    final gpuController = Get.find<ServerGpuController>();
    final cpuController = Get.find<ServerCpuController>();
    final ramController = Get.find<ServerRamController>();

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
                  child: CommonInfoCardBase(title: 'CUDA Info.', child: const ServerCudaInfoCard()),
                ),
                const SizedBox(width: gap),

                // GPU VRAM Chart
                Expanded(
                  child: CommonInfoCardBase(
                    title: 'GPU VRAM',
                    usageText: '${gpuController.metrics.value.gpuVram.toStringAsFixed(0)}% Utilization',
                    child: const ServerGpuResourceChart(),
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
                  child: CommonInfoCardBase(
                    title: 'CPU',
                    usageText: '${cpuController.metrics.value.cpuUsage.toStringAsFixed(0)}% Usage',
                    child: const ServerCpuUsageChart(),
                  ),
                ),
                const SizedBox(width: gap),

                // RAM Usage
                Expanded(
                  child: CommonInfoCardBase(
                    title: 'RAM',
                    usageText: '${ramController.metrics.value.ramUsage.toStringAsFixed(0)}% Memory Usage',
                    child: const ServerRamUsageChart(),
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
