// lib/widgets/dashboard/server_dashboard_panel.dart
import 'package:flutter/material.dart';
import 'package:triton/widgets/dashboard/common_metric_header_bar.dart';
import 'package:triton/widgets/dashboard/server_cuda_info_card.dart';
import 'package:triton/widgets/dashboard/server_gpu_vram_chart.dart';
import 'package:triton/widgets/dashboard/server_cpu_usage_chart.dart';
import 'package:triton/widgets/dashboard/server_ram_usage_chart.dart';
import 'package:triton/model/dashboard/server_metrics.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';

class ServerDashboardPanel extends StatelessWidget {
  const ServerDashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;

    return Padding(
      padding: const EdgeInsets.all(gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(child: CommonMetricHeaderBar()),
          const SizedBox(height: gap),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CommonInfoCardBase(
                    title: 'CUDA Info.',
                    child: ServerCudaInfoCard(metrics: ServerMetrics.mock),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: CommonInfoCardBase(
                    title: 'GPU VRAM',
                    usageText: '${ServerMetrics.mock.gpuVram.toStringAsFixed(0)}% Utilization',
                    child: ServerGpuResourceChart(metrics: ServerMetrics.mock),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: gap),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CommonInfoCardBase(
                    title: 'CPU',
                    child: ServerCpuUsageChart(metrics: ServerMetrics.mock),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: CommonInfoCardBase(
                    title: 'RAM',
                    usageText: '${ServerMetrics.mock.ramUsage.toStringAsFixed(0)}% Memory Usage',
                    child: ServerRamUsageChart(metrics: ServerMetrics.mock),
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
