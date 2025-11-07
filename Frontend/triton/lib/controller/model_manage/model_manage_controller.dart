// 모델 목록 관리 컨트롤러
import 'package:get/get.dart';
import 'version_manage_controller.dart';
import 'code_editor_controller.dart';

class ModelItem {
  final int id;
  final String name;
  final String lastLoaded;
  final bool isLoaded;
  final int versionsCount;

  const ModelItem({
    required this.id,
    required this.name,
    required this.lastLoaded,
    required this.isLoaded,
    required this.versionsCount,
  });
}

class ModelManageController extends GetxController {
  ///전체 모델 목록
  final models = <ModelItem>[].obs;

  // 선택 모델 관리
  final selectedId = RxnInt();
  final selectedName = ''.obs;

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
          id: i,
          name: i == 1 ? 'yolov8-detector' : 'model-$i',
          lastLoaded: i % 3 == 0
              ? '2025-10-${(i % 30 + 1).toString().padLeft(2, '0')} ${((8 + i) % 24).toString().padLeft(2, '0')}:12'
              : 'N/A',
          isLoaded: i % 2 == 0,
          versionsCount: (i % 5) + 1,
        ),
      );
    }
    models.assignAll(tmp);

    // 첫 번째 모델 자동 선택
    if (models.isNotEmpty) {
      await selectModel(models.first.id);
    }
  }

  // 모델 선택
  Future<void> selectModel(int id) async {
    if (selectedId.value == id) return;
    selectedId.value = id;

    final model = models.firstWhereOrNull((e) => e.id == id);
    selectedName.value = model?.name ?? '';

    // 버전 컨트롤러에게 로드 지시
    final versionManageController = Get.find<VersionManageController>();
    await versionManageController.loadVersions(modelId: id, modelName: selectedName.value);

    // 컨피그 컨트롤러에게 로드 지시
    final codeEditorController = Get.find<CodeEditorController>();
    await codeEditorController.loadConfig(modelId: id);
  }

  // 모델 등록
  Future<void> registerModel({String? name}) async {
    // TODO: 등록 API 연동 (성공 시 목록/선택 업데이트)
    final newId = (models.isEmpty ? 1 : models.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final item = ModelItem(
      id: newId,
      name: (name?.trim().isNotEmpty ?? false) ? name!.trim() : 'new-model-$newId',
      lastLoaded: 'N/A',
      isLoaded: false,
      versionsCount: 1,
    );
    models.insert(0, item);
  }

  // 모델 삭제
  Future<void> deleteModel(int id) async {
    // TODO: 삭제 API 연동 (성공 시 목록/선택 업데이트)
    models.removeWhere((e) => e.id == id);

    // 현재 선택된 모델일 경우
    if (selectedId.value == id) {
      if (models.isNotEmpty) {
        await selectModel(models.first.id);
      } else {
        selectedId.value = null;
        selectedName.value = '';
        // 버전 컨트롤러 초기화
        final versions = Get.find<VersionManageController>();
        versions.reset();
      }
    }
  }
}
