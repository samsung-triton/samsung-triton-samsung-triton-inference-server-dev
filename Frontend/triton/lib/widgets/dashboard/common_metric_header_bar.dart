// 대시보드 메트릭 상단 헤더바 (Reset Time / Last Updated / Update 버튼)

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart' as dash;
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/input/dropdown.dart';
import 'package:triton/widgets/button/button_small.dart';

class CommonMetricHeaderBar extends StatelessWidget {
  // 외부에서 전달받는 Refresh 콜백
  final VoidCallback? onRefresh;

  const CommonMetricHeaderBar({super.key, this.onRefresh});

  // 읽기 전용 드롭다운(비개발자용)
  Widget _fakeDropdown(String text, double width) {
    return Container(
      width: width,
      height: 28,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: white,
        border: Border.all(color: lightGray),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: T.t12(color: gray)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<dash.DashboardController>();

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: black, width: 0.5),
      ),

      // 좌측: Reset Time  / 우측: Last Updated + Update 버튼
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Reset Time 설정 영역
          Obx(() {
            final isDevel = dashboard.isDevel;
            final hh = dashboard.resetHour.value.toString().padLeft(2, '0');
            final mm = dashboard.resetMinute.value.toString().padLeft(2, '0');

            return Row(
              children: [
                Text("Reset Time", style: T.t16(color: primaryDarker, bold: true)),
                const SizedBox(width: 8),

                // 시(hour)
                isDevel
                    ? Dropdown(
                        width: 76,
                        items: const [
                          '00',
                          '01',
                          '02',
                          '03',
                          '04',
                          '05',
                          '06',
                          '07',
                          '08',
                          '09',
                          '10',
                          '11',
                          '12',
                          '13',
                          '14',
                          '15',
                          '16',
                          '17',
                          '18',
                          '19',
                          '20',
                          '21',
                          '22',
                          '23',
                        ],
                        hintText: hh,
                        onChanged: (v) => dashboard.setResetHour(v!),
                      )
                    : _fakeDropdown(hh, 76),

                const SizedBox(width: 4),

                // 분(minute)
                isDevel
                    ? Dropdown(
                        width: 76,
                        items: const ['00', '10', '20', '30', '40', '50'],
                        hintText: mm,
                        onChanged: (v) => dashboard.setResetMinute(v!),
                      )
                    : _fakeDropdown(mm, 76),

                if (isDevel) const SizedBox(width: 8),

                // Apply 버튼 (개발자 전용)
                if (isDevel)
                  // Reset Time 적용 버튼
                  ButtonSmall(
                    text: 'Set',
                    width: 56,
                    height: 28,
                    backgroundColor: white,
                    textColor: primaryDarker,
                    borderColor: lightGray,
                    borderRadius: 8,
                    isbold: true,
                    onPressed: dashboard.updateResetTime,
                  ),
              ],
            );
          }),

          // Last Updated + Update 버튼
          Row(
            children: [
              Text("Last Updated", style: T.t16(color: primaryDarker, bold: true)),
              const SizedBox(width: 8),

              // 갱신 시간 표시
              Obx(() {
                final text = dashboard.formattedLastUpdated;

                if (text == '-') {
                  return _timeTag("--:--");
                }

                final parts = text.split('•');
                final date = parts.first.trim();
                final time = parts.last.trim();

                return Row(children: [_timeTag(date), const SizedBox(width: 4), _timeTag(time)]);
              }),

              const SizedBox(width: 8),

              // Update 버튼
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () {
                    dashboard.manualUpdate();
                    onRefresh?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white,
                    foregroundColor: primaryDarker,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: lightGray),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('Update', style: T.t12(color: primaryDarker, bold: true)),
                      const SizedBox(width: 6),
                      SvgPicture.asset('assets/icons/restart_black.svg', width: 12, height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 날짜/시간 태그
  Widget _timeTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: T.t12(color: black)),
    );
  }
}
