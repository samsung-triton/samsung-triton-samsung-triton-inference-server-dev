import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/widgets/button/button_small.dart';
import 'package:triton/widgets/input/input_small.dart';
import 'package:triton/widgets/modellog/dropdown.dart';
import 'package:triton/widgets/modellog/filter_text.dart';
import 'package:triton/widgets/modellog/MiniDatePicker.dart';

class FilterBlockServer extends StatelessWidget {
  const FilterBlockServer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryDarkest),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1행: period
          Row(
            children: const [
              FilterText(label: 'period'),
              SizedBox(width: 8),
              MiniDatePicker(),
              SizedBox(width: 8),
              Text('~', style: TextStyle(color: black)),
              SizedBox(width: 8),
              MiniDatePicker(),
            ],
          ),

          // 2행: log level
          Row(
            children: const [
              FilterText(label: 'log type'),
              SizedBox(width: 8),
              Dropdown(items: ['INFO', 'DEBUG', 'WARN', 'ERROR'], width: 200, hintText: 'selcct logtype'),
            ],
          ),

          // 3행: search
          Row(
            children: [
              const FilterText(label: 'search'),
              const SizedBox(width: 8),
              const Dropdown(items: ['user ID', 'user name', 'details', 'description'], width: 200, hintText: 'sort'),
              const SizedBox(width: 8),
              const SizedBox(child: InputSmall(hintText: 'Enter keyword...', width: 424, height: 28)),
              const SizedBox(width: 8),
              const ButtonSmall(
                text: 'ok',
                backgroundColor: primaryNormal,
                textColor: white,
                borderColor: Colors.transparent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
