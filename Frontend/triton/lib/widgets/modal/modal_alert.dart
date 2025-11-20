import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:triton/utils/show_alert.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/button/button_large.dart';

class ModalAlert extends StatelessWidget {
  const ModalAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!ShowAlert.isVisible.value) {
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.black.withAlpha(64),
        alignment: Alignment.center,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목
                  Text(
                    ShowAlert.title.value,
                    style: T.t20(bold: true, color: darkGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // 내용
                  Text(
                    ShowAlert.message.value,
                    style: T.t16(color: darkGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 확인 버튼
                  ButtonLarge(text: 'OK', onPressed: () => ShowAlert.hide()),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
