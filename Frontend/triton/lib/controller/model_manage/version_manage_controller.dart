// 버전 목록 관리 컨트롤러
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/controller/model_manage/model_manage_controller.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';

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

  // 공통 API 클라이언트 사용
  late final ApiClient _api;

  // 게정 정보 확인을 위한 저장소 사용
  GetStorage get _authStorage => GetStorage('auth');

  @override
  void onInit() {
    super.onInit();

    _api = Get.find<ApiClient>();
  }

  // 버전 목록 받기
  void setVersions(List<VersionItem> items) {
    versions.assignAll(items);
    selectedVersion.value = versions.isNotEmpty ? versions.first.version : null;
    selectedVersionId.value = versions.isNotEmpty ? versions.first.versionId : null;
  }

  // 버전 선택
  void selectVersion(int versionId, int version) {
    selectedVersion.value = version;
    selectedVersionId.value = versionId;
  }

  // 선택된 버전 삭제
  Future<void> deleteSelectedVersion(String description) async {
    final version = selectedVersion.value;
    if (version == null) return;

    final context = Get.context;
    final deleteId = _authStorage.read<String>('loginedId') ?? '';
    // 버전 채워 넣기
    final modelManageController = Get.find<ModelManageController>();
    final modelId = modelManageController.selectedModelId.value;
    if (modelId == null) {
      if (context != null) {
        showAlert(context, message: "Select Model");
      }
      return;
    }

    final dynamic data = await _api.deleteModelVersion(
      modelId: modelId,
      version: version,
      loginId: deleteId,
      description: description,
    );
    // 데이터가 String이면 에러 메시지로 간주
    if (data is String) {
      final context = Get.context;
      showAlert(context!, message: "Failed to Delete version.\nPlease retry or restart the server.");
      return;
    }

    modelManageController.loadModelInfo();

    // 첫 번째 버전 자동 선택
    if (versions.isNotEmpty) {
      selectedVersion.value = versions.first.version;
      selectedVersionId.value = versions.first.versionId;
    } else {
      selectedVersion.value = null;
      selectedVersionId.value = null;
    }
  }
}
