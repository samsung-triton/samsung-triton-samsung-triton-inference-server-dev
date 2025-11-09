// 컨피그 에디터 헤더
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/model_manage/code_editor_controller.dart';
import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

import '../button/button_large.dart';

class EditorHeader extends StatelessWidget {
  const EditorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final codeEditorController = Get.find<CodeEditorController>();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text("config.pbtxt", style: T.t20(bold: true, color: darkGray)),

          const Spacer(),

          // 롤백 버튼
          Obx(() {
            final enabled = codeEditorController.currentModelId.value != null;
            return ButtonLarge(
              onPressed: enabled ? codeEditorController.rollback : null,
              text: 'rollback',
              backgroundColor: primaryNormal,
            );
          }),

          const SizedBox(width: 10),

          // 저장 버튼
          Obx(() {
            final enabled = codeEditorController.currentModelId.value != null;
            return ButtonLarge(
              onPressed: enabled ? codeEditorController.save : null,
              text: 'save',
              backgroundColor: primaryNormal,
            );
          }),
        ],
      ),
    );
  }
}
