import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';
import 'package:triton/utils/api_client.dart'; // ← 🔥 추가 필요

/// ------------------------------------------------------------
///  ServerDashboardController (New GPU Utilization Structure)
/// ------------------------------------------------------------
class ServerDashboardController extends GetxController {
  /// 🔹 서버 전체 스냅샷 (CPU / RAM / GPU Utilization)
  final metrics = ServerMetrics.mock.obs;

  /// 🔹 시계열 (RAM / GPU VRAM)
  final gpuVramSeries = <FlSpot>[].obs;
  final ramSeries = <FlSpot>[].obs;

  /// 🔹 로딩 상태
  final loading = false.obs;

  // API Client 인스턴스
  late final ApiClient _api;

  // ============================================================
  // ⬇️ Computed Fields
  // ============================================================
  double get latestCpuUsage => metrics.value.cpuUsage;
  double get latestGpuUtil => metrics.value.gpuUtilization;
  double get latestGpuVram => gpuVramSeries.isNotEmpty ? gpuVramSeries.last.y : metrics.value.gpuVram;
  double get latestRamUsage => ramSeries.isNotEmpty ? ramSeries.last.y : metrics.value.ramUsage;

  // ============================================================
  // Init
  // ============================================================
  @override
  void onInit() {
    super.onInit();

    /// 1) API client 주입
    _api = Get.find<ApiClient>();

    /// 2) 시계열 mock은 그대로 유지 (추후 timeseries API로 대체)
    gpuVramSeries.assignAll(ServerGpuMockData.vramUsage);
    ramSeries.assignAll(ServerRamMockData.ramUsage);

    /// 옵션: 최초 1회 fetch
    // fetchAll();
  }

  // ============================================================
  // 🔥 전체 서버 메트릭 로드 (CPU + RAM + GPU Utilization + GPU VRAM)
  // ============================================================
  Future<void> fetchAll() async {
    loading.value = true;

    try {
      // mock delay 제거 가능하지만 임시 유지
      await Future.delayed(const Duration(milliseconds: 300));

      // 기존 mock 업데이트 제거하고 API 기반으로 교체
      final apiData = await _api.getServerMetrics();
      print('🔥🔥🔥 server metrics apiData: $apiData');

      // null-safe
      if (apiData == null) {
        loading.value = false;
        return;
      }

      final cpu = (apiData['cpu_utilization'] ?? 0).toDouble();

      final gpuList = apiData['gpu'] as List<dynamic>;
      final gpu = gpuList.isNotEmpty ? (gpuList[0]['gpu_util'] ?? 0).toDouble() : 0.0;

      final prev = metrics.value;

      // ======================================================
      // [수정 #3] metrics 스냅샷 갱신 — CPU/GPU만 실제 값으로 교체
      // ======================================================
      metrics.value = ServerMetrics(
        cpuUsage: cpu,
        ramUsage: prev.ramUsage,
        gpuUtilization: gpu,
        gpuVram: prev.gpuVram,
        models: prev.models,
      );
    } catch (e) {
      print('[ServerDashboardController] fetchAll Error: $e');
    }

    loading.value = false;
  }
}
