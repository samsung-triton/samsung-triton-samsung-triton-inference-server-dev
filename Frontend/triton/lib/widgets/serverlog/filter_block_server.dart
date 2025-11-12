import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/widgets/button/button_small.dart';
import 'package:triton/widgets/input/input_small.dart';
import 'package:triton/widgets/modellog/dropdown.dart';
import 'package:triton/widgets/modellog/filter_text.dart';
import 'package:triton/widgets/modellog/MiniDatePicker.dart';
import 'package:triton/controller/server_log/server_log_controller.dart';

class FilterBlockServer extends StatelessWidget {
  const FilterBlockServer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerLogController>();

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

                  // 만약 종료 날짜가 시작보다 전이면 null로 리셋
                  if (controller.endDate.value != null && controller.endDate.value!.isBefore(date)) {
                    controller.endDate.value = null;
                  }
                },
              ),
              SizedBox(width: 8),
              Text('~', style: TextStyle(color: black)),
              SizedBox(width: 8),
              Obx(
                () => MiniDatePicker(
                  onDateSelected: (date) {
                    controller.endDate.value = date;
                  },
                  // 시작 날짜 이후로만 선택 가능하게 제한
                  firstDate: controller.startDate.value ?? DateTime(2000),
                ),
              ),
            ],
          ),

          // 2행: log level
          Row(
            children: [
              FilterText(label: 'log type'),
              SizedBox(width: 8),
              Dropdown(
                //현재 연결 안되어있음
                items: ['triton', 'server'],
                width: 200,
                hintText: 'selcct logtype',
                //onChanged: / {},
              ),
            ],
          ),

          // 3행: search
          Row(
            children: [
              const FilterText(label: 'search'),
              const SizedBox(width: 8),
              Dropdown(
                items: ['user name', 'details', 'description'],
                width: 200,
                hintText: 'sort',
                onChanged: (value) {
                  controller.sort.value = value ?? '';
                },
              ),
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
