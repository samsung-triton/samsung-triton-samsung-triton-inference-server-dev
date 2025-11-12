// 모델 or 버전 등록 모달
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../controller/model_manage/model_manage_controller.dart';
import '../../controller/model_manage/version_manage_controller.dart';

import '../../theme/app_colors.dart';
import '../../theme/typography.dart';

import '../../utils/modal_util.dart';

import 'modal_base.dart';
import '../input/input_medium.dart';
import '../input/input_large.dart';
import '../button/button_medium.dart';
import '../button/button_small.dart';
import '../modellog/dropdown.dart';

import 'modal_confirmation.dart';

// 모달 등록 종류
enum RegistrationKind { model, setup }

class PickedFile {
  final String name;
  final Uint8List bytes;
  const PickedFile(this.name, this.bytes);
}

class ModalRegistration extends StatefulWidget {
  final RegistrationKind kind;

  const ModalRegistration({super.key, required this.kind});

  @override
  State<ModalRegistration> createState() => _ModalRegistrationState();
}

class _ModalRegistrationState extends State<ModalRegistration> {
  late final TextEditingController nameCtrl;
  late final TextEditingController modelFileCtrl;
  late final TextEditingController setupFileCtrl;
  late final TextEditingController descCtrl;

  PickedFile? pickedModelFile;
  PickedFile? pickedSetupFile;

  String modelType = 'single';

  String? errorText;

