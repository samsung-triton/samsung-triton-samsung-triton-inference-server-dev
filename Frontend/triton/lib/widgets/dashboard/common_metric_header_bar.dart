import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/dropdown.dart'; // ✅ 기존 Dropdown 위젯 사용

class CommonMetricHeaderBar extends StatelessWidget {
  const CommonMetricHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ✅ 화면 폭에 맞춰 자동 확장
      height: 36, // ✅ 고정 높이 유지
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: white, // 배경색 유지
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: black, // ✅ 외곽선 색상
          width: 0.5, // ✅ 선 두께
        ),
      ),

      // ✅ 전체 Row 배치
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 왼쪽: Reset Time
              Row(
                children: [
                  Text("Reset Time", style: T.t16(color: primaryDarker, bold: true)),
                  const SizedBox(width: 8),
                  Dropdown(
                    width: 76,
                    items: const ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],
                    hintText: '06',
                  ),
                  const SizedBox(width: 4),
                  Dropdown(width: 76, items: const ['00', '10', '20', '30', '40', '50'], hintText: '30'),
                ],
              ),

              // ✅ 오른쪽: Last Updated + Update 버튼
              Row(
                children: [
                  Text("Last Updated", style: T.t16(color: primaryDarker, bold: true)),
                  const SizedBox(width: 8),

                  // 날짜
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
                    child: Text("Apr 1, 2025", style: T.t12(color: black)),
                  ),
                  const SizedBox(width: 4),

                  // 시간
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
                    child: Text("9:41 AM", style: T.t12(color: black)),
                  ),
                  const SizedBox(width: 8),

                  // ✅ Update 버튼
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: white,
                        foregroundColor: primaryDarker,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: lightGray),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // ✅ Hug width
                        children: [
                          Text('Update', style: T.t12(color: primaryDarker, bold: true)),
                          const SizedBox(width: 6),
                          SvgPicture.asset(
                            'assets/icons/restart_black.svg', // ✅ 항상 고정 아이콘
                            width: 12,
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
