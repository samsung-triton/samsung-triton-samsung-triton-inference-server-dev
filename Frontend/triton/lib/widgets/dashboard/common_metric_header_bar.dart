import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:triton/controller/dashboard/dashboard_controller.dart' as dash;
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/modellog/dropdown.dart';

class CommonMetricHeaderBar extends StatelessWidget {
  const CommonMetricHeaderBar({super.key});

  // 🔹 일반 계정용 Fake Dropdown (모양만, 클릭 불가)
  Widget _fakeDropdown(String text, double width) {
    return Container(
      width: width,
      height: 28,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: white,
        border: Border.all(color: lightGray, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: T.t12(color: gray, bold: false)),
    );
  }

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
          /// ------------------------------------------
          /// 🔹 왼쪽 영역 (Reset Time)
          /// ------------------------------------------
          Obx(() {
            final isDevel = dashboardController.isDevel;
            final hourText = dashboardController.resetHour.value.toString().padLeft(2, '0');
            final minuteText = dashboardController.resetMinute.value.toString().padLeft(2, '0');

            return Row(
              children: [
                Text("Reset Time", style: T.t16(color: primaryDarker, bold: true)),
                const SizedBox(width: 8),

                /// 🔹 Hour Dropdown
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
                        hintText: hourText,
                        onChanged: (value) {
                          dashboardController.setResetHour(value!);
                        },
                      )
                    : _fakeDropdown(hourText, 76),

                const SizedBox(width: 4),

                /// 🔹 Minute Dropdown
                isDevel
                    ? Dropdown(
                        width: 76,
                        items: const ['00', '10', '20', '30', '40', '50'],
                        hintText: minuteText,
                        onChanged: (value) {
                          dashboardController.setResetMinute(value!);
                        },
                      )
                    : _fakeDropdown(minuteText, 76),

                /// 🔹 Apply 버튼 (DEVEL만 표시)
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

          /// ------------------------------------------
          /// 🔹 오른쪽 영역 (Last Updated + Update 버튼)
          /// ------------------------------------------
          Row(
            children: [
              Text("Last Updated", style: T.t16(color: primaryDarker, bold: true)),
              const SizedBox(width: 8),

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
