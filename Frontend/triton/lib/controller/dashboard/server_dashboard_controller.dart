// lib/controller/dashboard/server_dashboard_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:triton/utils/api_client.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';

class ServerDashboardController extends GetxController {
  // initial snapshot
  final metrics = ServerMetrics(cpuUsage: 0, ramUsage: 0, gpuUtilization: 0, gpuVram: 0, models: const []).obs;

  // Time-series (VRAM / RAM)
  final gpuVramSeries = <FlSpot>[].obs;
  final ramSeries = <FlSpot>[].obs;

  final gpuVramTimestamps = <DateTime>[].obs;
  final ramTimestamps = <DateTime>[].obs;

  // Error states
  final cpuError = RxnString();
  final gpuError = RxnString();
  final vramError = RxnString();
  final ramError = RxnString();

  // Subscriptions
  StreamSubscription<String>? _metricsSub;
  StreamSubscription<String>? _timeseriesSub;

  late final ApiClient _api;

  // ==============================================================
  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    restartSse(); // start SSE immediately
  }

  // ==============================================================
  // SSE 재시작 (server dashboard)
  // ==============================================================
  void restartSse() {
    _metricsSub?.cancel();
    _timeseriesSub?.cancel();

    _startMetricsSse();
    _startTimeseriesSse();
  }

  // ==============================================================
  // 1) METRICS SSE (CPU / GPU Utilization)
  // ==============================================================
  void _startMetricsSse() {
    _metricsSub = _api.listenServerMetrics().listen((raw) {
      try {
        final json = jsonDecode(raw);
        final data = json['data'];
        if (data == null) return;

        cpuError.value = null;
        gpuError.value = null;

        final cpu = (data['cpu_utilization'] ?? 0).toDouble();

        final gpuList = data['gpu'] as List? ?? [];
        final gpuUtil = gpuList.isNotEmpty ? (gpuList.first['gpu_util'] ?? 0).toDouble() : 0.0;

        final prev = metrics.value;

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

  // ==============================================================
  // 2) TIMESERIES SSE (VRAM / RAM)
  // ==============================================================
  void _startTimeseriesSse() {
    _timeseriesSub = _api.listenServerTimeSeries().listen((raw) {
      try {
        final json = jsonDecode(raw);
        final data = json['data'];
        if (data == null) return;

        vramError.value = null;
        ramError.value = null;

        // ---------------- VRAM ----------------
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

        // ---------------- RAM ----------------
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

        // Snapshot 업데이트
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

  // ==============================================================
  @override
  void onClose() {
    _metricsSub?.cancel();
    _timeseriesSub?.cancel();
    super.onClose();
  }

  // ==============================================================
  // COMPUTED SNAPSHOT GETTERS
  // ==============================================================
  double get latestCpuUsage => metrics.value.cpuUsage;
  double get latestGpuUtil => metrics.value.gpuUtilization;
  double get latestGpuVram => gpuVramSeries.isNotEmpty ? gpuVramSeries.last.y : metrics.value.gpuVram;
  double get latestRamUsage => ramSeries.isNotEmpty ? ramSeries.last.y : metrics.value.ramUsage;
}
