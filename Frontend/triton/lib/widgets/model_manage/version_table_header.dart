// 버전 관리 테이블 위 헤더
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/model_manage/version_manage_controller.dart';
import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

import '../button/button_large.dart';

class VersionTableHeader extends StatelessWidget {
  const VersionTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final versionManageController = Get.find<VersionManageController>();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 좌측: 모델 정보
          Obx(
            () => Text(versionManageController.currentModelName.value, style: T.t20(bold: true, color: primaryNormal)),
          ),
          Obx(() => Text(' | ${versionManageController.versions.length} versions', style: T.t16())),
          const Spacer(),

          // 우측: 버전 관리 버튼
          ButtonLarge(
            onPressed: () => versionManageController.registerVersion(),
            text: 'register',
            backgroundColor: primaryNormal,
          ),
          const SizedBox(width: 8),
          ButtonLarge(
            onPressed: () => versionManageController.deleteSelectedVersion(),
            text: 'delete',
            backgroundColor: lightGray,
            textColor: black,
          ),
        ],
      ),
    );
  }
}
