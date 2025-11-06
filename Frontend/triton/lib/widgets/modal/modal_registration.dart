import 'package:flutter/material.dart';
import 'package:triton/widgets/input/input_type.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import '../input/input_small.dart';
import '../input/input_medium.dart';
import '../input/input_large.dart';
import '../button/button_medium.dart';
import '../button/button_small.dart';
import 'modal_base.dart';
import '../modellog/dropdown.dart';

class ModalRegistration extends StatefulWidget {
  final String modelType;
  final TextEditingController versionController;
  final TextEditingController modelNameController;
  final TextEditingController modelFileController;
  final TextEditingController configFileController;
  final TextEditingController descriptionController;
  final VoidCallback? onRegister;
  final VoidCallback? onCancel;
  final VoidCallback? onBrowseModel;
  final VoidCallback? onBrowseConfig;
  final VoidCallback? onClose;

  const ModalRegistration({
    Key? key,
    required this.modelType,
    required this.versionController,
    required this.modelNameController,
    required this.modelFileController,
    required this.configFileController,
    required this.descriptionController,
    this.onRegister,
    this.onCancel,
    this.onBrowseModel,
    this.onBrowseConfig,
    this.onClose,
  }) : super(key: key);

  @override
  State<ModalRegistration> createState() => _ModalRegistrationState();
}

class _ModalRegistrationState extends State<ModalRegistration> {
  late String selectedModelType;

  @override
  void initState() {
    super.initState();
    selectedModelType = widget.modelType;
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: 'registration',
      onClose: widget.onClose,
      width: 428,
      borderRadius: 8,
      dividerColor: primaryDarker,
      borderColor: lightGray,
      backgroundColor: white,
      titleColor: primaryDarker,
      contentSpacing: 8,
      children: [
        // ───── model type (임시 InputSmall) ─────
        _LabelInputRow(
          label: 'model type',
          child: Dropdown(
            width: 200,
            items: const ['single', 'ensemble'], // 선택 가능한 타입 목록
            hintText: 'Select model type',
            value: selectedModelType, // 현재 선택된 값
            onChanged: (newValue) {
              setState(() {
                selectedModelType = newValue ?? 'single'; // 변경값 반영
              });
            },
          ),
        ),

        const SizedBox(height: 4),

        // ───── model name ─────
        _LabelInputRow(
          label: 'model name',
          child: InputMedium(controller: widget.modelNameController),
        ),

        const SizedBox(height: 4),

        // ───── model file (single일 때만 표시) ─────
        if (selectedModelType == 'single') ...[
          _LabelInputRow(
            label: 'model file',
            child: Row(
              children: [
                InputMedium(
                  controller: widget.modelFileController,
                  readOnly: true, // 🔹 입력 불가
                  enableInteractiveSelection: false,
                ),
                const SizedBox(width: 8),
                ButtonSmall(text: 'browse', onPressed: widget.onBrowseModel),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],

        // ───── config file ─────
        _LabelInputRow(
          label: 'config file',
          child: Row(
            children: [
              InputMedium(
                controller: widget.configFileController,
                readOnly: true, // 🔹 입력 불가
                enableInteractiveSelection: false,
              ),
              const SizedBox(width: 8),
              ButtonSmall(text: 'browse', onPressed: widget.onBrowseConfig),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ───── description ─────
        _LabelInputRow(
          label: 'description',
          alignTop: true,
          child: InputLarge(
            controller: widget.descriptionController,
            hintText: 'Enter reason or notes for adding this model.',
          ),
        ),

        const SizedBox(height: 24),

        // ───── 하단 버튼 영역 ─────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonMedium(
              text: 'register',
              onPressed: widget.onRegister,
              backgroundColor: primaryNormal,
              textColor: white,
              width: 80,
              height: 32,
            ),
            const SizedBox(width: 16),
            ButtonMedium(
              text: 'cancel',
              onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
              backgroundColor: lightGray,
              textColor: darkGray,
              width: 80,
              height: 32,
            ),
          ],
        ),
      ],
    );
  }
}

/// ─────────────────────────────
/// 공통 라벨 + 인풋 행
/// ─────────────────────────────
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
          // 🔹 왼쪽 라벨 영역
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

          // 🔹 세로 구분선 (회색 실선)
          Container(width: 1, height: alignTop ? 60 : 28, color: lightGray),

          const SizedBox(width: 8),

          // 🔹 인풋 필드 영역
          child,
        ],
      ),
    );
  }
}
