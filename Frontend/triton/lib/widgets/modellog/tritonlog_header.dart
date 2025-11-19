import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_log/model_log_controller.dart';
import 'package:triton/controller/model_log/triton_infer_log_controller.dart';
import 'package:triton/controller/model_log/triton_log_controller.dart';
import 'package:triton/widgets/modellog/DownloadIconButton.dart';
import 'package:triton/widgets/modellog/dropdown.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/filter_block_Infer.dart';
import 'package:triton/widgets/modellog/filter_block_triton.dart';

class TritonLogHeader extends StatefulWidget {
  const TritonLogHeader({super.key});

  @override
  State<TritonLogHeader> createState() => _TritonLogHeaderState();
}

class _TritonLogHeaderState extends State<TritonLogHeader> with SingleTickerProviderStateMixin {
  bool _isFilterOpen = false;

  @override
  Widget build(BuildContext context) {
    final tritonInferController = Get.find<TritonInferLogController>();
    final tritonController = Get.find<TritonLogController>();
    final modelController = Get.find<ModelLogController>();

    return Column(
      children: [
        const SizedBox(height: 8),

        // 상단 헤더
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //왼쪽 :Model Log + Dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Model Log", style: T.t16(color: black, bold: true)),
                  const SizedBox(width: 12),
                  Obx(() {
                    return Dropdown(
                      items: tritonInferController.modelList.toList(), // API + 'triton' 포함된 동적 리스트
                      width: 244,
                      hintText: "model name",
                      onChanged: (value) {
                        tritonController.modelName.value = value ?? '';
                        modelController.modelName.value = value ?? '';
                        tritonInferController.modelName.value = value ?? '';

                        if (value == "triton") {
                          tritonController.applyFilter(); // 서로 다른 흐름이면 분기
                        } else {
                          modelController.applyFilter();
                        }
                      },
                    );
                  }),
                  const SizedBox(width: 12),
                  DownloadIconButton(
                    onPressed: () {
                      if (tritonInferController.modelName.value == 'triton') {
                        tritonController.exportFilteredLogsAsTxt(); // Triton 로그 다운로드
                      } else {
                        modelController.exportFilteredLogsAsTxt(); // 모델별 Infer 로그 다운로드
                      }
                    },
                  ),
                ],
              ),

              // 오른쪽: filter 토글
              Obx(() {
                if (tritonController.modelName.value.isEmpty) {
                  return const SizedBox.shrink(); // model name 선택 전에는 숨김
                }

                return GestureDetector(
                  onTap: () => setState(() => _isFilterOpen = !_isFilterOpen),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_isFilterOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: black, size: 24),
                      const SizedBox(width: 2),
                      Text("filter", style: T.t16(color: black)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // 필터 영역 (열리면 아래 컨텐츠 밀림)
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isFilterOpen
              ? Obx(() {
                  final server = tritonInferController.modelName.value;

                  if (server == 'triton') {
                    return const FilterBlockTriton();
                  } else {}
                  return const FilterBlockInfer();
                })
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