  bool get isModel => widget.kind == RegistrationKind.model;
  bool get isSetup => widget.kind == RegistrationKind.setup;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    modelFileCtrl = TextEditingController();
    setupFileCtrl = TextEditingController();
    descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    modelFileCtrl.dispose();
    setupFileCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // 파일 픽커
  Future<PickedFile?> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (res == null || res.files.isEmpty || res.files.single.bytes == null) return null;
    final file = res.files.single;
    return PickedFile(file.name, file.bytes!);
  }

  // 모델 파일 등록
  Future<void> _browseModelFile() async {
    final file = await _pickFile();
    if (file != null) {
      setState(() {
        pickedModelFile = file;
        modelFileCtrl.text = file.name;
      });
    }
  }

  // config 파일 등록
  Future<void> _browseSetupFile() async {
    final file = await _pickFile();
    if (file != null) {
      setState(() {
        pickedSetupFile = file;
        setupFileCtrl.text = file.name;
      });
    }
  }

  void _setError(String? msg) => setState(() => errorText = msg);

  // 검증
  bool _validate() {
    // 모델 등록 검증
    if (isModel) {
      if (nameCtrl.text.trim().isEmpty) {
        _setError('model name is required');
        return false;
      }
      if (modelType == 'single' && pickedModelFile == null) {
        _setError('model file is required');
        return false;
      }
      if (pickedSetupFile == null) {
        _setError('config file is required');
        return false;
      }
      if (descCtrl.text.trim().isEmpty) {
        _setError('description is required');
        return false;
      }
    }
    // 세팅 등록 검증
    else {
      if (descCtrl.text.trim().isEmpty) {
        _setError('description is required');
        return false;
      }
    }
    _setError(null);
    return true;
  }

  // 버튼 활성화
  bool get _canRegisterPreview {
    final hasDesc = descCtrl.text.trim().isNotEmpty;

    if (isModel) {
      final hasName = nameCtrl.text.trim().isNotEmpty;
      final hasModel = isModel ? (modelType == 'ensemble' || pickedModelFile == null) : pickedModelFile == null;
      final hasConfig = pickedSetupFile != null;
      return hasName && hasModel && hasConfig && hasDesc;
    } else {
      return hasDesc;
    }
  }

  // 등록 수행 함수
  Future<void> _performRegister() async {
    if (isModel) {
      final modelManageController = Get.find<ModelManageController>();
      // TODO: nameCtrl, modelType, pickedModelFiles, pickedConfigFile, descCtrl 연결
      await modelManageController.registerModel();
    } else {
      final versionManageController = Get.find<VersionManageController>();
      // TODO: 선택 모델, pickedModelFiles, descCtrl 연결
      await versionManageController.registerVersion();
    }
  }

  // 확인 모달로 넘어가기
  Future<void> _confirmAndRegisterSequential() async {
    if (!_validate()) return;

    // 현재(등록) 모달의 root 네비게이터 컨텍스트를 확보
    final hostCtx = Navigator.of(context, rootNavigator: true).context;

    // 1) 현재 모달 닫기
    ModalPortal.close(context);

    // 2) 다음 프레임에서 확인 모달 열기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalPortal.open(
        hostCtx,
        builder: (dialogContext) => ModalConfirmation(
          message: 'Are you sure you want to register it?',
          onOK: () async {
            await _performRegister(); // API 호출
          },
        ),
      );
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: 'registration',
      width: 428,
      borderRadius: 8,
      dividerColor: primaryDarkest,
      borderColor: Colors.transparent,
      backgroundColor: white,
      titleColor: primaryDarkest,
      contentSpacing: 8,
      children: [
        if (errorText != null) ...[
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(color: statusRed.withAlpha(16), borderRadius: BorderRadius.circular(6)),
            child: Text(errorText!, style: T.t12(color: statusRed)),
          ),
          const SizedBox(height: 8),
        ],

        // 모델 등록일 경우에만 타입과 이름 입력
        if (isModel) ...[
          _LabelInputRow(
            label: 'model type',
            child: Dropdown(
              width: 200,
              items: const ['single', 'ensemble'],
              hintText: 'Select model type',
              value: modelType,
              onChanged: (newValue) {
                setState(() {
                  modelType = newValue ?? 'single';
                });
              },
            ),
          ),
          const SizedBox(height: 4),

          _LabelInputRow(
            label: 'model name',
            child: InputMedium(controller: nameCtrl),
          ),
          const SizedBox(height: 4),
        ],

        // 모델 파일
        if ((isModel && modelType == 'single') || isSetup) ...[
          _LabelInputRow(
            label: 'model file',
            child: Row(
              children: [
                InputMedium(controller: modelFileCtrl, readOnly: true, enableInteractiveSelection: false),
                const SizedBox(width: 8),
                ButtonSmall(text: 'browse', onPressed: _browseModelFile),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],

        // config 파일
        if (isModel) ...[
          _LabelInputRow(
            label: 'setup file',
            child: Row(
              children: [
                InputMedium(controller: setupFileCtrl, readOnly: true, enableInteractiveSelection: false),
                const SizedBox(width: 8),
                ButtonSmall(text: 'browse', onPressed: _browseSetupFile),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],

        // 이유 입력
        _LabelInputRow(
          label: 'description',
          alignTop: true,
          child: InputLarge(controller: descCtrl, hintText: 'Enter the reason for your action.'),
        ),
        const SizedBox(height: 24),

        // 등록 | 취소 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([nameCtrl, descCtrl]),
              builder: (context, _) {
                final can = _canRegisterPreview;
                return ButtonMedium(
                  text: 'register',
                  onPressed: can ? _confirmAndRegisterSequential : null,
                  backgroundColor: can ? primaryNormal : gray.withAlpha(128),
                  textColor: white,
                );
              },
            ),
            const SizedBox(width: 16),
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

// 공통 라벨 + 인풋 행
class _LabelInputRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool alignTop;

  const _LabelInputRow({required this.label, required this.child, this.alignTop = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽 라벨 영역
          SizedBox(
            width: 88,
            height: alignTop ? null : 32,
            child: Padding(
              padding: EdgeInsets.only(top: alignTop ? 6 : 0),
              child: Align(
                alignment: alignTop ? Alignment.topCenter : Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: T.t12(color: darkGray),
                ),
              ),
            ),
          ),

          // 세로 구분선 (회색 실선)
          Container(width: 1, height: alignTop ? 60 : 28, color: lightGray),

          const SizedBox(width: 8),

          child,
        ],
      ),
    );
  }
}
