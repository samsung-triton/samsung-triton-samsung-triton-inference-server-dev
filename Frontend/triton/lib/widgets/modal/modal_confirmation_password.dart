import 'package:flutter/material.dart';
import 'package:triton/widgets/input/input_medium.dart';
import 'package:get/get.dart';

import '../../controller/server/server_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../../utils/modal_util.dart';

import 'modal_base.dart';
import '../button/button_medium.dart';

import '../../widgets/modal/modal_description.dart';

// 모달 종류
enum ControlKind { stop, restart }

class ModalConfirmationPassword extends StatefulWidget {
  final ControlKind kind;

  const ModalConfirmationPassword({super.key, required this.kind});

  @override
  State<ModalConfirmationPassword> createState() => _ModalConfirmationPasswordState();
}

class _ModalConfirmationPasswordState extends State<ModalConfirmationPassword> {
  late final TextEditingController masterKeyCtrl;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    masterKeyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    masterKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleOk() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (masterKeyCtrl.text.trim().isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please enter password.';
      });
      return;
    }

    final serverController = Get.find<ServerController>();

    try {
      final ok = await serverController.verifyMasterKey(masterKeyCtrl.text);
      if (!ok) {
        setState(() {
          _error = 'Password incorrect. Please try again or reset it.';
        });
        return;
      }

      if (mounted) {
        final hostCtx = Navigator.of(context, rootNavigator: true).context;

        ModalPortal.close(context, true);

        // 다음 프레임에 설명 모달 열기
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final descCtrl = TextEditingController();

          ModalPortal.open(
            hostCtx,
            builder: (dialogCtx) => ModalDescription(
              descCtrl: descCtrl,
              isServer: true,
              onOK: () async {
                final serverController = Get.find<ServerController>();
                // TODO: 추후 descCtrl 글자 추가
                if (widget.kind == ControlKind.stop) {
                  await serverController.stopServer();
                }
                if (widget.kind == ControlKind.restart) {
                  await serverController.restartServer();
                }
              },
            ),
          );
        });
      }
    } catch (e) {
      // 실패 메시지 노출
      setState(() {
        _error = 'Request failed. please try again.';
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
            child: Text(_error!, style: T.t12(color: statusRed)),
          ),
        ],

        // 본문 문구
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'To stop or restart the server,\nplease enter your password.',
            style: T.t16(color: white),
            textAlign: TextAlign.center,
            maxLines: 2, // 최대 2줄
          ),
        ),

        Center(
          child: SizedBox(
            width: 200,
            child: InputMedium(hintText: "Enter password", obscureText: true, controller: masterKeyCtrl),
          ), // [ADDED]
        ),

        const SizedBox(height: 20),

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
