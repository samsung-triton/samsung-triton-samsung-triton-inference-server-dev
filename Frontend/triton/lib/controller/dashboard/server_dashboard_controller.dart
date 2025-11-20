import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';
import 'package:triton/utils/api_client.dart';

class ServerDashboardController extends GetxController {
  /// 서버 전체 스냅샷
  final metrics = ServerMetrics.mock.obs;

  /// 시계열 (RAM / GPU VRAM)
  final gpuVramSeries = <FlSpot>[].obs;
  final ramSeries = <FlSpot>[].obs;

  /// timestamp 저장 (chart 라벨용)
  final gpuVramTimestamps = <DateTime>[].obs;
  final ramTimestamps = <DateTime>[].obs;

  /// 로딩 상태
  final loading = false.obs;

  /// 에러 상태
  final cpuError = RxnString();
  final gpuError = RxnString();
  final vramError = RxnString();
  final ramError = RxnString();

  /// API Client
  late final ApiClient _api;

  // ------------------------------------------------------------
  // Computed Fields
  // ------------------------------------------------------------
  double get latestCpuUsage => metrics.value.cpuUsage;
  double get latestGpuUtil => metrics.value.gpuUtilization;
  double get latestGpuVram => gpuVramSeries.isNotEmpty ? gpuVramSeries.last.y : metrics.value.gpuVram;
  double get latestRamUsage => ramSeries.isNotEmpty ? ramSeries.last.y : metrics.value.ramUsage;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();

    // 초기 빈값
    gpuVramSeries.value = [];
    ramSeries.value = [];
    gpuVramTimestamps.value = [];
    ramTimestamps.value = [];
  }

  Future<void> fetchAll() async {
    loading.value = true;

    // ------------------------------------------------------------
    // 1) CPU / GPU Utilization
    // ------------------------------------------------------------
    try {
      final metricData = await _api.getServerMetrics();

      cpuError.value = null;
      gpuError.value = null;

      final cpu = (metricData['cpu_utilization'] ?? 0).toDouble();

      final gpuList = metricData['gpu'] as List<dynamic>? ?? [];
      final gpu = gpuList.isNotEmpty ? (gpuList.first['gpu_util'] ?? 0).toDouble() : 0.0;

      final prev = metrics.value;

      metrics.value = ServerMetrics(
        cpuUsage: cpu,
        ramUsage: prev.ramUsage,
        gpuUtilization: gpu,
        gpuVram: prev.gpuVram,
        models: prev.models,
      );
    } catch (e) {
      cpuError.value = "CPU Error: $e";
      gpuError.value = "GPU Error: $e";
    }

    // ------------------------------------------------------------
    // 2) VRAM / RAM 시계열
    // ------------------------------------------------------------
    try {
      final tsData = await _api.getServerTimeSeries();

      vramError.value = null;
      ramError.value = null;

      List<dynamic> _safeList(Map src, String key) {
        final v = src[key];
        if (v is List && v.isNotEmpty) return v;
        throw "Missing or empty '$key' field in timeseries response";
      }

      // -------------------------
      // 🔥 VRAM (timestamp + index 기반)
      // -------------------------
      final vramNode = _safeList(tsData, 'vram');
      final vramValues = vramNode.first['values'] as List<dynamic>? ?? [];

      gpuVramTimestamps.assignAll(vramValues.map((v) => DateTime.parse(v['ts'])).toList());

      gpuVramSeries.assignAll(
        List.generate(vramValues.length, (i) {
          final y = (vramValues[i]['value'] ?? 0).toDouble();
          return FlSpot(i.toDouble(), y);
        }),
      );

      // -------------------------
      // 🔥 RAM (timestamp + index 기반)
      // -------------------------
      final ramNode = _safeList(tsData, 'ram');
      final ramValues = ramNode.first['values'] as List<dynamic>? ?? [];

      ramTimestamps.assignAll(ramValues.map((v) => DateTime.parse(v['ts'])).toList());

      ramSeries.assignAll(
        List.generate(ramValues.length, (i) {
          final y = (ramValues[i]['value'] ?? 0).toDouble();
          return FlSpot(i.toDouble(), y);
        }),
      );

      // snapshot 업데이트
      final prev = metrics.value;
      metrics.value = ServerMetrics(
        cpuUsage: prev.cpuUsage,
        gpuUtilization: prev.gpuUtilization,
        ramUsage: ramSeries.isNotEmpty ? ramSeries.last.y : prev.ramUsage,
        gpuVram: gpuVramSeries.isNotEmpty ? gpuVramSeries.last.y : prev.gpuVram,
        models: prev.models,
      );
    } catch (e) {
      vramError.value = "VRAM Error: $e";
      ramError.value = "RAM Error: $e";
    }

    loading.value = false;
  }
}
