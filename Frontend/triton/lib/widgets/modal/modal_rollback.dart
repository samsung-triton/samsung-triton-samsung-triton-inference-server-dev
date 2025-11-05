import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import '../button/button_medium.dart';
import 'modal_base.dart';

class RollbackItem {
  final int id;
  final String createdAt;
  final String userName;

  RollbackItem({required this.id, required this.createdAt, required this.userName});
}

/// ─────────────────────────────
/// Main Modal Component
/// ─────────────────────────────
class ModalRollback extends StatefulWidget {
  final List<RollbackItem> rollbackList;
  final VoidCallback? onGet;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  const ModalRollback({Key? key, required this.rollbackList, this.onGet, this.onDelete, this.onClose})
    : super(key: key);

  @override
  State<ModalRollback> createState() => _ModalRollbackState();
}

class _ModalRollbackState extends State<ModalRollback> {
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: 'rollback',
      onClose: widget.onClose,
      width: 428,
      borderRadius: 8,
      dividerColor: primaryDarker,
      borderColor: lightGray,
      backgroundColor: white,
      titleColor: primaryDarker,
      contentSpacing: 0,
      children: [
        const SizedBox(height: 4),
        RollbackTable(
          items: widget.rollbackList,
          selectedId: selectedId,
          onSelect: (id) => setState(() => selectedId = id),
        ),
        const SizedBox(height: 16),
        RollbackButtonRow(onGet: widget.onGet, onDelete: widget.onDelete),
      ],
    );
  }
}

class RollbackTable extends StatelessWidget {
  final List<RollbackItem> items;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const RollbackTable({super.key, required this.items, required this.selectedId, required this.onSelect});

  // ✅ 412px 컨텐츠 폭을 4개의 컬럼으로 ‘공통’ 정의
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
          // ── Header
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

          // ── Rows
          Table(
            columnWidths: _col,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (final item in items)
                TableRow(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Transform.scale(
                        scale: 0.8,
                        child: RadioTheme(
                          data: const RadioThemeData(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          ),
                          child: Radio<int>(
                            value: item.id,
                            groupValue: selectedId,
                            activeColor: primaryNormal,
                            onChanged: (_) => onSelect(item.id),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text('${item.id}', style: T.t12(color: darkGray)),
                    ),
                    Center(
                      child: Text(item.createdAt, style: T.t12(color: darkGray)),
                    ),
                    Center(
                      child: Text(item.userName, style: T.t12(color: darkGray)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────
/// Bottom Button Row
/// ─────────────────────────────
class RollbackButtonRow extends StatelessWidget {
  final VoidCallback? onGet;
  final VoidCallback? onDelete;

  const RollbackButtonRow({super.key, this.onGet, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ButtonMedium(text: 'get', onPressed: onGet, backgroundColor: primaryNormal, textColor: white),
        const SizedBox(width: 16),
        ButtonMedium(text: 'delete', onPressed: onDelete, backgroundColor: lightGray, textColor: darkGray),
      ],
    );
  }
}
