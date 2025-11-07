// 모델 사이드바 카드
import 'package:flutter/material.dart';
import 'package:triton/controller/model_manage/model_manage_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../sidebar/sidebar_card_base.dart';

enum ModelCardType { normal, add }

class ModelCard extends StatelessWidget {
  final ModelCardType type;

  // 보여줄 모델 아이템
  // 모델 컨트롤러에 들어있음
  final ModelItem? item;

  // 공통 인터랙션
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  // 일반 모델 카드
  const ModelCard.normal({super.key, required this.item, this.active = false, this.onTap, this.onDelete})
    : type = ModelCardType.normal;

  // 추가 카드
  const ModelCard.add({super.key, required this.onTap})
    : item = null,
      active = false,
      onDelete = null,
      type = ModelCardType.add;

  @override
  Widget build(BuildContext context) {
    final isAdd = type == ModelCardType.add;
    final fg = active ? white : black;

    return SidebarCardBase(
      isActive: active,
      onTap: onTap,
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
                          color: (item?.isLoaded ?? false) ? secondaryLightest : lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (item?.isLoaded ?? false) ? 'load' : 'unload',
                          style: T.t10(bold: true, color: (item?.isLoaded ?? false) ? secondaryDarkest : darkGray),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'delete',
                        onPressed: onDelete,
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
                          'last loaded: ${item?.lastLoaded ?? '-'}',
                          style: T.t8(color: active ? lightGray : gray),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${item?.versionsCount ?? 0} versions',
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
