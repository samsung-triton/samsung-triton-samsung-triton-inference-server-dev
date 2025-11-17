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
  final selectedConfig = Rxn<RollbackItem>(); // 선택된 롤백 항목

  // 공통 API 클라이언트 사용
  late final ApiClient _api;

  // 계정 정보 확인을 위한 저장소
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
    _modelWatcher = ever<ModelItem?>(modelManageController.selectedModel, (_) {
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
    return Get.find<ModelManageController>().selectedModel.value?.modelId;
  }

  // 외부에서 에디터 내용만 주입
  void setEditorCtrlText({required String text}) {
    editorCtrl.text = text;
  }

  // 롤백 선택 함수
  void selectRollback(int configId) {
    if (selectedConfig.value?.configId == configId) return;
    selectedConfig.value = rollbacks.firstWhereOrNull((rollback) => rollback.configId == configId);
  }

  // 롤백 목록 로드
  Future<void> loadRollbacks() async {
    final modelId = _currentModelId();
    if (modelId == null) return;

    // API 호출
    final dynamic data = await _api.getConfigHistory(modelId: modelId);

    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      ShowAlert.show(message: "Failed to load the model list.\nPlease retry or restart the server.");
      return;
    }

    // configs 추출
    final List<dynamic> rawConfigs = (data['configs'] as List?) ?? [];

    // rawConfigs → RollbackItem 변환
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
    for (final rollback in fetchedConfigs) {
      if (rollback.isCurrent) {
        currentConfig = rollback;
        break;
      }
    }

    // 선택값 유지/초기화
    if (_hasUserSelectedOnce) {
      final prevId = selectedConfig.value?.configId;
      var exists = false;
      if (prevId != null) {
        for (final rollback in fetchedConfigs) {
          if (rollback.configId == prevId) {
            exists = true;
            break;
          }
        }
      }

      if (!exists) {
        // 이전 선택이 더 이상 없으면 current로 이동
        if (currentConfig != null) {
          selectRollback(currentConfig.configId);
        } else {
          selectedConfig.value = null;
        }
      } else {
        // 이전 선택이 여전히 존재하면, 새 리스트 기준으로 다시 셋팅
        selectRollback(prevId!);
      }
    } else {
      // 최초 로드
      if (currentConfig != null) {
        editorCtrl.text = currentConfig.content;
        selectRollback(currentConfig.configId);
      } else {
        selectedConfig.value = null;
      }
    }
  }

  // 저장
  Future<void> save(String description) async {
    final modelId = _currentModelId();
    if (modelId == null) return;

    final content = editorCtrl.text;
    final saveId = _authStorage.read<String>('loginedId') ?? '';

    print(content);

    final dynamic data = await _api.applyConfig(
      modelId: modelId,
      loginId: saveId,
      description: description,
      configContent: content,
    );

    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      ShowAlert.show(message: "Failed to load the model list.\nPlease retry or restart the server.");
      return;
    }
  }

  // 롤백 삭제
  void deleteRollback(String description) async {
    // 삭제 타겟 확인 (현재 선택 기준)
    final currentSelectedId = selectedConfig.value?.configId;
    RollbackItem? target;
    for (final rollback in rollbacks) {
      if (rollback.configId == currentSelectedId) {
        target = rollback;
        break;
      }
    }

    if (target == null) return;

    // 현재 사용중 항목은 삭제 금지
    if (target.isCurrent) {
      return;
    }

    final modelId = _currentModelId();
    if (modelId == null) return;

    final deleteId = _authStorage.read<String>('loginedId') ?? '';

    final dynamic data = await _api.deleteConfig(
      modelId: modelId,
      configId: target.configId,
      loginId: deleteId,
      description: description,
    );

    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      ShowAlert.show(message: "Failed to Delete rollback.\nPlease retry or restart the server.");
      return;
    }

    // 삭제 후 목록 재로딩
    await loadRollbacks();

    // 새 목록 기준으로 선택 정리
    if (rollbacks.isNotEmpty) {
      RollbackItem? current;
      for (final rollback in rollbacks) {
        if (rollback.isCurrent) {
          current = rollback;
          break;
        }
      }

      if (current != null) {
        selectRollback(current.configId);
      } else {
        selectRollback(rollbacks.first.configId);
      }
    } else {
      selectedConfig.value = null;
    }
  }

  // 에디터에 반영
  void getRollback() {
    // 아무것도 선택 안 돼 있으면 current 기준으로 한 번 선택
    if (selectedConfig.value == null) {
      for (final rollback in rollbacks) {
        if (rollback.isCurrent) {
          selectRollback(rollback.configId);
          break;
        }
      }
    }

    final rollback = selectedConfig.value;
    if (rollback == null) return;

    editorCtrl.text = rollback.content;
    _hasUserSelectedOnce = true;
  }
}
