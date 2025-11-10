import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/model_log_table_header.dart';
import 'package:triton/widgets/modellog/model_log_table_row.dart';
import 'package:triton/controller/model_log/filter_controller.dart';

class ModelLogTable extends StatelessWidget {
  const ModelLogTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilterController>();

    return Container(
      //margin: EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      color: white,
      child: Column(
        children: [
          const ModelLogTableHeader(),
          Expanded(
            child: Obx(() {
              // 모델 선택 안한 경우
              if (controller.modelName.value.isEmpty) {
                return Center(
                  child: Text('Please select a model.', style: T.t12(color: gray, bold: false)),
                );
              }

              final logs = controller.filteredLogs; // 필터링된 로그 가져오기

              // 필터링 결과가 없는 경우
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    'There are no logs matching the selected conditions.',
                    style: T.t12(color: gray, bold: false),
                  ),
                );
              }

              return RawScrollbar(
                thumbColor: lightGray,
                radius: const Radius.circular(4),
                thickness: 8, // 두께
                thumbVisibility: false, // 항상 보이게
                interactive: true, // 드래그로 스크롤 가능
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, i) {
                    final log = logs[i];
                    return ModelLogTableRow(
                      log: {
                        // 기존 구조에 맞게 변환
                        'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(log['date']),
                        'level': log['level'],
                        'detail': log['message'],
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
