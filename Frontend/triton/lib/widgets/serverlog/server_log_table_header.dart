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
          SizedBox(width: 100, child: Center(child: _headerText('user name'))),
          SizedBox(width: 150, child: Center(child: _headerText('created at'))),
          SizedBox(width: 100, child: Center(child: _headerText('log type'))),
          SizedBox(width: 150, child: Center(child: _headerText('details'))),
          Expanded(child: Center(child: _headerText('description'))),
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
