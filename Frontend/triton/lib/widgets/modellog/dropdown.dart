import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class Dropdown extends StatefulWidget {
  final double? width;
  final double? height;
  final List<String> items;
  final String hintText;

  const Dropdown({super.key, this.width, this.height, required this.items, this.hintText = 'Select an item'});

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? selectedModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 300,
      height: widget.height ?? 28,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(widget.hintText, style: T.t12(color: gray, bold: false)),
          value: selectedModel,
          iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down, color: black), iconSize: 20),
          buttonStyleData: ButtonStyleData(
            height: widget.height ?? 28,
            padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(left: 0),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(color: lightGray, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            elevation: 0,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: lightGray, width: 1),
            ),
            offset: const Offset(0, 0), // 드롭다운을 아래로 띄움
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 28, // 각 항목의 높이
            padding: const EdgeInsets.symmetric(horizontal: 12), // 좌우 여백
            overlayColor: WidgetStateProperty.all(
              primaryLightest.withValues(alpha: 0.2), // 커서 위치 배경색
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              selectedModel = newValue!;
            });
          },
          items: widget.items.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: T.t12(color: black, bold: false)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
