// 버전 목록 관리 컨트롤러
import 'package:get/get.dart';

class VersionItem {
  final int version;
  final String file;
  final String user;
  final String createdAt;

  const VersionItem({required this.version, required this.file, required this.user, required this.createdAt});
}

class VersionManageController extends GetxController {
  // 현재 모델 정보
  final currentModelId = RxnInt();
  final currentModelName = ''.obs;

  // 버전 리스트 + 라디오 선택 버전
  final versions = <VersionItem>[].obs;
  final selectedVersion = RxnInt();

  // 모델 전환 시 로드
  Future<void> loadVersions({required int modelId, required String modelName}) async {
    currentModelId.value = modelId;
    currentModelName.value = modelName;

    // TODO: 버전 리스트 API 연동
    // final result = await api.fetchVersionList(modelId);
    // versions.assignAll(result);

    // 임시 더미
    final count = 5 + (modelId % 3);
    final tmp = <VersionItem>[];
    for (int i = 1; i <= count; i++) {
      tmp.add(
        VersionItem(
          version: i + 1,
          file: 'modelFile.onnx',
          user: 'admin',
          createdAt: '2025-10-${(i + 1).toString().padLeft(2, '0')}',
        ),
      );
    }
    versions.assignAll(tmp);

    // 첫 번째 버전 자동 선택
    if (versions.isNotEmpty) {
      selectedVersion.value = versions.first.version;
    }
  }

  // 버전 선택
  void selectVersion(int v) {
    selectedVersion.value = v;
  }

  // 버전 등록
  Future<void> registerVersion() async {
    final mid = currentModelId.value;
    if (mid == null) return;

    // TODO: 버전 추가 API 연동
    final nextIndex = versions.length + 10;
    final newRow = VersionItem(version: nextIndex, file: 'config.pbtxt', user: 'system', createdAt: '2025-11-01');
    versions.insert(0, newRow); // 위에 추가
  }

  // 선택된 버전 삭제
  Future<void> deleteSelectedVersion() async {
    final sv = selectedVersion.value;
    if (sv == null) return;

    // TODO: 버전 삭제 API 연동
    versions.removeWhere((e) => e.version == sv);

    // 첫 번째 버전 자동 선택
    if (versions.isNotEmpty) {
      selectedVersion.value = versions.first.version;
    }
  }

  void reset() {
    currentModelId.value = null;
    currentModelName.value = '';
    versions.clear();
    selectedVersion.value = null;
  }
}
