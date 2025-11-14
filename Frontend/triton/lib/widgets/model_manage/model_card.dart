// 모델 사이드바 카드
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:triton/controller/model_manage/model_manage_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../../utils/modal_util.dart';

import '../sidebar/sidebar_card_base.dart';

import '../../widgets/modal/modal_registration.dart';
import '../../widgets/modal/modal_description.dart';

// 모델 카드 종류
enum ModelCardType { normal, add }

class ModelCard extends StatelessWidget {
  final ModelCardType type;
  final ModelItem? item;
  final bool active;

  const ModelCard({super.key, required this.type, this.item, this.active = false})
    : assert(type != ModelCardType.normal || item != null, 'NORMAL 카드에서는 item이 필요합니다.');

  // 등록 모달 열기
  void _openRegisterModal(BuildContext context) {
    ModalPortal.open(context, builder: (dialogContext) => const ModalRegistration(kind: RegistrationKind.model));
  }

  // 삭제 모달 열기
  void _openDeleteModal(BuildContext context) {
    final descCtrl = TextEditingController();
    final modelId = item?.modelId;

    ModalPortal.open(
      context,
      builder: (dialogCtx) => ModalDescription(
        descCtrl: descCtrl,
        confirmMsg: "Are you sure you want to delete it?",
        onOK: () async {
          final modelManageController = Get.find<ModelManageController>();
          // TODO: 추후 descCtrl 글자 추가
          await modelManageController.deleteModel(modelId!, descCtrl.text);
          descCtrl.dispose();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdd = type == ModelCardType.add;
    final fg = active ? white : black;
    final modelManageController = Get.find<ModelManageController>();

    return SidebarCardBase(
      isActive: active,
      onTap: isAdd ? () => _openRegisterModal(context) : () => modelManageController.selectModel(item!.modelId),
      child: SizedBox(
        width: double.infinity,
        child: isAdd
            // ADD 카드
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: primaryLightest, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 20, color: primaryDarkest),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'register new model',
                      style: T.t10(color: black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            // NORMAL 카드
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 배지 + 삭제
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: (item?.status ?? false) ? secondaryLightest : lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (item?.status ?? false) ? 'load' : 'unload',
                          style: T.t10(bold: true, color: (item?.status ?? false) ? secondaryDarkest : darkGray),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'delete',
                        onPressed: () => _openDeleteModal(context),
                        icon: Icon(Icons.delete_outline, size: 20, color: active ? lightGray : gray),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                      ),
                    ],
                  ),

                  // 모델 이름
                  Text(
                    item?.name ?? '',
                    style: T.t20(bold: true, color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // 하단: last loaded | versions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'last loaded: ${item?.lastLoadedVersion ?? 'N/A'}',
                          style: T.t8(color: active ? lightGray : gray),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${item?.totalVersions ?? 0} versions',
                        style: T.t8(color: active ? lightGray : gray),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
