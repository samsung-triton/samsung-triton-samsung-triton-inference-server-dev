// config 관리 컨트롤러
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/controller/model_manage/model_manage_controller.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';

// 롤백 엔트리 모델
class RollbackItem {
  final int configId;
  final int version;
  final String createdAt;
  final String userName;
  final String content;
  final bool isCurrent;

  const RollbackItem({
    required this.configId,
    required this.version,
    required this.createdAt,
    required this.userName,
    required this.content,
    this.isCurrent = false,
  });
}

class ConfigController extends GetxController {
  // 에디터
  final editorCtrl = TextEditingController();

  // 롤백 목록 & 선택
  final rollbacks = <RollbackItem>[].obs;
  final selectedConfigId = RxnInt();

  // 공통 API 클라이언트 사용
  late final ApiClient _api;

  // 게정 정보 확인을 위한 저장소 사용
  GetStorage get _authStorage => GetStorage('auth');

  // 사용자가 getRollback으로 직접 선택했는지 여부
  bool _hasUserSelectedOnce = false;

  // 모델 변경 감시
  late final Worker _modelWatcher;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();

    final modelManageController = Get.find<ModelManageController>();

    // 모델이 바뀌면 "사용자 선택 여부" 초기화
    _modelWatcher = ever<int?>(modelManageController.selectedModelId, (_) {
      _hasUserSelectedOnce = false;
    });
  }

  @override
  void onClose() {
    _modelWatcher.dispose();
    editorCtrl.dispose();
    super.onClose();
  }

  // 현재 선택된 modelId 반환
  int? _currentModelId() {
    return Get.find<ModelManageController>().selectedModelId.value;
  }

  // 외부에서 에디터 내용만 주입
  void setEditorCtrlText({required String text}) {
    editorCtrl.text = text;
  }

  // 롤백 목록 로드
  Future<void> loadRollbacks() async {
    final modelId = _currentModelId();
    if (modelId == null) return;

    // API 호출
    final dynamic data = await _api.getConfigHistory(modelId: modelId);

    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      final context = Get.context;
      showAlert(context!, message: "Failed to load the model list.\nPlease retry or restart the server.");
      return;
    }

    // models 추출
    final List<dynamic> rawConfigs = (data['configs'] as List?) ?? [];

    // rawModel을 ModelItem 변환
    final List<RollbackItem> fetchedConfigs = rawConfigs.map((rawConfig) {
      return RollbackItem(
        configId: rawConfig['configId'] as int,
        version: rawConfig['version'] as int,
        createdAt: rawConfig['createdAt'] as String,
        userName: rawConfig['userName'] as String,
        content: rawConfig['content'] as dynamic,
        isCurrent: rawConfig['isCurrent'] as bool,
      );
    }).toList();

    rollbacks.assignAll(fetchedConfigs);

    // 서버에서 사용중인 current 탐색
    RollbackItem? currentConfig;
    for (final config in fetchedConfigs) {
      if (config.isCurrent) {
        currentConfig = config;
        break;
      }
    }

    // 선택값 유지/초기화
    if (_hasUserSelectedOnce) {
      final prev = selectedConfigId.value;
      var exists = false;
      if (prev != null) {
        for (final e in fetchedConfigs) {
          if (e.configId == prev) {
            exists = true;
            break;
          }
        }
      }
      if (!exists) {
        selectedConfigId.value = currentConfig?.configId;
      }
    } else {
      editorCtrl.text = currentConfig!.content;
      selectedConfigId.value = currentConfig.configId;
    }
  }

  // 저장
  Future<void> save(String description) async {
    final modelId = _currentModelId();
    if (modelId == null) return;

    final content = editorCtrl.text;
    final saveId = _authStorage.read<String>('loginedId') ?? '';

    print(content);

    // API 호출
    final dynamic data = await _api.applyConfig(
      modelId: modelId,
      loginId: saveId,
      description: description,
      configContent: content,
    );

    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      final context = Get.context;
      showAlert(context!, message: "Failed to load the model list.\nPlease retry or restart the server.");
      return;
    }
  }

  // 롤백 삭제
  void deleteRollback() {
    final modelId = _currentModelId();
    if (modelId == null) return;

    // 추후 삭제
    RollbackItem? target;
    for (final e in rollbacks) {
      if (e.configId == selectedConfigId.value) {
        target = e;
        break;
      }
    }

    if (target == null) return;

    // 현재 사용중 항목은 삭제 금지
    if (target.isCurrent) {
      return;
    }

    // 정상 삭제
    rollbacks.removeWhere((e) => e.configId == selectedConfigId.value);

    selectedConfigId.value = rollbacks.first.configId;

    // TODO: 서버 롤백 엔트리 삭제 API 호출
    // await api.createRollback(modelId: mid, entry: newEntry);
  }

  // 선택
  void getRollback() {
    if (selectedConfigId.value == null) {
      for (final e in rollbacks) {
        if (e.isCurrent) {
          selectedConfigId.value = e.configId;
          break;
        }
      }
    }

    final targetId = selectedConfigId.value;
    if (targetId == null) return;

    RollbackItem? entry;
    for (final e in rollbacks) {
      if (e.configId == targetId) {
        entry = e;
        break;
      }
    }
    if (entry == null) return;

    editorCtrl.text = entry.content;
    _hasUserSelectedOnce = true;
  }
}
