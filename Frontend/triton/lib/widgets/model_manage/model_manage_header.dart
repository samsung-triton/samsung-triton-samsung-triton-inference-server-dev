// 버전 관리 테이블 위 헤더
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/model_manage/model_manage_controller.dart';
import '../../controller/model_manage/version_manage_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../../utils/modal_util.dart';

import '../button/button_large.dart';

import '../../widgets/modal/modal_registration.dart';

class ModelManageHeader extends StatelessWidget {
  const ModelManageHeader({super.key});

  // 등록 모달 열기
  void _openRegisterModal(BuildContext context) {
    ModalPortal.open(context, builder: (dialogContext) => const ModalRegistration(kind: RegistrationKind.setup));
  }

  @override
  Widget build(BuildContext context) {
    final modelManageController = Get.find<ModelManageController>();
    final versionManageController = Get.find<VersionManageController>();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 좌측: 모델 정보
          Obx(
            () => Text(modelManageController.selectedModelName.value, style: T.t20(bold: true, color: primaryNormal)),
          ),
          Obx(() => Text(' | ${versionManageController.versions.length} versions', style: T.t16())),
          const Spacer(),

          // 우측: 버전 관리 버튼
          ButtonLarge(onPressed: () => _openRegisterModal(context), text: 'register', backgroundColor: primaryNormal),
        ],
      ),
    );
  }
}
