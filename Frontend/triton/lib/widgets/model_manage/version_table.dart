// 버전 관리 테이블
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/model_manage/version_manage_controller.dart';
import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

import 'version_table_row.dart';

class VersionTable extends StatelessWidget {
  const VersionTable({super.key});

  static const double _headerH = 44.0;

  @override
  Widget build(BuildContext context) {
    final versionManageController = Get.find<VersionManageController>();

    return Obx(() {
      final items = versionManageController.versions;
      final selectedId = versionManageController.selectedVersionId.value;

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
                child: Row(
                  children: [
                    const SizedBox(width: 80),
                    SizedBox(width: 120, child: Center(child: _headerText('version'))),
                    Expanded(child: Center(child: _headerText('file name'))),
                    SizedBox(width: 240, child: Center(child: _headerText('user name'))),
                    SizedBox(width: 240, child: Center(child: _headerText('created at'))),
                  ],
                ),
              ),
              Expanded(
                child: RadioGroup<int>(
                  groupValue: selectedId,
                  onChanged: (int? id) {
                    if (id == null) return;
                    final row = items.firstWhere((e) => e.versionId == id);
                    versionManageController.selectVersion(row.versionId, row.version);
                  },
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: primaryLightest),
                      itemBuilder: (context, i) {
                        final row = items[i];
                        final isSelected = selectedId == row.versionId;
                        return VersionListRow(item: row, isSelected: isSelected);
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
