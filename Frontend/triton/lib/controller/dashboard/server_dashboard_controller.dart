import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';

/// ------------------------------------------------------------
///  ServerDashboardController
///  - CPU / GPU / RAM / CUDA 모든 서버 메트릭 통합 관리
///  - 기존: server_cpu / server_gpu / server_ram / server_cuda
///  - 새 구조: fetchAll() 호출로 전체 갱신
/// ------------------------------------------------------------
class ServerDashboardController extends GetxController {
  /// 🔹 서버 전체 메트릭 스냅샷
  final metrics = ServerMetrics.mock.obs;

  /// 🔹 시계열 데이터 (RAM / GPU VRAM)
  final gpuVramSeries = <FlSpot>[].obs;
  final ramSeries = <FlSpot>[].obs;

  /// 🔹 로딩 상태
  final loading = false.obs;

  // ============================================================
  // ⬇️ Computed Fields (UI에서 바로 접근 가능)
  // ============================================================

  double get latestCpuUsage => metrics.value.cpuUsage;
  double get latestGpuVram => gpuVramSeries.isNotEmpty ? gpuVramSeries.last.y : metrics.value.gpuVram;
  double get latestRamUsage => ramSeries.isNotEmpty ? ramSeries.last.y : metrics.value.ramUsage;

  double get latestSmUtil => metrics.value.smUtil;
  double get latestTensorUtil => metrics.value.tensorCoreUtil;
  double get latestFp32Util => metrics.value.fp32Util;
  int get latestThroughput => metrics.value.inferenceThroughput;

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
  // 🔥 전체 서버 메트릭 로드 (CPU + GPU + RAM + CUDA)
  // ============================================================
  Future<void> fetchAll() async {
    loading.value = true;

    await Future.delayed(const Duration(milliseconds: 400));

    // ---------------------------------------------------------
    // 1) CPU usage mock update
    // ---------------------------------------------------------
    final prev = metrics.value;

    final updatedCpu = (prev.cpuUsage + 10) % 100;

    // ---------------------------------------------------------
    // 2) GPU VRAM 시계열 mock update
    // ---------------------------------------------------------
    final updatedGpuSeries = ServerGpuMockData.vramUsage.map((spot) {
      final delta = (spot.y + (spot.y % 10) - 5).clamp(0, 100).toDouble();
      return FlSpot(spot.x, delta);
    }).toList();
    gpuVramSeries.assignAll(updatedGpuSeries);

    // ---------------------------------------------------------
    // 3) RAM 시계열 mock update
    // ---------------------------------------------------------
    final updatedRamSeries = ramSeries.map((spot) {
      final delta = (spot.y + (spot.y % 7) - 3).clamp(0, 100).toDouble();
      return FlSpot(spot.x, delta);
    }).toList();
    ramSeries.assignAll(updatedRamSeries);

    // ---------------------------------------------------------
    // 4) CUDA 관련 지표 mock update
    // ---------------------------------------------------------
    final updatedCudaSm = (prev.smUtil + 5) % 100;
    final updatedTensor = (prev.tensorCoreUtil + 3) % 100;
    final updatedFp32 = (prev.fp32Util + 4) % 100;
    final updatedThroughput = (prev.inferenceThroughput + 10) % 400;

    // ---------------------------------------------------------
    // 🔥 최종 통합 Snapshot 업데이트
    // ---------------------------------------------------------
    metrics.value = ServerMetrics(
      smUtil: updatedCudaSm,
      tensorCoreUtil: updatedTensor,
      fp32Util: updatedFp32,
      inferenceThroughput: updatedThroughput,
      gpuVram: updatedGpuSeries.last.y,
      cpuUsage: updatedCpu,
      ramUsage: updatedRamSeries.last.y,
    );

    loading.value = false;
  }
}
