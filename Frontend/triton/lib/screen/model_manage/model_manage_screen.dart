// 모델 관리 스크린
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/model_manage/model_manage_controller.dart';
import '../../controller/model_manage/version_manage_controller.dart';
import '../../controller/model_manage/config_controller.dart';

import '../../widgets/model_manage/model_sidebar.dart';
import '../../widgets/model_manage/model_manage_header.dart';
import '../../widgets/model_manage/version_table.dart';
import '../../widgets/model_manage/editor_header.dart';
import '../../widgets/model_manage/code_editor.dart';

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

    // 화면 스코프 주입
    modelManageController = Get.put(ModelManageController(), permanent: false);
    versionManageController = Get.put(VersionManageController(), permanent: false);
    codeEditorController = Get.put(ConfigController(), permanent: false);

    // 모델들 불러오기
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
        // 좌측: 모델 사이드바
        const ModelSidebar(),

        // 우측: 버전 헤더 + 테이블 + 에디터
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Obx(() {
              final selected = modelManageController.selectedModel.value;
              final isNormal = selected?.type == 'NORMAL';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ModelManageHeader(),
                  if (isNormal) ...[const VersionTable(), const SizedBox(height: 24)],
                  const EditorHeader(),
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
