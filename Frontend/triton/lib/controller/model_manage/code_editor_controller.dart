// 컨피그 코드 수정 컨트롤러
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CodeEditorController extends GetxController {
  // 현재 모델 아이디
  final currentModelId = RxnInt();

  // 에디터 텍스트 컨트롤러
  final textCtrl = TextEditingController();

  // 마지막 저장 스냅샷(임시용)
  String _lastSavedText = '';

  // 모델이 바뀔 때 호출
  Future<void> loadConfig({required int modelId}) async {
    currentModelId.value = modelId;

    // TODO: 모델별 config 내용 로드 API로 교체
    final content = _dummyContent(modelId);

    textCtrl.text = content;
    _lastSavedText = content;
  }

  // 롤백 (현재는 임시로 마지막 저장 시점으로 복원)
  void rollback() {
    // TODO: 롤백 API 연동
    textCtrl.text = _lastSavedText;
  }

  // 저장
  Future<void> save() async {
    final mid = currentModelId.value;
    if (mid == null) return;

    final content = textCtrl.text;
    // TODO: 저장 API 연동 (modelId 기준으로 저장)
    // await api.saveConfig(modelId: mid, content: content);
    _lastSavedText = content;
  }

  String _dummyContent(int modelId) {
    return '''
# config.pbtxt (model: $modelId)
platform: "onnxruntime_onnx"
max_batch_size: 8

optimization { execution_accelerators {
  gpu_execution_accelerator: [ { name: "tensorrt" } ]
}}

dynamic_batching {
  preferred_batch_size: [4, 8, 16]
  max_queue_delay_microseconds: 2000
}
''';
  }

  @override
  void onClose() {
    textCtrl.dispose();
    super.onClose();
  }
}
