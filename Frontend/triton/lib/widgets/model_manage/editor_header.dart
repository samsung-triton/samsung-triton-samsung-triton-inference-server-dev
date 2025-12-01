// 컨피그 에디터 헤더
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_manage/config_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/utils/modal_util.dart';
import 'package:triton/widgets/button/button_large.dart';
import 'package:triton/widgets/modal/modal_description.dart';
import 'package:triton/widgets/modal/modal_rollback.dart';

class EditorHeader extends StatelessWidget {
  const EditorHeader({super.key});

  // 롤백 리스트 모달 열기
  Future<void> _openRollbackModal(BuildContext context) async {
    final codeEditorController = Get.find<ConfigController>();

    // 목록 불러오기 호출
    await codeEditorController.loadRollbacks();
    ModalPortal.open(context, builder: (dialogContext) => const ModalRollback());
  }

  // 저장 모달 열기
  void _openSaveModal(BuildContext context) {
    final descCtrl = TextEditingController();

    ModalPortal.open(
      context,
      builder: (dialogCtx) => ModalDescription(
        descCtrl: descCtrl,
        confirmMsg: "Are you sure you want to save it?",
        onOK: () async {
          final codeEditorController = Get.find<ConfigController>();

          // config 저장 호출
          final ok = await codeEditorController.save(descCtrl.text);
          descCtrl.dispose();
          if (ok) {
            _openRollbackModal(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text("config.pbtxt", style: T.t20(bold: true, color: darkGray)),

          const Spacer(),

          // 롤백 버튼
          ButtonLarge(onPressed: () => _openRollbackModal(context), text: 'rollback', backgroundColor: primaryNormal),
          const SizedBox(width: 10),
          // 저장 버튼
          ButtonLarge(onPressed: () => _openSaveModal(context), text: 'save', backgroundColor: primaryNormal),
        ],
      ),
    );
  }
}
