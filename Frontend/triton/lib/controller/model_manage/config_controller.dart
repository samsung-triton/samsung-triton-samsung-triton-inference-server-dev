// config 관리 컨트롤러
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/model_manage/model_manage_controller.dart';

// 롤백 엔트리 모델
class RollbackItem {
  final int configId;
  final int version;
  final DateTime createdAt;
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

  // 사용자가 getRollback으로 직접 선택했는지 여부
  bool _hasUserSelectedOnce = false;

  // 모델 변경 감시
  late final Worker _modelWatcher;

  @override
  void onInit() {
    super.onInit();
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

    // TODO: API 연동 (modelId 기준 롤백 목록 조회)
    final list = _dummyRollbacks(modelId);

    rollbacks.assignAll(list);

    // 서버에서 사용중인 current 탐색
    RollbackItem? current;
    for (final e in list) {
      if (e.isCurrent) {
        current = e;
        break;
      }
    }

    // 선택값 유지/초기화
    if (_hasUserSelectedOnce) {
      final prev = selectedConfigId.value;
      var exists = false;
      if (prev != null) {
        for (final e in list) {
          if (e.configId == prev) {
            exists = true;
            break;
          }
        }
      }
      if (!exists) {
        selectedConfigId.value = current?.configId;
      }
    } else {
      editorCtrl.text = current!.content;
      selectedConfigId.value = current.configId;
    }
  }

  // 저장
  Future<void> save() async {
    final modelId = _currentModelId();
    if (modelId == null) return;

    final content = editorCtrl.text;

    // TODO: 저장 API 호출 시 서버가 configId를 생성해주면 그 값을 사용
    final newId = DateTime.now().millisecondsSinceEpoch;
    const username = 'system';

    // TODO: 추후 삭제
    var maxV = 0;
    for (final e in rollbacks) {
      if (e.version > maxV) maxV = e.version;
    }

    final newEntry = RollbackItem(
      configId: newId,
      version: maxV + 1,
      createdAt: DateTime.now(),
      userName: username,
      content: content,
      isCurrent: false,
    );

    rollbacks.insert(0, newEntry);

    selectedConfigId.value = newEntry.configId;
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

  // 더미 데이터 (API 연결 전 테스트용)
  List<RollbackItem> _dummyRollbacks(int modelId) {
    final now = DateTime.now();
    return [
      RollbackItem(
        configId: modelId * 1000 + 3,
        version: 3,
        createdAt: now.subtract(const Duration(minutes: 5)),
        userName: 'jane',
        content: '# rollback 3 for model $modelId\nmax_batch_size: 16\n',
        isCurrent: false,
      ),
      RollbackItem(
        configId: modelId * 1000 + 2,
        version: 2,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 12)),
        userName: 'minsu',
        content: '# rollback 2 for model $modelId\nmax_batch_size: 8\n',
        isCurrent: true,
      ),
      RollbackItem(
        configId: modelId * 1000 + 1,
        version: 1,
        createdAt: now.subtract(const Duration(days: 1, minutes: 3)),
        userName: 'admin',
        content: '# rollback 1 for model $modelId\nmax_batch_size: 4\n',
        isCurrent: false,
      ),
    ];
  }
}
