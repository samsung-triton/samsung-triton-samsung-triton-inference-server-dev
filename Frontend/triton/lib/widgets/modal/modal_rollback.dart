// 롤백 목록 모달
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/model_manage/config_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../../utils/modal_util.dart';

import '../button/button_medium.dart';
import 'modal_base.dart';

import '../../widgets/modal/modal_description.dart';

class ModalRollback extends StatefulWidget {
  const ModalRollback({super.key});

  @override
  State<ModalRollback> createState() => _ModalRollbackState();
}

class _ModalRollbackState extends State<ModalRollback> {
  // 삭제 모달 열기
  void _openDeleteModal(BuildContext context) {
    final descCtrl = TextEditingController();

    ModalPortal.open(
      context,
      builder: (dialogCtx) => ModalDescription(
        descCtrl: descCtrl,
        confirmMsg: "Are you sure you want to delete it?",
        onOK: () async {
          final configController = Get.find<ConfigController>();
          // TODO: 추후 descCtrl 글자 추가
          configController.deleteRollback();
          descCtrl.dispose();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configController = Get.find<ConfigController>();

    return Obx(() {
      final rollbacks = configController.rollbacks;
      final selectedId = configController.selectedConfigId.value;

      // 선택된 항목이 서버 사용중(isCurrent)인지 체크
      bool isCurrentSelected = false;
      if (selectedId != null) {
        for (final e in rollbacks) {
          if (e.configId == selectedId) {
            isCurrentSelected = e.isCurrent;
            break;
          }
        }
      }

      return ModalBase(
        title: 'rollback',
        width: 428,
        borderRadius: 8,
        dividerColor: primaryDarkest,
        borderColor: Colors.transparent,
        backgroundColor: white,
        titleColor: primaryDarkest,
        contentSpacing: 0,
        children: [
          const SizedBox(height: 4),
          RadioGroup<int>(
            groupValue: selectedId,
            onChanged: (id) {
              if (id != null) configController.selectedConfigId.value = id;
            },
            child: RollbackTable(
              items: rollbacks,
              selectedId: selectedId,
              onSelect: (id) {
                configController.selectedConfigId.value = id;
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonMedium(
                text: 'get',
                onPressed: () {
                  configController.getRollback();
                  Navigator.of(context).pop();
                },
                backgroundColor: primaryNormal,
                textColor: white,
              ),
              const SizedBox(width: 16),
              ButtonMedium(
                text: 'delete',
                onPressed: !isCurrentSelected ? () => _openDeleteModal(context) : null,
                backgroundColor: !isCurrentSelected ? lightGray : gray.withAlpha(128),
                textColor: darkGray,
              ),
            ],
          ),
        ],
      );
    });
  }
}

class RollbackTable extends StatelessWidget {
  final List<RollbackItem> items;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const RollbackTable({super.key, required this.items, required this.selectedId, required this.onSelect});

  // 412px 컨텐츠 폭을 4개의 컬럼으로 ‘공통’ 정의
  static const Map<int, TableColumnWidth> _col = {
    0: FixedColumnWidth(50), // Radio 자리(오른쪽 정렬)
    1: FlexColumnWidth(1), // no
    2: FlexColumnWidth(3), // create at
    3: FlexColumnWidth(2), // user name
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 412,
      child: Column(
        children: [
          // 테이블 헤더
          Table(
            columnWidths: _col,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 0.5, color: primaryDarker)),
                ),
                children: [
                  const SizedBox(),
                  Center(
                    child: Text('no', style: T.t16(color: primaryDarker, bold: true)),
                  ),
                  Center(
                    child: Text('create at', style: T.t16(color: primaryDarker, bold: true)),
                  ),
                  Center(
                    child: Text('user name', style: T.t16(color: primaryDarker, bold: true)),
                  ),
                ],
              ),
            ],
          ),

          // 데이터
          Column(
            children: [for (final item in items) RollbackListRow(item: item, isSelected: selectedId == item.configId)],
          ),
        ],
      ),
    );
  }
}

// 롤백 데이터 가로줄
class RollbackListRow extends StatelessWidget {
  final RollbackItem item;
  final bool isSelected;

  const RollbackListRow({super.key, required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    void selectThis() {
      // 부모에 정의된 라디오 그룹의 온체인지 호출
      RadioGroup.maybeOf<int>(context)?.onChanged.call(item.configId);
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
              SizedBox(
                width: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Transform.scale(scale: 0.8, child: Radio<int>(value: item.configId)),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    '${item.configId}',
                    style: T.t12(color: darkGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    _fmt(item.createdAt),
                    style: T.t12(color: darkGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    item.userName,
                    style: T.t12(color: darkGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }
}
