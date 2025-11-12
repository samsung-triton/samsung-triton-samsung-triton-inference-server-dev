// 버전 목록 관리 컨트롤러
import 'package:get/get.dart';

import '../../controller/model_manage/model_manage_controller.dart';

class VersionItem {
  final int versionId;
  final int version;
  final String fileName;
  final String userName;
  final String createdAt;

  const VersionItem({
    required this.versionId,
    required this.version,
    required this.fileName,
    required this.userName,
    required this.createdAt,
  });
}

class VersionManageController extends GetxController {
  // 버전 리스트 + 라디오 선택 버전
  final versions = <VersionItem>[].obs;
  final selectedVersionId = RxnInt();
  final selectedVersion = RxnInt();

  // 버전 목록 받기
  void setVersions(List<VersionItem> items) {
    versions.assignAll(items);
    selectedVersionId.value = versions.isNotEmpty ? versions.first.versionId : null;
  }

  // 버전 선택
  void selectVersion(int versionId, int version) {
    selectedVersionId.value = versionId;
    selectedVersion.value = version;
  }

  // 버전 등록
  Future<void> registerVersion() async {
    final modelManageController = Get.find<ModelManageController>();
    final modelId = modelManageController.selectedModelId.value;
    if (modelId == null) return;

    // TODO: 버전 추가 API 연동
    final nextIndex = versions.length + 10;
    final newRow = VersionItem(
      versionId: nextIndex,
      version: nextIndex,
      fileName: 'config.pbtxt',
      userName: 'system',
      createdAt: '2025-11-01',
    );
    versions.insert(0, newRow); // 위에 추가
  }

  // 선택된 버전 삭제
  Future<void> deleteSelectedVersion() async {
    final version = selectedVersion.value;
    if (version == null) return;

    // TODO: 버전 삭제 API 연동
    versions.removeWhere((e) => e.version == version);

    // 첫 번째 버전 자동 선택
    if (versions.isNotEmpty) {
      selectedVersionId.value = versions.first.versionId;
      selectedVersion.value = versions.first.version;
    } else {
      selectedVersionId.value = null;
      selectedVersion.value = null;
    }
  }

  void reset() {
    versions.clear();
    selectedVersion.value = null;
  }
}
