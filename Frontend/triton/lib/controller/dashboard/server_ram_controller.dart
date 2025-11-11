import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';

/// [ServerRamController]
/// - RAM 사용률 시계열 데이터 관리
/// - 추후 /server/ram API와 연동 예정
class ServerRamController extends GetxController {
  /// 현재 RAM 사용률 시계열 데이터
  final ramSeries = <FlSpot>[].obs;

  /// 전체 스냅샷 데이터 (RAM % 등)
  final metrics = ServerMetrics.mock.obs;

  /// 로딩 상태
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 초기 mock 데이터 세팅
    ramSeries.assignAll(ServerRamMockData.ramUsage);
  }

  /// ✅ RAM 데이터 fetch (mock 기반)
  Future<void> fetch() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    // 간단히 값에 변동을 주는 시뮬레이션
    final updated = ramSeries.map((spot) {
      final delta = (spot.y + (spot.y % 7) - 3).clamp(0, 100).toDouble();
      return FlSpot(spot.x, delta);
    }).toList();

    ramSeries.assignAll(updated);

    // 마지막 값으로 스냅샷 업데이트
    final current = metrics.value;
    metrics.value = ServerMetrics(
      smUtil: current.smUtil,
      tensorCoreUtil: current.tensorCoreUtil,
      fp32Util: current.fp32Util,
      inferenceThroughput: current.inferenceThroughput,
      gpuVram: current.gpuVram,
      cpuUsage: current.cpuUsage,
      ramUsage: updated.last.y,
    );

    loading.value = false;
  }
}
