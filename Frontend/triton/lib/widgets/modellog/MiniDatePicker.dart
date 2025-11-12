import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class MiniDatePicker extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? firstDate;

  const MiniDatePicker({super.key, this.onDateSelected, this.firstDate});

  @override
  State<MiniDatePicker> createState() => _MiniDatePickerState();
}

class _MiniDatePickerState extends State<MiniDatePicker> {
  final GlobalKey _buttonKey = GlobalKey(); // 버튼 위치 계산용 Key
  DateTime? selectedDate = DateTime.now();
  OverlayEntry? _overlayEntry;

  void _toggleCalendar() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 전체 화면 클릭 감지용 반투명 배경 (달력 닫기)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent, // 빈 공간 클릭도 감지
              onTap: _removeOverlay,
              child: Container(color: Colors.transparent), // 투명 배경
            ),
          ),

          Positioned(
            left: offset.dx,
            top: offset.dy + renderBox.size.height - 44, //버튼의 위치를 제대로 잡지 못해서 위치 수동으로 조정
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: renderBox.size.width,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: lightGray),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TableCalendar(
                  focusedDay: selectedDate ?? DateTime.now(),
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  enabledDayPredicate: (day) {
                    if (widget.firstDate == null) return true;
                    return !day.isBefore(widget.firstDate!);
                  },
                  availableGestures: AvailableGestures.horizontalSwipe,
                  rowHeight: 32,
                  daysOfWeekHeight: 18,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    leftChevronIcon: Icon(Icons.chevron_left, size: 20, color: Colors.grey),
                    rightChevronIcon: Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  ),
                  calendarStyle: const CalendarStyle(
                    defaultTextStyle: TextStyle(fontSize: 10, color: black),
                    weekendTextStyle: TextStyle(fontSize: 10, color: black),
                    todayTextStyle: TextStyle(fontSize: 10, color: black),
                    outsideTextStyle: TextStyle(fontSize: 10, color: gray),
                    disabledTextStyle: TextStyle(fontSize: 10, color: lightGray),
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(color: primaryNormal, shape: BoxShape.rectangle),
                    todayDecoration: BoxDecoration(color: lightGray, shape: BoxShape.rectangle),
                    selectedTextStyle: TextStyle(fontSize: 11, color: white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontSize: 10, color: black, fontWeight: FontWeight.w500),
                    weekendStyle: TextStyle(fontSize: 10, color: black, fontWeight: FontWeight.w500),
                  ),
                  selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDate = selected;
                    });

                    widget.onDateSelected?.call(selected);

                    _removeOverlay(); // 날짜 선택 시 닫기
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedDate != null) widget.onDateSelected?.call(selectedDate!);
    });
    return GestureDetector(
      onTap: _toggleCalendar,
      child: Container(
        key: _buttonKey, // 버튼 위치 추적용 Key
        height: 28,
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: lightGray),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 12, color: selectedDate == null ? lightGray : black),
            const SizedBox(width: 8),
            Text(
              selectedDate == null ? 'YYYY.MM.DD' : DateFormat('yyyy.MM.dd').format(selectedDate!),
              style: selectedDate == null ? T.t12(color: lightGray, bold: false) : T.t12(color: black, bold: false),
            ),
          ],
        ),
      ),
    );
  }
}
