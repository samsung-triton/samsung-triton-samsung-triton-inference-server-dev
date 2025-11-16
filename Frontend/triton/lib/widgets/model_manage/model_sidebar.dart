// 모델 사이드바
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/model_manage/model_manage_controller.dart';

import '../sidebar/sidebar_base.dart';
import 'model_card.dart';

class ModelSidebar extends StatelessWidget {
  const ModelSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final modelManageController = Get.find<ModelManageController>();

    return Obx(() {
      final models = modelManageController.models;
      final selected = modelManageController.selectedModel.value?.modelId;

      // 카드 리스트
      final cards = <Widget>[
        for (final model in models)
          ModelCard(type: ModelCardType.normal, item: model, active: model.modelId == selected),
        // 맨 아래 추가 카드
        ModelCard(type: ModelCardType.add),
      ];

      return SidebarBase(children: cards);
    });
  }
}
