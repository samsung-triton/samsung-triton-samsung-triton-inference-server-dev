// 모델 사이드바
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/controller/model_manage/model_manage_controller.dart';
import 'package:triton/widgets/model_manage/model_card.dart';
import 'package:triton/widgets/sidebar/sidebar_base.dart';

class ModelSidebar extends StatelessWidget {
  const ModelSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final modelManageController = Get.find<ModelManageController>();

    return Obx(() {
      final models = modelManageController.models;
      final selected = modelManageController.selectedModel.value?.modelId;

      // 모델 카드 리스트
      final cards = <Widget>[
        for (final model in models)
          ModelCard(type: ModelCardType.normal, item: model, active: model.modelId == selected),
        // 맨 아래 모델 추가 카드
        ModelCard(type: ModelCardType.add),
      ];

      return SidebarBase(children: cards);
    });
  }
}
