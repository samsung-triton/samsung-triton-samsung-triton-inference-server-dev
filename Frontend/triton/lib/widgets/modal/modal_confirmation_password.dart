// 서버 마스터키 입력 모달
import 'package:flutter/material.dart';
import 'package:triton/controller/server/server_controller.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/utils/modal_util.dart';
import 'package:triton/widgets/button/button_medium.dart';
import 'package:triton/widgets/input/input_medium.dart';
import 'package:get/get.dart';
import 'package:triton/widgets/modal/modal_base.dart';
import 'package:triton/widgets/modal/modal_description.dart';

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
      // 서버 마스터키 확인 기능 호출
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

        // 설명 모달 열기
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final descCtrl = TextEditingController();

          ModalPortal.open(
            hostCtx,
            builder: (dialogCtx) => ModalDescription(
              descCtrl: descCtrl,
              isServer: true,
              onOK: () async {
                final serverController = Get.find<ServerController>();
                if (widget.kind == ControlKind.stop) {
                  // 트리톤 서버 정지 기능 호출
                  await serverController.stopServer(descCtrl.text);
                }
                if (widget.kind == ControlKind.restart) {
                  // 트리톤 서버 재시작 기능 호출
                  await serverController.restartServer(descCtrl.text);
                }
              },
            ),
          );
        });
      }
    } catch (e) {
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
        // 본문 문구
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'To stop or restart the server,\nplease enter your password.',
            style: T.t16(color: white),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),

        // 에러 문구
        if (_error != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(color: statusRed.withAlpha(28), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  _error!,
                  style: T.t12(color: statusRed),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],

        // 패스워드 입력칸
        Center(
          child: SizedBox(
            width: 200,
            child: InputMedium(hintText: "Enter password", obscureText: true, controller: masterKeyCtrl),
          ),
        ),

        const SizedBox(height: 20),

        // 하단 버튼 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 확인 버튼
            ButtonMedium(
              text: 'ok',
              // 로딩 중 비활성화
              onPressed: _loading ? null : _handleOk,
              backgroundColor: _loading ? lightGray : white,
              textColor: black,
            ),
            const SizedBox(width: 12),
            // 취소 버튼
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
