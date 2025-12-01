// 버전 관리 테이블 가로줄
import 'package:flutter/material.dart';
import 'package:triton/controller/model_manage/version_manage_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class VersionListRow extends StatelessWidget {
  final VersionItem item;
  final bool isSelected;

  const VersionListRow({super.key, required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    void selectThis() {
      // 부모에 정의된 라디오 그룹의 온체인지 호출
      RadioGroup.maybeOf<int>(context)?.onChanged.call(item.versionId);
    }

    return Material(
      color: isSelected ? primaryLightest : white,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: selectThis,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              SizedBox(width: 80, child: Radio<int>(value: item.versionId)),
              _textCell('${item.version}', width: 120),
              _textCell(item.fileName, expanded: true),
              _textCell(item.userName, width: 240),
              _textCell(item.createdAt, width: 240),
            ],
          ),
        ),
      ),
    );
  }

  // 내용 텍스트
  Widget _textCell(String text, {double? width, bool expanded = false}) {
    final child = Center(
      child: Text(text, style: T.t16(), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
    );

    if (expanded) return Expanded(child: child);
    return SizedBox(width: width, child: child);
  }
}
