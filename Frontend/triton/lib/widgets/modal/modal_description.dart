// 이유 작성 모달
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../../utils/modal_util.dart';
import '../input/input_large.dart';
import '../button/button_medium.dart';
import 'modal_base.dart';
import 'modal_confirmation.dart';

class ModalDescription extends StatefulWidget {
  final TextEditingController descCtrl;
  final Future<void> Function()? onOK;
  final bool isServer;
  final String? confirmMsg;

  const ModalDescription({super.key, required this.descCtrl, this.onOK, this.isServer = false, this.confirmMsg});

  @override
  State<ModalDescription> createState() => _ModalDescriptionState();
}

class _ModalDescriptionState extends State<ModalDescription> {
  String? _error;
  bool _canSubmit = false;

  void _onDescChanged() {
    final next = widget.descCtrl.text.trim().isNotEmpty;
    if (next != _canSubmit) {
      setState(() => _canSubmit = next);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.descCtrl.addListener(_onDescChanged);
  }

  @override
  void dispose() {
    widget.descCtrl.removeListener(_onDescChanged);
    super.dispose();
  }

  // OK 동작
  Future<void> _handleOk(BuildContext context) async {
    // 0) 입력 검증
    if (widget.descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'description is required');
      return;
    }
    setState(() => _error = null);

    // 분기1) 서버: 즉시 실행 후 현재 모달 닫기
    if (widget.isServer) {
      if (widget.onOK != null) {
        await widget.onOK!();
      }
      ModalPortal.close(context, true);
      return;
    }

    // 분기2) 서버아님: 확인 모달로 전환
    final hostCtx = Navigator.of(context, rootNavigator: true).context;

    // 현재 모달 닫기
    ModalPortal.close(context);

    // 다음 프레임에 확인 모달 열기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalPortal.open(
        hostCtx,
        builder: (dialogCtx) => ModalConfirmation(
          message: widget.confirmMsg ?? 'Proceed with this action?',
          onOK: () async {
            await widget.onOK!();
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 서버/일반 문구 분기
    final String title = widget.isServer ? 'Description' : 'description';
    final String message = widget.isServer
        ? 'Restarting(stopping) the server may interrupt\n'
              'ongoing inferences. Please ensure all tasks are\n'
              'completed before proceeding.\nDo you want to continue?'
        : 'Please write a description of your actions.\n'
              'You can always check it on the Server Log page.';
    final String hint = widget.isServer
        ? 'Enter reason or notes for restarting(stopping) this model.'
        : 'Enter the reason for your action.';

    return ModalBase(
      title: title,
      children: [
        // 에러 배너
        if (_error != null) ...[
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(color: statusRed.withAlpha(24), borderRadius: BorderRadius.circular(6)),
            child: Text(_error!, style: T.t12(color: statusRed)),
          ),
          const SizedBox(height: 8),
        ],

        // 안내 문구
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            message,
            style: T.t16(color: darkGray),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 8),

        // 입력창
        InputLarge(hintText: hint, controller: widget.descCtrl),

        const SizedBox(height: 24),

        // 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonMedium(
              text: 'ok',
              onPressed: _canSubmit ? () => _handleOk(context) : null,
              backgroundColor: _canSubmit ? primaryNormal : gray.withAlpha(128),
              textColor: white,
            ),
            const SizedBox(width: 12),
            ButtonMedium(
              text: 'cancel',
              onPressed: () => ModalPortal.close(context),
              backgroundColor: lightGray,
              textColor: darkGray,
            ),
          ],
        ),
      ],
    );
  }
}
