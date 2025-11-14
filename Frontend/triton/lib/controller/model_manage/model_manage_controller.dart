// 모델 목록 관리 컨트롤러
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/controller/model_manage/config_controller.dart';
import 'package:triton/controller/model_manage/version_manage_controller.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';

class ModelItem {
  final int modelId;
  final String name;
  final String type;
  final bool status;
  final dynamic lastLoadedVersion;
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

  // 게정 정보 확인을 위한 저장소 사용
  GetStorage get _authStorage => GetStorage('auth');

  bool _isFirstLoad = true;

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
        lastLoadedVersion: rawModel['lastLoadedVersion'] as dynamic,
        totalVersions: rawModel['totalVersions'] as int,
      );
    }).toList();

    // List에 반영
    models.assignAll(fetchedModels);

    // 첫 로드일 때만 첫 번째 모델 자동 선택
    if (_isFirstLoad && models.isNotEmpty) {
      _isFirstLoad = false;
      await selectModel(models.first.modelId);
    }
  }

  // 모델 선택
  Future<void> selectModel(int modelId) async {
    if (selectedModelId.value == modelId) return;
    selectedModelId.value = modelId;

    final model = models.firstWhereOrNull((e) => e.modelId == modelId);
    selectedModelName.value = model?.name ?? '';

    await loadModelInfo();
  }

  Future<void> loadModelInfo() async {
    final context = Get.context;

    final modelId = selectedModelId.value;
    if (modelId == null) {
      if (context != null) {
        showAlert(context, message: "Select Model");
      }
      return;
    }

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
  Future<void> registerModel(dynamic body) async {
    final registerId = _authStorage.read<String>('loginedId') ?? '';
    body.fields.add(MapEntry('LoginId', registerId));

    print(body);

    final dynamic data = await _api.createModel(body);
    if (data is String) {
      final context = Get.context;
      showAlert(context!, message: "Failed to Register the model.\nPlease retry or restart the server.");
      return;
    } else {
      await loadModels();
    }
  }

  // 앙상블 모델 등록
  Future<void> registerEnsembleModel(dynamic body) async {
    final registerId = _authStorage.read<String>('loginedId') ?? '';
    body.fields.add(MapEntry('LoginId', registerId));

    final dynamic data = await _api.createEnsembleModel(body);
    if (data is String) {
      final context = Get.context;
      showAlert(context!, message: "Failed to Register the model.\nPlease retry or restart the server.");
      return;
    } else {
      await loadModels();
    }
  }

  // 버전 or 셋업 등록
  Future<void> registerAssets(dynamic body) async {
    final context = Get.context;

    final modelId = selectedModelId.value;
    if (modelId == null) {
      if (context != null) {
        showAlert(context, message: "Select Model");
      }
      return;
    }

    final registerId = _authStorage.read<String>('loginedId') ?? '';
    body.fields.add(MapEntry('loginId', registerId));

    final dynamic data = await _api.addModelAssets(modelId: modelId, body: body);
    if (data is String) {
      showAlert(context!, message: "Failed to Register version or setup.\nPlease retry or restart the server.");
      return;
    } else {
      await loadModelInfo();
    }
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
