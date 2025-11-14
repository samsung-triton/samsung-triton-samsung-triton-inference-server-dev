import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 통합 서버/모델 컨트롤러
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

/// 대시보드 타입 (서버 / 모델 / 앙상블)
enum DashboardType { server, model, ensemble }

class DashboardController extends GetxController {
  /// 현재 활성화된 대시보드 영역
  final selectedType = DashboardType.server.obs;

  /// 현재 선택된 모델명 (model-dashboard 전용)
  final selectedItem = ''.obs;

  /// 마지막 갱신 시각
  final lastUpdated = Rxn<DateTime>();

  Timer? _timer;

  // ---- 통합 컨트롤러 ----
  late final ServerDashboardController serverCtrl;
  late final ModelDashboardController modelCtrl;

  @override
  void onInit() {
    super.onInit();

    // ===== Lazy 등록 =====
    if (!Get.isRegistered<ServerDashboardController>()) {
      Get.lazyPut(() => ServerDashboardController(), fenix: true);
    }
    if (!Get.isRegistered<ModelDashboardController>()) {
      Get.lazyPut(() => ModelDashboardController(), fenix: true);
    }

    // ===== 인스턴스 로드 =====
    serverCtrl = Get.find<ServerDashboardController>();
    modelCtrl = Get.find<ModelDashboardController>();

    // ===== 최초 1회 fetch =====
    _fetchCurrentGroup();

    // ===== 60초 자동 갱신 =====
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchCurrentGroup();
    });
  }

  /// ----------------------------------------
  /// Dashboard Type 변경 (서버 ↔ 모델)
  /// ----------------------------------------
  void changeType(DashboardType type, {String? item}) {
    selectedType.value = type;
    selectedItem.value = item ?? '';
    _fetchCurrentGroup();
  }

  /// ----------------------------------------
  /// 현재 선택된 그룹(Server/Model)에 따라 API 호출
  /// ----------------------------------------
  Future<void> _fetchCurrentGroup() async {
    switch (selectedType.value) {
      case DashboardType.server:
        await serverCtrl.fetchAll();
        break;

      case DashboardType.model:
        final modelName = selectedItem.value;
        if (modelName.isNotEmpty) {
          await modelCtrl.fetchAll(modelName);
        }
        break;

      case DashboardType.ensemble:
        // TODO: ensemble 추가 예정
        break;
    }

    lastUpdated.value = DateTime.now();
  }

  /// 수동 갱신 버튼
  Future<void> manualUpdate() async {
    await _fetchCurrentGroup();
  }

  String get formattedLastUpdated {
    final t = lastUpdated.value;
    if (t == null) return '-';
    return DateFormat('MMM d, yyyy • hh:mm a').format(t);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
