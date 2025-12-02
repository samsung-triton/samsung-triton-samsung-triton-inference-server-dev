// 모델 관리 최상단 헤더
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_manage/model_manage_controller.dart';
import 'package:triton/controller/model_manage/version_manage_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/utils/modal_util.dart';
import 'package:triton/widgets/button/button_large.dart';
import 'package:triton/widgets/modal/modal_registration.dart';

class ModelManageHeader extends StatelessWidget {
  const ModelManageHeader({super.key});

  // 등록 모달 열기 기능 (에셋 버전)
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
      child: Obx(() {
        final selected = modelManageController.selectedModel.value;
        final name = selected?.name ?? '';
        final isNormal = selected?.type == 'NORMAL';
        final versionsCount = versionManageController.versions.length;

        return Row(
          children: [
            // 좌측 모델 정보
            Text(name, style: T.t20(bold: true, color: primaryNormal)),
            // 버전 갯수 (NORMAL일 때만 보이게)
            if (isNormal) Text(' | $versionsCount versions', style: T.t16()),
            const Spacer(),

            // 우측 버전 관리 버튼 (NORMAL일 때만 보이게)
            if (isNormal)
              ButtonLarge(
                onPressed: () => _openRegisterModal(context),
                text: 'register',
                backgroundColor: primaryNormal,
              ),
          ],
        );
      }),
    );
  }
}
