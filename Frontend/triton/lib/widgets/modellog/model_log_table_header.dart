import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ModelLogTableHeader extends StatelessWidget {
  const ModelLogTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryDarkest,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              'create at',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'log level',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
          Expanded(
            flex: 58,
            child: Text(
              'details',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
        ],
      ),
    );
  }
}
