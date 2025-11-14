// 모델 목록 관리 컨트롤러
import 'package:get/get.dart';
import 'package:triton/controller/model_manage/config_controller.dart';
import 'package:triton/controller/model_manage/version_manage_controller.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';

class ModelItem {
  final int modelId;
  final String name;
  final String type;
  final bool status;
  final int? lastLoadedVersion;
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

  // 공통 API 클라이언트 사용
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();

    _api = Get.find<ApiClient>();
  }

  // 모델 목록 로드
  Future<void> loadModels() async {
    // API 호출
    final dynamic data = await _api.getModelList();

    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      final context = Get.context;
      showAlert(context!, message: "Failed to load the model list.\nPlease retry or restart the server.");
      return;
    }

    // models 추출
    final List<dynamic> rawModels = (data['models'] as List?) ?? [];

    // rawModel을 ModelItem 변환
    final List<ModelItem> fetchedModels = rawModels.map((rawModel) {
      return ModelItem(
        modelId: rawModel['modelId'] as int,
        name: rawModel['name'] as String,
        type: rawModel['type'] as String,
        status: rawModel['status'] as bool,
        lastLoadedVersion: rawModel['lastLoadedVersion'] as int?,
        totalVersions: rawModel['totalVersions'] as int,
      );
    }).toList();

    // List에 반영
    models.assignAll(fetchedModels);

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

    final dynamic data = await _api.getModelVersionsAndConfig(modelId: modelId);
    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      final context = Get.context;
      showAlert(context!, message: "Failed to load the model data.\nPlease retry or restart the server.");
      return;
    }

    // versions 추출
    final List<dynamic> rawVersions = (data['versions'] as List?) ?? [];

    // rawVersion을 VersionItem 변환
    final List<VersionItem> fetchedVersions = rawVersions.map((rawVersion) {
      return VersionItem(
        versionId: rawVersion['versionId'] as int,
        version: rawVersion['version'] as int,
        fileName: rawVersion['fileName'] as String,
        userName: rawVersion['userName'] as String,
        createdAt: rawVersion['createdAt'] as String,
      );
    }).toList();

    // 버전 채워 넣기
    final versionManageController = Get.find<VersionManageController>();
    versionManageController.setVersions(fetchedVersions);

    // 컨피그 내용 넣기
    final codeEditorController = Get.find<ConfigController>();
    codeEditorController.setEditorCtrlText(text: data['config']["content"] as String);
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
      lastLoadedVersion: null,
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
}
