// 버전 관리 테이블
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/model_manage/version_manage_controller.dart';

import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

import '../../utils/modal_util.dart';

import 'version_table_row.dart';

import '../../widgets/modal/modal_description.dart';

class VersionTable extends StatelessWidget {
  const VersionTable({super.key});

  static const double _headerH = 44.0;

  // 삭제 모달 열기
  void _openDeleteModal(BuildContext context) {
    final descCtrl = TextEditingController();

    ModalPortal.open(
      context,
      builder: (dialogCtx) => ModalDescription(
        descCtrl: descCtrl,
        confirmMsg: "Are you sure you want to delete it?",
        onOK: () async {
          final versionManageController = Get.find<VersionManageController>();
          await versionManageController.deleteSelectedVersion(descCtrl.text);
          descCtrl.dispose();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versionManageController = Get.find<VersionManageController>();

    return Obx(() {
      final versions = versionManageController.versions;
      int? selectedId = versionManageController.selectedVersion.value?.versionId;

      if (versions.isEmpty) {
        selectedId = null;

        Future.microtask(() {
          versionManageController.selectedVersion.value = null;
        });
      } else {
        // 선택된 ID가 현재 리스트에 없으면 안전하게 재선택
        if (selectedId != null && !versions.any((version) => version.versionId == selectedId)) {
          selectedId = null; // 로컬에서는 우선 해제

          Future.microtask(() {
            // 목록이 비지 않으므로 첫 번째 버전을 기본 선택으로
            versionManageController.selectedVersion.value = versions.first;
          });
        }

        // 아무것도 선택 안 돼 있으면 첫 번째 버전을 기본 선택으로
        if (selectedId == null && versionManageController.selectedVersion.value == null) {
          Future.microtask(() {
            versionManageController.selectedVersion.value = versions.first;
          });
          selectedId = versions.first.versionId;
        }
      }

      return SizedBox(
        width: double.infinity,
        height: 220,
        child: Material(
          color: white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: primaryDarkest),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: _headerH,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 80),
                        SizedBox(width: 120, child: Center(child: _headerText('version'))),
                        Expanded(child: Center(child: _headerText('file name'))),
                        SizedBox(width: 240, child: Center(child: _headerText('user name'))),
                        SizedBox(width: 240, child: Center(child: _headerText('created at'))),
                      ],
                    ),
                    // 삭제 아이콘
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            onPressed: () => _openDeleteModal(context),
                            icon: Icon(Icons.delete_outline, size: 20, color: gray),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RadioGroup<int>(
                  groupValue: selectedId,
                  onChanged: (int? id) {
                    if (id == null) return;
                    final row = versions.firstWhere((e) => e.versionId == id);
                    versionManageController.selectVersion(row.versionId);
                  },
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: versions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: primaryLightest),
                      itemBuilder: (context, i) {
                        final row = versions[i];
                        final isSelected = selectedId == row.versionId;
                        return VersionListRow(key: ValueKey(row.versionId), item: row, isSelected: isSelected);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 헤더 텍스트
  Widget _headerText(String label) {
    return Text(
      label,
      style: T.t16(bold: true, color: black),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
