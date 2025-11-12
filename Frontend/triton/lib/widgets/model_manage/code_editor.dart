// 코드 에디터 본문
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/model_manage/config_controller.dart';
import '../../theme/app_colors.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final codeEditorController = Get.find<ConfigController>();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: codeEditorController.editorCtrl, // 에디터 컨트롤러 안 텍스트 컨트롤러 연결
      expands: true,
      maxLines: null,
      minLines: null,
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.top,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: primaryDarkest)),
        hintText: 'Edit config.pbtxt for current model...',
        contentPadding: EdgeInsets.all(12),
      ),
      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
    );
  }
}
