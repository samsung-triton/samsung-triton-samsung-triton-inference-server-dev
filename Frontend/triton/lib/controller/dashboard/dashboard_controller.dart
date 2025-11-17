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

// ==================================================================
// 🔥 DashboardModelItem (대시보드 모델 목록 DTO)
// ==================================================================
class DashboardModelItem {
  final int modelId;
  final String modelName;
  final int inferenceTotal;
  final int inferenceOk;
  final double okRatio;

  DashboardModelItem({
    required this.modelId,
    required this.modelName,
    required this.inferenceTotal,
    required this.inferenceOk,
    required this.okRatio,
  });

  factory DashboardModelItem.fromJson(Map<String, dynamic> json) {
    return DashboardModelItem(
      modelId: json['modelId'],
      modelName: json['modelName'],
      inferenceTotal: json['inference_total'],
      inferenceOk: json['inference_ok'],
      okRatio: (json['ok_ratio'] as num).toDouble(),
    );
  }
}

// ==================================================================

class DashboardController extends GetxController {
  /// 현재 활성화된 대시보드 영역
  final selectedType = DashboardType.server.obs;

  /// 선택된 모델 ID
  final selectedModelId = RxnInt();

  /// 모델 목록 (대시보드 모델 리스트 API 결과)
  final modelList = <DashboardModelItem>[].obs;

  /// 마지막 갱신 시각
  final lastUpdated = Rxn<DateTime>();

  /// Reset Time (집계 기준 시각)
  final resetTime = ''.obs; // "10:30" 형태 SET
  final resetHour = 0.obs;
  final resetMinute = 0.obs;

  /// 사용자 권한
  final _authStorage = GetStorage('auth');
  final role = ''.obs;
  bool get isDevel => role.value.toUpperCase() == 'DEVEL';

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

    // 🔥 모델 목록 최초 조회
    fetchDashboardModelList();

    // ===== 최초 1회 fetch =====
    _fetchCurrentGroup();
  }

  // ==================================================================
  // 🔥 대시보드 모델 목록 API 호출
  // ==================================================================
  Future<void> fetchDashboardModelList() async {
    try {
      final res = await _api.getDashboardModelList();
      final list = res['models'] as List;
      modelList.assignAll(list.map((e) => DashboardModelItem.fromJson(e)));

      print("✅ 모델 목록 조회 성공: ${modelList.length}개");
    } catch (e) {
      print("❌ 모델 목록 조회 실패: $e");
    }
  }

  // ==================================================================
  // 🔥 polling 함수로 타이머 추가
  // ==================================================================
  void startPolling() {
    print("🔥 [DashboardController] startPolling() 호출됨");
    stopPolling();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) async {
      print("⏱️ polling tick → fetchAll() + fetchResetTime()");
      await fetchResetTime();
      await fetchDashboardModelList(); // <-- 모델 목록도 주기적으로 갱신
      await _fetchCurrentGroup();
    });
  }

  void stopPolling() {
    print("🛑 [DashboardController] stopPolling() 호출됨");
    _timer?.cancel();
    _timer = null;
  }

  // ==================================================================
  // 🔥 Dashboard Type 변경
  // ==================================================================
  void changeType(DashboardType type, {int? modelId}) {
    selectedType.value = type;
    selectedModelId.value = modelId;
    _fetchCurrentGroup();
  }

  // ==================================================================
  // 🔥 Server / Model 화면별 fetch
  // ==================================================================
  Future<void> _fetchCurrentGroup() async {
    switch (selectedType.value) {
      case DashboardType.server:
        await serverCtrl.fetchAll();
        break;

      case DashboardType.model:
        final id = selectedModelId.value;

        if (id != null) {
          // modelId → modelName 변환
          final item = modelList.firstWhereOrNull((e) => e.modelId == id);

          if (item != null) {
            try {
              await modelCtrl.fetchAll(item.modelName); // 🔥 기존 구조 유지
            } catch (e) {
              print("❌ ModelDashboard fetch 실패: $e");
            }
          }
        }
        break;

      case DashboardType.ensemble:
        break;
    }

    lastUpdated.value = DateTime.now();
  }

  // ==================================================================
  // Reset Time GET 호출
  // ==================================================================
  Future<void> fetchResetTime() async {
    try {
      final res = await _api.getStandardTime();
      final base = res['base_time'];

      resetTime.value = base;
      final parts = base.split(':');
      resetHour.value = int.tryParse(parts[0]) ?? 0;
      resetMinute.value = int.tryParse(parts[1]) ?? 0;
    } catch (e) {
      print("❌ ResetTime GET 실패: $e");
    }
  }

  // ==================================================================
  // Reset Time POST
  // ==================================================================
  Future<void> updateResetTime() async {
    if (!isDevel) return;

    final hh = resetHour.value.toString().padLeft(2, '0');
    final mm = resetMinute.value.toString().padLeft(2, '0');
    final newTime = "$hh:$mm";

    try {
      final res = await _api.updateStandardTime(newTime);

      final base = res['base_time']; // 서버 응답
      resetTime.value = base;

      final parts = base.split(':');
      resetHour.value = int.parse(parts[0]);
      resetMinute.value = int.parse(parts[1]);
    } catch (e) {
      print("❌ ResetTime POST 실패: $e");
    }
  }

  void setResetHour(String hh) {
    resetHour.value = int.tryParse(hh) ?? 0;
  }

  void setResetMinute(String mm) {
    resetMinute.value = int.tryParse(mm) ?? 0;
  }

  Future<void> manualUpdate() async {
    await fetchResetTime();
    await fetchDashboardModelList();
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
