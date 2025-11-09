import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ServerLogTableHeader extends StatelessWidget {
  const ServerLogTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryDarker,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'user name',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'create at',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'log type',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'details',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
          Expanded(
            flex: 20,
            child: Text(
              'description',
              textAlign: TextAlign.center,
              style: T.t10(color: white, bold: true),
            ),
          ),
        ],
      ),
    );
  }
}
