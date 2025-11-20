import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class TritonLogTableHeader extends StatelessWidget {
  const TritonLogTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryDarker,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Center(child: _headerText('create at'))),
          SizedBox(width: 120, child: Center(child: _headerText('log level'))),
          Expanded(child: Center(child: _headerText('detail'))),
        ],
      ),
    );
  }

  Widget _headerText(String label) {
    return Text(
      label,
      style: T.t10(bold: true, color: white),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
