// 모델 목록 관리 컨트롤러
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/controller/model_manage/config_controller.dart';
import 'package:triton/controller/model_manage/version_manage_controller.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/server_guard.dart';
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
  final selectedModel = Rxn<ModelItem>();

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
      ShowAlert.show(message: "Failed to load the model list.\nPlease retry or restart the server.");
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
    if (selectedModel.value?.modelId == modelId) return;
    selectedModel.value = models.firstWhereOrNull((e) => e.modelId == modelId);

    await loadModelInfo();
  }

  Future<void> loadModelInfo() async {
    final modelId = selectedModel.value?.modelId;
    if (modelId == null) {
      ShowAlert.show(message: "Select Model");
      return;
    }

    final dynamic data = await _api.getModelVersionsAndConfig(modelId: modelId);
    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      ShowAlert.show(message: "Failed to load the model data.\nPlease retry or restart the server.");
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
    final ok = await isServerRunning();
    if (!ok) {
      ShowAlert.show(
        title: 'Server Not Running',
        message:
            'The Triton server is currently not running.\n'
            'Please start the server and try again.',
      );
      return;
    }

    final registerId = _authStorage.read<String>('loginedId') ?? '';
    body.fields.add(MapEntry('LoginId', registerId));

    final dynamic data = await _api.createModel(body);
    if (data is String) {
      ShowAlert.show(message: "Failed to Register the model.\nPlease retry or restart the server.");
      return;
    } else {
      await loadModels();
    }
  }

  // 앙상블 모델 등록
  Future<void> registerEnsembleModel(dynamic body) async {
    final ok = await isServerRunning();
    if (!ok) {
      ShowAlert.show(
        title: 'Server Not Running',
        message:
            'The Triton server is currently not running.\n'
            'Please start the server and try again.',
      );
      return;
    }

    final registerId = _authStorage.read<String>('loginedId') ?? '';
    body.fields.add(MapEntry('LoginId', registerId));

    final dynamic data = await _api.createEnsembleModel(body);
    if (data is String) {
      ShowAlert.show(message: "Failed to Register the model.\nPlease retry or restart the server.");
      return;
    } else {
      await loadModels();
    }
  }

  // 버전 or 셋업 등록
  Future<void> registerAssets(dynamic body) async {
    final ok = await isServerRunning();
    if (!ok) {
      ShowAlert.show(
        title: 'Server Not Running',
        message:
            'The Triton server is currently not running.\n'
            'Please start the server and try again.',
      );
      return;
    }

    final modelId = selectedModel.value?.modelId;
    if (modelId == null) {
      ShowAlert.show(message: "Select Model");
      return;
    }

    final registerId = _authStorage.read<String>('loginedId') ?? '';
    body.fields.add(MapEntry('loginId', registerId));

    final dynamic data = await _api.addModelAssets(modelId: modelId, body: body);
    if (data is String) {
      ShowAlert.show(message: "Failed to Register version or setup.\nPlease retry or restart the server.");
      return;
    } else {
      await loadModelInfo();
    }
  }

  // 모델 삭제
  Future<void> deleteModel(int modeld, String description) async {
    final ok = await isServerRunning();
    if (!ok) {
      ShowAlert.show(
        title: 'Server Not Running',
        message:
            'The Triton server is currently not running.\n'
            'Please start the server and try again.',
      );
      return;
    }

    final modelId = selectedModel.value?.modelId;
    if (modelId == null) {
      ShowAlert.show(message: "Select Model");
      return;
    }

    final deleteId = _authStorage.read<String>('loginedId') ?? '';

    final dynamic data = await _api.deleteModel(modelId: modelId, loginId: deleteId, description: description);
    if (data is String) {
      ShowAlert.show(message: "Failed to Delete model.\nPlease retry or restart the server.");
      return;
    } else {
      await loadModels();
    }
  }
}
