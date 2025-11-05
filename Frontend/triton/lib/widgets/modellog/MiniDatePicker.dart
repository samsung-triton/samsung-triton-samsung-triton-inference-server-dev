import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class MiniDatePicker extends StatefulWidget {
  const MiniDatePicker({super.key});

  @override
  State<MiniDatePicker> createState() => _MiniDatePickerState();
}

class _MiniDatePickerState extends State<MiniDatePicker> {
  DateTime? selectedDate;
  bool showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => showCalendar = !showCalendar),
          child: Container(
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
        ),

        // 아래에 달력 표시
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: showCalendar ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            width: 200,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: lightGray),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TableCalendar(
              focusedDay: selectedDate ?? DateTime.now(),
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              availableGestures: AvailableGestures.horizontalSwipe,
              headerVisible: true, // 상단 년/월 숨김
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
                todayTextStyle: TextStyle(fontSize: 10, color: white),
                outsideTextStyle: TextStyle(fontSize: 10, color: gray),
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(color: primaryNormal, shape: BoxShape.rectangle),
                todayDecoration: BoxDecoration(color: gray, shape: BoxShape.rectangle),
                selectedTextStyle: TextStyle(fontSize: 11, color: white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                //요일
                weekdayStyle: TextStyle(fontSize: 10, color: black, fontWeight: FontWeight.w500),
                weekendStyle: TextStyle(fontSize: 10, color: black, fontWeight: FontWeight.w500),
              ),
              selectedDayPredicate: (day) => isSameDay(day, selectedDate),
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDate = selected;
                  showCalendar = false; // 날짜 선택 후 닫기
                });
              },
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
