import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';

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
    gpuVramSeries.assignAll(ServerGpuMockData.vramUsage);
    ramSeries.assignAll(ServerRamMockData.ramUsage);
  }

  // ============================================================
  // 🔥 전체 서버 메트릭 로드 (CPU + RAM + GPU Utilization + GPU VRAM)
  // ============================================================
  Future<void> fetchAll() async {
    loading.value = true;

    // API 연동 전이므로 Mock Delay
    await Future.delayed(const Duration(milliseconds: 300));

    final prev = metrics.value;

    // ---------------------------------------------------------
    // 1) CPU usage mock update
    // ---------------------------------------------------------
    final updatedCpu = (prev.cpuUsage + 7) % 100;

    // ---------------------------------------------------------
    // 2) GPU Utilization mock update
    // ---------------------------------------------------------
    final updatedGpuUtil = (prev.gpuUtilization + 9) % 100;

    // ---------------------------------------------------------
    // 3) GPU VRAM 시계열 mock update
    // ---------------------------------------------------------
    final updatedGpuSeries = gpuVramSeries.map((spot) {
      final delta = (spot.y + (spot.y % 8) - 4).clamp(0, 100).toDouble();
      return FlSpot(spot.x, delta);
    }).toList();
    gpuVramSeries.assignAll(updatedGpuSeries);

    // ---------------------------------------------------------
    // 4) RAM Usage 시계열 mock update
    // ---------------------------------------------------------
    final updatedRamSeries = ramSeries.map((spot) {
      final delta = (spot.y + (spot.y % 5) - 2).clamp(0, 100).toDouble();
      return FlSpot(spot.x, delta);
    }).toList();
    ramSeries.assignAll(updatedRamSeries);

    // ---------------------------------------------------------
    // 5) sidebar card mock update
    // ---------------------------------------------------------
    final updatedModels = prev.models.map((m) {
      return m.copyWith(success: m.success + (m.success % 5), fail: m.fail + (m.fail % 3));
    }).toList();

    // ---------------------------------------------------------
    // 🔥 최종 Snapshot 업데이트
    // ---------------------------------------------------------
    metrics.value = ServerMetrics(
      cpuUsage: updatedCpu,
      ramUsage: updatedRamSeries.last.y,
      gpuUtilization: updatedGpuUtil,
      gpuVram: updatedGpuSeries.last.y,
      models: updatedModels,
    );

    loading.value = false;
  }
}
