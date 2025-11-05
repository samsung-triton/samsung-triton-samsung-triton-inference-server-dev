import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import '../input/input_large.dart';
import '../button/button_medium.dart';
import 'modal_base.dart';

class ModalDescription extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onOk;
  final VoidCallback? onSkip;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;

  const ModalDescription({Key? key, required this.controller, this.onOk, this.onSkip, this.onCancel, this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: 'description',
      onClose: onClose,
      children: [
        // ───── 안내 문구 영역 ─────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Please write a description of your actions.\n'
            'You can always check it on the Server Log page.',
            style: T.t16(color: darkGray),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 8),

        // ───── 입력창 영역 ─────
        InputLarge(hintText: 'Enter reason or notes for adding this model.', controller: controller),

        const SizedBox(height: 24),

        // ───── 하단 버튼 영역 ─────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonMedium(text: 'ok', onPressed: onOk, backgroundColor: primaryNormal, textColor: white),
            const SizedBox(width: 12),

            ButtonMedium(text: 'skip', onPressed: onSkip, backgroundColor: lightGray, textColor: darkGray),
            const SizedBox(width: 12),

            ButtonMedium(
              text: 'cancel',
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              backgroundColor: lightGray,
              textColor: darkGray,
            ),
          ],
        ),
      ],
    );
  }
}
