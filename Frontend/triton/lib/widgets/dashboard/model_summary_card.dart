import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/dashboard/common_info_card_base.dart';

/// 모델 이름, 버전, 상태를 요약해서 표시하는 카드
class ModelSummaryCard extends StatelessWidget {
  final String modelName;
  final String version;
  final String status; // READY / UNAVAILABLE / LOADING

  const ModelSummaryCard({super.key, required this.modelName, required this.version, required this.status});

  Color _statusColor() {
    switch (status.toUpperCase()) {
      case 'READY':
        return statusGreen;
      case 'UNAVAILABLE':
        return statusRed;
      case 'LOADING':
        return statusYellow;
      default:
        return gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonInfoCardBase(
      title: 'Model Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Model', modelName),
          const SizedBox(height: 8),
          _row('Version', version),
          const SizedBox(height: 8),
          _row('Status', status, valueColor: _statusColor()),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: T.t12(color: gray)),
        Text(value, style: T.t12(color: valueColor ?? black, bold: true)),
      ],
    );
  }
}
