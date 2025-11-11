// 모델 목록 관리 컨트롤러
import 'package:get/get.dart';
import 'version_manage_controller.dart';
import 'config_controller.dart';

class ModelItem {
  final int modelId;
  final String name;
  final String type;
  final bool status;
  final String lastLoadedVersion;
  final int totalVersions;

  const ModelItem({
    required this.modelId,
    required this.name,
    required this.type,
    required this.status,
    required this.lastLoadedVersion,
    required this.totalVersions,
  });
}

class ModelManageController extends GetxController {
  ///전체 모델 목록
  final models = <ModelItem>[].obs;

  // 선택 모델 관리
  final selectedModelId = RxnInt();
  final selectedModelName = ''.obs;

  // 최초 로드
  Future<void> loadModels() async {
    // TODO: 모델 목록 API 연동
    // final result = await api.fetchModelList();
    // models.assignAll(result);

    // 임시 더미 15개
    final tmp = <ModelItem>[];
    for (int i = 1; i <= 15; i++) {
      tmp.add(
        ModelItem(
          modelId: i,
          name: i == 1 ? 'yolov8-detector' : 'model-$i',
          type: "NORMAL",
          status: i % 2 == 0,
          lastLoadedVersion: i % 3 == 0
              ? '2025-10-${(i % 30 + 1).toString().padLeft(2, '0')} ${((8 + i) % 24).toString().padLeft(2, '0')}:12'
              : 'N/A',
          totalVersions: (i % 5) + 1,
        ),
      );
    }
    models.assignAll(tmp);

    // 첫 번째 모델 자동 선택
    if (models.isNotEmpty) {
      await selectModel(models.first.modelId);
    }
  }

  // 모델 선택
  Future<void> selectModel(int modelId) async {
    if (selectedModelId.value == modelId) return;
    selectedModelId.value = modelId;

    final model = models.firstWhereOrNull((e) => e.modelId == modelId);
    selectedModelName.value = model?.name ?? '';

    // TODO: api 호출해서 넣기
    final dummyVersions = _makeDummyVersionsFor(modelId, selectedModelName.value);
    final dummyConfig = _makeDummyConfigFor(modelId, selectedModelName.value);

    // 버전 목록 넣기
    final versionManageController = Get.find<VersionManageController>();
    versionManageController.setVersions(dummyVersions);

    // 컨피그 내용 넣기
    final codeEditorController = Get.find<ConfigController>();
    codeEditorController.setEditorCtrlText(text: dummyConfig); // NEW (기존 "test" → 더미 생성값)
  }

  // 모델 등록
  Future<void> registerModel({String? name}) async {
    // TODO: 등록 API 연동 (성공 시 목록/선택 업데이트)
    final newId = (models.isEmpty ? 1 : models.map((e) => e.modelId).reduce((a, b) => a > b ? a : b) + 1);
    final item = ModelItem(
      modelId: newId,
      name: (name?.trim().isNotEmpty ?? false) ? name!.trim() : 'new-model-$newId',
      type: "NORMAL",
      status: false,
      lastLoadedVersion: 'N/A',
      totalVersions: 1,
    );
    models.insert(0, item);
  }

  // 모델 삭제
  Future<void> deleteModel(int modelId) async {
    // TODO: 삭제 API 연동 (성공 시 목록/선택 업데이트)
    models.removeWhere((e) => e.modelId == modelId);

    // 현재 선택된 모델일 경우
    if (selectedModelId.value == modelId) {
      if (models.isNotEmpty) {
        await selectModel(models.first.modelId);
      } else {
        selectedModelId.value = null;
        selectedModelName.value = '';
        // 버전 컨트롤러 초기화
        final versions = Get.find<VersionManageController>();
        versions.reset();
      }
    }
  }

  // TODO: 더미 추후 삭제
  List<VersionItem> _makeDummyVersionsFor(int modelId, String modelName) {
    final count = 3 + (modelId % 4);
    final list = <VersionItem>[];
    for (int i = 0; i < count; i++) {
      final ver = count - i;
      list.add(
        VersionItem(
          versionId: modelId * ver,
          version: ver,
          fileName: (modelId % 2 == 0) ? '${modelName}_v$ver.engine' : '${modelName}_v$ver.onnx',
          userName: (ver % 2 == 0) ? 'admin' : 'builder',
          createdAt: '2025-10-${(10 + ver).toString().padLeft(2, '0')}',
        ),
      );
    }
    return list; // NEW
  }

  // 모델별 더미 config 생성기
  String _makeDummyConfigFor(int modelId, String modelName) {
    final platform = (modelId % 2 == 0) ? 'tensorrt_plan' : 'onnxruntime_onnx';
    final maxBatch = 4 + (modelId % 5) * 4;
    return '''
# config.pbtxt (model: $modelId / name: $modelName)
platform: "$platform"
max_batch_size: $maxBatch

optimization {
  execution_accelerators {
    gpu_execution_accelerator: [ { name: "tensorrt" } ]
  }
}

dynamic_batching {
  preferred_batch_size: [4, 8, 16]
  max_queue_delay_microseconds: ${1000 + (modelId % 5) * 500}
}
''';
  }
}
