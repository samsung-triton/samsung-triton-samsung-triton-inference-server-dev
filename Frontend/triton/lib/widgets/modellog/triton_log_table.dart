//트리톤 로그 테이블
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_log/model_log_controller.dart';
import 'package:triton/controller/model_log/triton_log_controller.dart';
import 'package:triton/controller/model_log/triton_server_log_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/model_log_table_row.dart';
import 'package:triton/widgets/modellog/triton_log_table_header.dart';
import 'package:triton/widgets/modellog/triton_server_log_table_row.dart';

class TritonLogTable extends StatefulWidget {
  const TritonLogTable({super.key});

  @override
  State<TritonLogTable> createState() => _TritonLogTableState();
}

class _TritonLogTableState extends State<TritonLogTable> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final tritonServerLogController = Get.find<TritonServerLogController>();

      final modelController = Get.find<ModelLogController>();
      final tritonController = Get.find<TritonLogController>();

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500) {
        final model = tritonController.modelName.value;

        //Triton Server 선택 경우와 AI 모델 선택 경우로 분기
        if (model == 'Triton Server') {
          tritonServerLogController.fetchMoreLogs();
        } else {
          modelController.fetchMoreLogs();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tritonServerLogController = Get.find<TritonServerLogController>();
    final modelController = Get.find<ModelLogController>();

    final tritonInferController = Get.find<TritonLogController>();

    return Container(
      padding: const EdgeInsets.all(8),
      color: white,
      child: Column(
        children: [
          const TritonLogTableHeader(),

          Expanded(
            child: Obx(() {
              final model = tritonInferController.modelName.value;

              //로딩 상태
              if (tritonServerLogController.isLoading.value && tritonServerLogController.filteredLogs.isEmpty ||
                  modelController.isLoading.value && modelController.filteredLogs.isEmpty) {
                return Center(
                  child: Text("Loading...", style: T.t12(color: gray, bold: false)),
                );
              }

              //선택된 모델이 없을 경우
              if (model.isEmpty) {
                return Center(
                  child: Text('Please select a model.', style: T.t12(color: gray)),
                );
              }

              //Triton Server 선택 경우와 AI 모델 선택 경우로 분기
              final logs = (model == 'Triton Server')
                  ? tritonServerLogController.filteredLogs
                  : modelController.filteredLogs;

              //필터링 된 조건의 결과가 없을 경우
              if (logs.isEmpty) {
                return Center(
                  child: Text('There are no logs matching the selected conditions.', style: T.t12(color: gray)),
                );
              }

              //스크롤 바
              return RawScrollbar(
                thumbColor: lightGray,
                radius: const Radius.circular(4),
                thickness: 8,
                interactive: true,
                child: Obx(() {
                  final model = tritonInferController.modelName.value;

                  if (model == 'Triton Server') {
                    final logs = tritonServerLogController.filteredLogs;

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: logs.length,
                      itemBuilder: (context, i) {
                        return TritonServerLogTableRow(log: logs[i]);
                      },
                    );
                  } else {
                    final logs = modelController.filteredLogs;

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: logs.length,
                      itemBuilder: (context, i) {
                        return ModelLogTableRow(log: logs[i]);
                      },
                    );
                  }
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}
