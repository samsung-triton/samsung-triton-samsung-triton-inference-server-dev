// 모델 관리 화면
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_manage/config_controller.dart';
import 'package:triton/controller/model_manage/model_manage_controller.dart';
import 'package:triton/controller/model_manage/version_manage_controller.dart';
import 'package:triton/widgets/model_manage/code_editor.dart';
import 'package:triton/widgets/model_manage/editor_header.dart';
import 'package:triton/widgets/model_manage/model_manage_header.dart';
import 'package:triton/widgets/model_manage/model_sidebar.dart';
import 'package:triton/widgets/model_manage/version_table.dart';

class ModelManageScreen extends StatefulWidget {
  const ModelManageScreen({super.key});

  @override
  State<ModelManageScreen> createState() => _ModelManageScreenState();
}

class _ModelManageScreenState extends State<ModelManageScreen> {
  late final ModelManageController modelManageController;
  late final VersionManageController versionManageController;
  late final ConfigController codeEditorController;

  @override
  void initState() {
    super.initState();

    modelManageController = Get.put(ModelManageController(), permanent: false);
    versionManageController = Get.put(VersionManageController(), permanent: false);
    codeEditorController = Get.put(ConfigController(), permanent: false);

    // 모델 리스트 불러오기 호출
    modelManageController.loadModels();
  }

  @override
  void dispose() {
    Get.delete<ModelManageController>();
    Get.delete<VersionManageController>();
    Get.delete<ConfigController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 왼쪽 모델 리스트 사이드바
        const ModelSidebar(),

        // 오른쪽 관리 화면
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Obx(() {
              final selected = modelManageController.selectedModel.value;
              // 노말 모델인지 확인
              final isNormal = selected?.type == 'NORMAL';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 모델 관리 헤더
                  const ModelManageHeader(),
                  // 노말 모델인 경우 버전 테이블
                  if (isNormal) ...[const VersionTable(), const SizedBox(height: 24)],
                  // config.pbtxt 관리 헤더
                  const EditorHeader(),
                  // config.pbtxt 에디터
                  const Expanded(child: CodeEditor()),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
