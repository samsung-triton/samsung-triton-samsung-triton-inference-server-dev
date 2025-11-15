import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:triton/utils/api_client.dart';
import 'package:get_storage/get_storage.dart';

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

  /// Reset Time (집계 기준 시각)
  final resetTime = ''.obs; // "10:30" 형태 SET
  final resetHour = 0.obs;
  final resetMinute = 0.obs;

  /// 사용자 권한
  final _authStorage = GetStorage('auth');
  final role = ''.obs;
  bool get isDevel => role.value == 'DEVEL';

  late final ApiClient _api;

  Timer? _timer;

  // ---- 통합 컨트롤러 ----
  late final ServerDashboardController serverCtrl;
  late final ModelDashboardController modelCtrl;

  @override
  void onInit() {
    super.onInit();

    // 🔹 API 클라이언트 주입
    _api = Get.find<ApiClient>();

    // 🔹 저장된 role 그대로 읽기
    role.value = _authStorage.read<String>('role') ?? '';

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

    // 🔹 ResetTime 최초 호출
    fetchResetTime();

    // ===== 최초 1회 fetch =====
    _fetchCurrentGroup();
  }

  // polling 함수로 타이머 추가
  void startPolling() {
    print("🔥 [DashboardController] startPolling() 호출됨");
    stopPolling();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) async {
      print("⏱️ [DashboardController] periodic tick → fetchAll() + fetchResetTime()");
      await fetchResetTime();
      await _fetchCurrentGroup();
    });
  }

  void stopPolling() {
    print("🛑 [DashboardController] stopPolling() 호출됨");
    _timer?.cancel();
    _timer = null;
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

  /// ----------------------------------------
  /// Reset Time GET 호출
  /// ----------------------------------------
  Future<void> fetchResetTime() async {
    try {
      final res = await _api.getStandardTime();
      // res = { "base_time": "10:30" }
      final base = res['base_time'];

      resetTime.value = base;

      final parts = base.split(':');
      resetHour.value = int.tryParse(parts[0]) ?? 0;
      resetMinute.value = int.tryParse(parts[1]) ?? 0;
    } catch (e) {
      print("❌ ResetTime GET 실패: $e");
    }
  }

  /// ----------------------------------------
  /// Reset Time 드롭다운 변경용 Setter
  /// ----------------------------------------
  void setResetHour(String hh) {
    resetHour.value = int.tryParse(hh) ?? 0;
  }

  void setResetMinute(String mm) {
    resetMinute.value = int.tryParse(mm) ?? 0;
  }

  /// ----------------------------------------
  /// Reset Time POST 호출 (DEVEL 전용)
  /// ----------------------------------------
  Future<void> updateResetTime() async {
    if (!isDevel) return;

    final timeStr = "${resetHour.value.toString().padLeft(2, '0')}:${resetMinute.value.toString().padLeft(2, '0')}";

    try {
      final res = await _api.updateStandardTime(timeStr);
      // res = { "base_time": "10:30" }
      final base = res['base_time'];

      resetTime.value = base;

      final parts = base.split(':');
      resetHour.value = int.tryParse(parts[0]) ?? resetHour.value;
      resetMinute.value = int.tryParse(parts[1]) ?? resetMinute.value;
    } catch (e) {
      print("❌ ResetTime POST 실패: $e");
    }
  }

  /// 수동 갱신 버튼
  Future<void> manualUpdate() async {
    // Update 버튼 눌렀을 때도 ResetTime + 대시보드 같이 새로고침
    await fetchResetTime();
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
