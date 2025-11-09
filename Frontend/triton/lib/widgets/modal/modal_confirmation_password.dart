import 'package:flutter/material.dart';
import 'package:triton/widgets/input/input_medium.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import '../button/button_medium.dart';
import 'modal_base.dart';

class ModalConfirmationPassword extends StatelessWidget {
  final String message;
  final VoidCallback? onOk;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;

  const ModalConfirmationPassword({
    super.key, // Key를 바로 부모(StatelessWidget)로 전달
    required this.message,
    this.onOk,
    this.onCancel,
    this.onClose,
  });

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
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            message,
            style: T.t16(color: white),
            textAlign: TextAlign.center,
            maxLines: 2, // ✅ 최대 2줄
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Center(
          child: SizedBox(width: 200, child: InputMedium(hintText: "Enter password", obscureText: true)),
        ),

        const SizedBox(height: 20),

        // ───── 하단 버튼 영역 ─────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonMedium(text: 'OK', onPressed: onOk, backgroundColor: white, textColor: black),
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
