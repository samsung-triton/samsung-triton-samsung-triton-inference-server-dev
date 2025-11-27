// 서버 대시보드 컨트롤러

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:triton/utils/api_client.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';

class ServerDashboardController extends GetxController {
  // 현재 서버 스냅샷
  final metrics = ServerMetrics(cpuUsage: 0, ramUsage: 0, gpuUtilization: 0, gpuVram: 0, models: const []).obs;

  // VRAM / RAM 시간 시리즈
  final gpuVramSeries = <FlSpot>[].obs;
  final ramSeries = <FlSpot>[].obs;

  // 타임스탬프
  final gpuVramTimestamps = <DateTime>[].obs;
  final ramTimestamps = <DateTime>[].obs;

  // 에러 상태
  final cpuError = RxnString();
  final gpuError = RxnString();
  final vramError = RxnString();
  final ramError = RxnString();

  // SSE 구독
  StreamSubscription<String>? _metricsSub;
  StreamSubscription<String>? _timeseriesSub;

  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();

    // 초기 SSE 시작
    restartSse();
  }

  // SSE 재시작
  void restartSse() {
    _metricsSub?.cancel();
    _timeseriesSub?.cancel();

    _startMetricsSse();
    _startTimeseriesSse();
  }

  // 서버 메트릭 SSE
  void _startMetricsSse() {
    _metricsSub = _api.listenServerMetrics().listen((raw) {
      try {
        final json = jsonDecode(raw);
        final data = json['data'];
        if (data == null) return;

        cpuError.value = null;
        gpuError.value = null;

        // CPU
        final cpu = (data['cpu_utilization'] ?? 0).toDouble();

        // GPU Utilization (단일 GPU 기준)
        final gpuList = data['gpu'] as List? ?? [];
        final gpuUtil = gpuList.isNotEmpty ? (gpuList.first['gpu_util'] ?? 0).toDouble() : 0.0;

        final prev = metrics.value;

        // 스냅샷 갱신
        metrics.value = ServerMetrics(
          cpuUsage: cpu,
          ramUsage: prev.ramUsage,
          gpuUtilization: gpuUtil,
          gpuVram: prev.gpuVram,
          models: prev.models,
        );
      } catch (e) {
        cpuError.value = "CPU Error: $e";
        gpuError.value = "GPU Error: $e";
      }
    });
  }

  // VRAM / RAM 시간 시리즈 SSE
  void _startTimeseriesSse() {
    _timeseriesSub = _api.listenServerTimeSeries().listen((raw) {
      try {
        final json = jsonDecode(raw);
        final data = json['data'];
        if (data == null) return;

        vramError.value = null;
        ramError.value = null;

        // ---- VRAM ----
        final vramList = data['vram'];
        if (vramList is! List || vramList.isEmpty || vramList.first is! Map) {
          vramError.value = "Invalid vram format";
          return;
        }

        final vramValues = vramList.first['values'];
        if (vramValues is! List) {
          vramError.value = "Invalid vram.values";
          return;
        }

        gpuVramTimestamps.assignAll(vramValues.map((v) => DateTime.parse(v['ts'])).toList());

        gpuVramSeries.assignAll(
          List.generate(vramValues.length, (i) => FlSpot(i.toDouble(), (vramValues[i]['value'] ?? 0).toDouble())),
        );

        // ---- RAM ----
        final ramList = data['ram'];
        if (ramList is! List || ramList.isEmpty || ramList.first is! Map) {
          ramError.value = "Invalid ram format";
          return;
        }

        final ramValues = ramList.first['values'];
        if (ramValues is! List) {
          ramError.value = "Invalid ram.values";
          return;
        }

        ramTimestamps.assignAll(ramValues.map((v) => DateTime.parse(v['ts'])).toList());

        ramSeries.assignAll(
          List.generate(ramValues.length, (i) => FlSpot(i.toDouble(), (ramValues[i]['value'] ?? 0).toDouble())),
        );

        // 스냅샷 갱신
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
    });
  }

  @override
  void onClose() {
    _metricsSub?.cancel();
    _timeseriesSub?.cancel();
    super.onClose();
  }

  // 최신 메트릭 getter
  double get latestCpuUsage => metrics.value.cpuUsage;
  double get latestGpuUtil => metrics.value.gpuUtilization;
  double get latestGpuVram => gpuVramSeries.isNotEmpty ? gpuVramSeries.last.y : metrics.value.gpuVram;
  double get latestRamUsage => ramSeries.isNotEmpty ? ramSeries.last.y : metrics.value.ramUsage;
}
