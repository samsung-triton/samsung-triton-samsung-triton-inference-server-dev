// 모달 열고 닫는 유틸 파일
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ModalPortal {
  // 열기
  static Future<void> open(BuildContext context, {required Widget Function(BuildContext context) builder}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      barrierColor: black.withAlpha(128),
      // 모달 내용 넣기
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: builder(dialogContext),
        );
      },
    );
  }

  // 닫기
  static void close(BuildContext dialogContext, [Object? result]) {
    Navigator.of(dialogContext, rootNavigator: true).pop(result);
  }
}
