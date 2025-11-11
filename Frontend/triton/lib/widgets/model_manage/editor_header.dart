// 컨피그 에디터 헤더
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/model_manage/config_controller.dart';

import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

import '../../utils/modal_util.dart';

import '../button/button_large.dart';

import '../../widgets/modal/modal_rollback.dart';

class EditorHeader extends StatelessWidget {
  const EditorHeader({super.key});

  // 롤백 모달 열기
  Future<void> _openRegisterModal(BuildContext context) async {
    final codeEditorController = Get.find<ConfigController>();

    await codeEditorController.loadRollbacks();
    ModalPortal.open(context, builder: (dialogContext) => const ModalRollback());
  }

  @override
  Widget build(BuildContext context) {
    final codeEditorController = Get.find<ConfigController>();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text("config.pbtxt", style: T.t20(bold: true, color: darkGray)),

          const Spacer(),

          // 롤백 버튼
          ButtonLarge(onPressed: () => _openRegisterModal(context), text: 'rollback', backgroundColor: primaryNormal),
          const SizedBox(width: 10),
          // 저장 버튼
          ButtonLarge(onPressed: () => codeEditorController.save, text: 'save', backgroundColor: primaryNormal),
        ],
      ),
    );
  }
}
