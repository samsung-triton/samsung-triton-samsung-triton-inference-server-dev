import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import '../button/button_medium.dart';
import 'modal_base.dart';

class ModalConfirmation extends StatelessWidget {
  final String message;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;

  const ModalConfirmation({Key? key, required this.message, this.onDelete, this.onCancel, this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: 'confirmation',
      backgroundColor: primaryDarkest,
      titleColor: white,
      dividerColor: white,
      onClose: onClose,
      children: [
        // ───── 본문 문구 ─────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            message,
            style: T.t16(color: white),
            textAlign: TextAlign.center,
            maxLines: 2, // ✅ 최대 2줄
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // ───── 하단 버튼 영역 ─────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonMedium(text: 'delete', onPressed: onDelete, backgroundColor: white, textColor: black),
            const SizedBox(width: 12),

            ButtonMedium(
              text: 'cancel',
              onPressed: onCancel ?? () => Navigator.of(context, rootNavigator: true).pop(),
              backgroundColor: gray,
              textColor: white,
            ),
          ],
        ),
      ],
    );
  }
}
