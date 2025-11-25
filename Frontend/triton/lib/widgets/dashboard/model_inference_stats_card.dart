// lib/widgets/dashboard/model_inference_stats_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/widgets/dashboard/model_gauge_card.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

class ModelInferenceStatsCard extends StatelessWidget {
  const ModelInferenceStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ModelDashboardController>();

    return Obx(() {
      return CommonInfoCardBase(
        title: "Model Inference Statistics",
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Expanded(
                child: ModelGaugeCard(
                  title: "Requests",
                  total: controller.totalRequests.value,
                  success: controller.successRequests.value,
                  fail: controller.failRequests.value,
                  percent: controller.requestPercent,
                ),
              ),

              Expanded(
                child: ModelGaugeCard(
                  title: "Inference",
                  total: controller.totalInference.value,
                  success: controller.successInference.value,
                  fail: controller.failInference.value,
                  percent: controller.inferencePercent,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
