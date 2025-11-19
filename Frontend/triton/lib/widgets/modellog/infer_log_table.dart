import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_log/model_log_controller.dart';
import 'package:triton/controller/model_log/triton_infer_log_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/infer_log_table_row.dart';
import 'package:triton/widgets/modellog/triton_log_table_header.dart';

class InferLogTable extends StatefulWidget {
  const InferLogTable({super.key});

  @override
  State<InferLogTable> createState() => _InferLogTableState();
}

class _InferLogTableState extends State<InferLogTable> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final modelController = Get.find<ModelLogController>();

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500) {
        modelController.fetchMoreLogs(); // 무한 스크롤 트리거
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              final logs = modelController.filteredLogs;

              if (modelController.isLoading.value && modelController.filteredLogs.isEmpty) {
                return Center(
                  child: Text("Loading...", style: T.t12(color: gray, bold: false)),
                );
              }

              if (tritonInferController.modelName.value.isEmpty) {
                return Center(
                  child: Text('Please select a model.', style: T.t12(color: gray, bold: false)),
                );
              }
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
                thickness: 8,
                interactive: true,
                child: ListView.builder(
                  controller: scrollController, // 연결
                  itemCount: logs.length,
                  itemBuilder: (context, i) {
                    final log = logs[i];
                    return InferLogTableRow(log: log);
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
