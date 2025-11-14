// 알람 모달
import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/button/button_large.dart';

Future<void> showAlert(BuildContext context, {String title = 'Notification', required String message}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목
                Text(
                  title,
                  style: T.t20(bold: true, color: darkGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 내용
                Text(
                  message,
                  style: T.t16(color: darkGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 확인 버튼
                ButtonLarge(text: "OK", onPressed: () => Navigator.of(ctx).pop()),
              ],
            ),
          ),
        ),
      );
    },
  );
}
