import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/widgets/button/button_small.dart';
import 'package:triton/widgets/input/input_small.dart';
import 'package:triton/widgets/modellog/dropdown.dart';
import 'package:triton/widgets/modellog/filter_text.dart';
import 'package:triton/widgets/modellog/MiniDatePicker.dart';
import 'package:triton/controller/model_log/model_log_controller.dart';

class FilterBlock extends StatelessWidget {
  const FilterBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ModelLogController>();

    final keywordCtrl = TextEditingController();

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
            children: [
              FilterText(label: 'period'),
              SizedBox(width: 8),
              MiniDatePicker(
                onDateSelected: (date) {
                  controller.startDate.value = date;
                },
              ),
              SizedBox(width: 8),
              Text('~', style: TextStyle(color: black)),
              SizedBox(width: 8),
              MiniDatePicker(
                onDateSelected: (date) {
                  controller.endDate.value = date;
                },
              ),
            ],
          ),

          // 2행: log level
          Row(
            children: [
              FilterText(label: 'log level'),
              SizedBox(width: 8),
              Dropdown(
                items: ['INFO', 'DEBUG', 'WARN', 'ERROR'],
                width: 200,
                hintText: 'select loglevel',
                onChanged: (value) {
                  controller.logLevel.value = value ?? '';
                },
              ),
            ],
          ),

          // 3행: search
          Row(
            children: [
              const FilterText(label: 'search'),
              const SizedBox(width: 8),
              SizedBox(
                child: InputSmall(hintText: 'Enter keyword', width: 424, height: 28, controller: keywordCtrl),
              ),
              const SizedBox(width: 8),
              ButtonSmall(
                text: 'ok',
                backgroundColor: primaryNormal,
                textColor: white,
                borderColor: Colors.transparent,
                onPressed: () {
                  final keyword = keywordCtrl.text.trim();
                  controller.keyword.value = keyword;

                  controller.applyFilter();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
