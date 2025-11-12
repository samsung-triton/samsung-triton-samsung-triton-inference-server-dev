// 확인 모달
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../../utils/modal_util.dart';

import 'modal_base.dart';
import '../button/button_medium.dart';

class ModalConfirmation extends StatefulWidget {
  final String message;
  final Future<void> Function()? onOK;

  const ModalConfirmation({super.key, required this.message, this.onOK});

  @override
  State<ModalConfirmation> createState() => _ModalConfirmationState();
}

class _ModalConfirmationState extends State<ModalConfirmation> {
  bool _loading = false;
  String? _error;

  Future<void> _handleOk() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 받아온 OK 기능 API 호출 대기
      if (widget.onOK != null) {
        await widget.onOK!();
      }
      if (mounted) {
        ModalPortal.close(context, true);
      }
    } catch (e) {
      // 실패 메시지 노출
      setState(() {
        _error = 'request failed. please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: 'confirmation',
      backgroundColor: primaryDarkest,
      titleColor: white,
      dividerColor: white,
      children: [
        // 에러 배너
        if (_error != null) ...[
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(color: statusRed.withAlpha(28), borderRadius: BorderRadius.circular(6)),
            child: Text(_error!, style: T.t12(color: white)),
          ),
          const SizedBox(height: 8),
        ],

        // 본문 문구
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            widget.message,
            style: T.t16(color: white),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 하단 버튼 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonMedium(
              text: _loading ? 'processing...' : 'ok',
              onPressed: _loading ? null : _handleOk, // 로딩 중 비활성화
              backgroundColor: white,
              textColor: black,
            ),
            const SizedBox(width: 12),
            ButtonMedium(
              text: 'cancel',
              onPressed: _loading ? null : () => ModalPortal.close(context),
              backgroundColor: gray,
              textColor: white,
            ),
          ],
        ),
      ],
    );
  }
}
