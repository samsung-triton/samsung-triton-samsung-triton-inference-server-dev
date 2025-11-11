// lib/controller/dashboard/server_gpu_controller.dart

import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';

class ServerGpuController extends GetxController {
  // ✅ GPU 스냅샷 (VRAM %, SM Util 등)
  final metrics = ServerMetrics.mock.obs;

  // ✅ GPU VRAM 시계열 데이터
  final vramSeries = <FlSpot>[].obs;

  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 초기 Mock 데이터 세팅
    vramSeries.assignAll(ServerGpuMockData.vramUsage);
  }

  Future<void> fetch() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    // 🔹 시뮬레이션: 시계열 데이터 랜덤 변화
    final newData = ServerGpuMockData.vramUsage.map((spot) {
      final delta = (spot.y + (spot.y % 10) - 5).clamp(0, 100).toDouble();
      return FlSpot(spot.x, delta);
    }).toList();

    vramSeries.assignAll(newData);

    // 🔹 VRAM 퍼센트 값도 함께 변경
    final updated = ServerMetrics(
      smUtil: metrics.value.smUtil,
      tensorCoreUtil: metrics.value.tensorCoreUtil,
      fp32Util: metrics.value.fp32Util,
      inferenceThroughput: metrics.value.inferenceThroughput,
      gpuVram: newData.last.y,
      cpuUsage: metrics.value.cpuUsage,
      ramUsage: metrics.value.ramUsage,
    );
    metrics.value = updated;

    loading.value = false;
  }
}
