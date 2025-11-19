import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_log/model_log_controller.dart';
import 'package:triton/controller/model_log/triton_infer_log_controller.dart';
import 'package:triton/controller/model_log/triton_server_log_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/infer_log_table_row.dart';
import 'package:triton/widgets/modellog/triton_log_table_header.dart';
import 'package:triton/widgets/modellog/triton_log_table_row.dart';

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

      final tritonInferController = Get.find<TritonInferLogController>();

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500) {
        final model = tritonInferController.modelName.value;

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

    final tritonInferController = Get.find<TritonInferLogController>();

    return Container(
      padding: const EdgeInsets.all(8),
      color: white,
      child: Column(
        children: [
          const TritonLogTableHeader(),

          Expanded(
            child: Obx(() {
              final model = tritonInferController.modelName.value;

              if (tritonServerLogController.isLoading.value && tritonServerLogController.filteredLogs.isEmpty ||
                  modelController.isLoading.value && modelController.filteredLogs.isEmpty) {
                return Center(
                  child: Text("Loading...", style: T.t12(color: gray, bold: false)),
                );
              }

              if (model.isEmpty) {
                return Center(
                  child: Text('Please select a model.', style: T.t12(color: gray)),
                );
              }

              // 🔥 로그 분기
              final logs = (model == 'Triton Server')
                  ? tritonServerLogController.filteredLogs
                  : modelController.filteredLogs;

              if (logs.isEmpty) {
                return Center(
                  child: Text('There are no logs matching the selected conditions.', style: T.t12(color: gray)),
                );
              }

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
                        return TritonLogTableRow(log: logs[i]);
                      },
                    );
                  } else {
                    final logs = modelController.filteredLogs;

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: logs.length,
                      itemBuilder: (context, i) {
                        return InferLogTableRow(log: logs[i]);
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
