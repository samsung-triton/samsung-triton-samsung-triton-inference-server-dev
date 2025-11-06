import 'package:flutter/material.dart';
import 'package:triton/widgets/modellog/filter_block.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class FilterToggleSection extends StatefulWidget {
  const FilterToggleSection({super.key});

  @override
  State<FilterToggleSection> createState() => _FilterToggleSectionState();
}

class _FilterToggleSectionState extends State<FilterToggleSection> {
  bool _isOpen = false; // 필터 열림 상태 (초기: 닫혀있음)

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // filter 버튼
        GestureDetector(
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: black, size: 24),
              const SizedBox(width: 2),
              Text("filter", style: T.t16(color: black, bold: false)),
            ],
          ),
        ),

        // 필터 블록 영역 (토글로 열고 닫기)
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: _isOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 20),
            curve: Curves.easeInOut,
            child: const FilterBlock(),
          ),
        ),
      ],
    );
  }
}
