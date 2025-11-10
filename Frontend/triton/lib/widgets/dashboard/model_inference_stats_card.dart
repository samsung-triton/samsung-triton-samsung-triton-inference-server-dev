import 'package:flutter/material.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';
import 'package:triton/widgets/dashboard/model_gauge_card.dart';

class ModelInferenceStatsCard extends StatelessWidget {
  const ModelInferenceStatsCard({super.key});

  double _calcPercent(int success, int total) {
    if (total == 0) return 0;
    return (success / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    const totalRequests = 50;
    const successRequests = 50;
    const failRequests = 0;
    const totalInference = 50;
    const successInference = 45;
    const failInference = 5;

    final requestPercent = _calcPercent(successRequests, totalRequests);
    final inferencePercent = _calcPercent(successInference, totalInference);

    return CommonInfoCardBase(
      title: "Model Inference Statistics",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            ModelGaugeCard(
              title: "Requests",
              total: totalRequests,
              success: successRequests,
              fail: failRequests,
              percent: requestPercent,
            ),
            ModelGaugeCard(
              title: "Inference",
              total: totalInference,
              success: successInference,
              fail: failInference,
              percent: inferencePercent,
            ),
          ],
        ),
      ),
    );
  }
}
