import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';

class ServerCudaInfoCard extends StatelessWidget {
  const ServerCudaInfoCard({super.key});

  Widget _buildBar(String title, String desc, double value, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: T.t16(color: primaryDarker, bold: true)),
          const SizedBox(height: 2),
          Text(desc, style: T.t12(color: darkGray)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              color: primaryNormal,
              backgroundColor: lightGray,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text('${value.toStringAsFixed(0)}$unit', style: T.t16(color: primaryDarker, bold: true)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerDashboardController>();

    return Obx(() {
      final metrics = controller.metrics.value;

      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBar('SM Utilization (%)', 'GPU CUDA Core Occupancy', metrics.smUtil, '%'),
              _buildBar('Tensor Core Utilization (%)', 'TensorRT / FP16 Model Proportion', metrics.tensorCoreUtil, '%'),
              _buildBar('FP32 Utilization (%)', 'Standard Operation Proportion', metrics.fp32Util, '%'),
              _buildBar(
                'Inference Throughput (req/s)',
                'Server Throughput (TPS)',
                metrics.inferenceThroughput.toDouble(),
                ' req/s',
              ),
            ],
          ),
        ),
      );
    });
  }
}
