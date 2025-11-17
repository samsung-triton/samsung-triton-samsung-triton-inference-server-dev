import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/widgets/button/button_small.dart';
import 'package:triton/widgets/input/input_small.dart';
import 'package:triton/widgets/modellog/dropdown.dart';
import 'package:triton/widgets/modellog/filter_text.dart';
import 'package:triton/widgets/modellog/MiniDatePicker.dart';
import 'package:triton/controller/server_log/server_log_controller.dart';

class FilterBlockServer extends StatefulWidget {
  const FilterBlockServer({super.key});

  @override
  State<FilterBlockServer> createState() => _FilterBlockServerState();
}

class _FilterBlockServerState extends State<FilterBlockServer> {
  final keywordCtrl = TextEditingController();

  @override
  void dispose() {
    keywordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerLogController>();

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
              Obx(
                () => MiniDatePicker(
                  initialDate: controller.startDate.value,
                  onDateSelected: (date) {
                    controller.startDate.value = date;

                    if (controller.endDate.value != null && controller.endDate.value!.isBefore(date)) {
                      controller.endDate.value = null;
                    }
                  },
                ),
              ),
              SizedBox(width: 8),
              Text('~', style: TextStyle(color: black)),
              SizedBox(width: 8),
              Obx(
                () => MiniDatePicker(
                  initialDate: controller.endDate.value,
                  firstDate: controller.startDate.value,
                  onDateSelected: (date) => controller.endDate.value = date,
                ),
              ),
              const Spacer(), // 오른쪽으로 밀기

              ButtonSmall(
                text: 'reset',
                backgroundColor: primaryNormal,
                textColor: white,
                borderColor: Colors.transparent,
                onPressed: () {
                  controller.resetFilter();
                  keywordCtrl.clear();
                },
              ),
            ],
          ),

          // 2행: log type
          Row(
            children: [
              FilterText(label: 'log type'),
              SizedBox(width: 8),
              Obx(
                () => Dropdown(
                  key: ValueKey(controller.logType.value),
                  items: [
                    'TRITON-START',
                    'TRITON-STOP',
                    'TRITON-RESTART',
                    'CONFIG-CREATE',
                    'CONFIG-UPDATE',
                    'CONFIG-DELETE',
                    'MODEL-CREATE',
                    'MODEL-UPDATE',
                    'MODEL-DELETE',
                    'VERSION-CREATE',
                    'VERSION-UPDATE',
                    'VERSION-DELETE',
                  ],
                  width: 200,
                  value: controller.logType.value,
                  hintText: 'select logtype',
                  onChanged: (value) {
                    controller.logType.value = value;
                  },
                ),
              ),
            ],
          ),

          // 3행: search
          Row(
            children: [
              const FilterText(label: 'search'),
              const SizedBox(width: 8),
              Obx(() {
                return Dropdown(
                  key: ValueKey(controller.sort.value),
                  items: const ['all', 'user name', 'description'],
                  width: 200,

                  value: controller.sort.value,

                  hintText: 'sort',
                  onChanged: (value) {
                    controller.sort.value = value;
                  },
                );
              }),
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
                  controller.keyword.value = keywordCtrl.text.trim();
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
