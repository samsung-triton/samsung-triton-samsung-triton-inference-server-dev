import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart' as dash;
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/dropdown.dart';

class CommonMetricHeaderBar extends StatelessWidget {
  const CommonMetricHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<dash.DashboardController>();

    return Container(
      width: double.infinity,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: black, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// ✅ 왼쪽: Reset Time 영역 (role + resetTime 반영)
          Obx(() {
            final isDevel = dashboardController.isDevel;
            final hourText = dashboardController.resetHour.value.toString().padLeft(2, '0');
            final minuteText = dashboardController.resetMinute.value.toString().padLeft(2, '0');

            return Row(
              children: [
                Text("Reset Time", style: T.t16(color: primaryDarker, bold: true)),
                const SizedBox(width: 8),

                // 🔹 Hour Dropdown
                IgnorePointer(
                  ignoring: !isDevel, // DEVEL만 선택 가능
                  child: Opacity(
                    opacity: isDevel ? 1.0 : 0.6,
                    child: Dropdown(
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
                      // 서버에서 받은 기준 시간을 hint로 표시
                      hintText: hourText,
                      onChanged: (value) {
                        if (value == null) return;
                        dashboardController.setResetHour(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // 🔹 Minute Dropdown
                IgnorePointer(
                  ignoring: !isDevel,
                  child: Opacity(
                    opacity: isDevel ? 1.0 : 0.6,
                    child: Dropdown(
                      width: 76,
                      items: const ['00', '10', '20', '30', '40', '50'],
                      hintText: minuteText,
                      onChanged: (value) {
                        if (value == null) return;
                        dashboardController.setResetMinute(value);
                      },
                    ),
                  ),
                ),

                // 🔹 DEVEL만 Reset 버튼 노출
                if (isDevel) const SizedBox(width: 8),
                if (isDevel)
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => dashboardController.updateResetTime(),
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
                      child: Text('Apply', style: T.t12(color: primaryDarker, bold: true)),
                    ),
                  ),
              ],
            );
          }),

          /// ✅ 오른쪽: Last Updated + Update 버튼
          Row(
            children: [
              Text("Last Updated", style: T.t16(color: primaryDarker, bold: true)),
              const SizedBox(width: 8),

              // 날짜 + 시간 표시 (Obx로 갱신)
              Obx(() {
                final text = dashboardController.formattedLastUpdated;
                if (text == '-') {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
                    child: Text("--:--", style: T.t12(color: black)),
                  );
                }

                final parts = text.split('•');
                final date = parts.first.trim();
                final time = parts.length > 1 ? parts.last.trim() : '';

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
                      child: Text(date, style: T.t12(color: black)),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
                      child: Text(time, style: T.t12(color: black)),
                    ),
                  ],
                );
              }),
              const SizedBox(width: 8),

              // ✅ Update 버튼
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () => dashboardController.manualUpdate(),
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
                    mainAxisSize: MainAxisSize.min,
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
}
