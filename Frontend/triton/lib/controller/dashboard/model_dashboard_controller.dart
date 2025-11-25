// lib/controller/dashboard/model_dashboard_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';

/// 서버 알림 DTO
class ServerNotificationItem {
  final DateTime ts;
  final String level;
  final String message;

  ServerNotificationItem({required this.ts, required this.level, required this.message});

  factory ServerNotificationItem.fromJson(Map<String, dynamic> json) {
    return ServerNotificationItem(
      ts: DateTime.parse(json['ts']),
      level: json['level'],
      message: json['error_message'] ?? '',
    );
  }
}

/// Model Dashboard Controller (SSE 기반)
class ModelDashboardController extends GetxController {
  late final ApiClient _api;

  // -----------------------------
  // Inference Stats
  // -----------------------------
  RxInt totalRequests = 0.obs;
  RxInt successRequests = 0.obs;
  RxInt failRequests = 0.obs;

  RxInt totalInference = 0.obs;
  RxInt successInference = 0.obs;
  RxInt failInference = 0.obs;

  double get requestPercent => totalRequests.value == 0 ? 0 : (successRequests.value / totalRequests.value) * 100;

  double get inferencePercent => totalInference.value == 0 ? 0 : (successInference.value / totalInference.value) * 100;

  // -----------------------------
  // Latency Stats
  // -----------------------------
  RxList<double> queueLatency = <double>[].obs;
  RxList<double> inputLatency = <double>[].obs;
  RxList<double> inferLatency = <double>[].obs;
  RxList<double> outputLatency = <double>[].obs;

  RxList<DateTime> latencyTimestamps = <DateTime>[].obs;

  // -----------------------------
  // Server Notifications (SSE 기반)
  // -----------------------------
  RxList<ServerNotificationItem> serverNotifications = <ServerNotificationItem>[].obs;

  // -----------------------------
  // SSE Subscriptions
  // -----------------------------
  StreamSubscription<String>? _statsSub;
  StreamSubscription<String>? _latencySub;
  StreamSubscription<String>? _notiSub;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  // ---------------------------------------------------------
  // SSE 재연결 (DashboardController에서 호출)
  // ---------------------------------------------------------
  void restartSse(int modelId) {
    _statsSub?.cancel();
    _latencySub?.cancel();
    _notiSub?.cancel();

    _startStatsSse(modelId);
    _startLatencySse(modelId);
    _startNotificationSse();
  }

  // ---------------------------------------------------------
  // Stats SSE
  // ---------------------------------------------------------
  void _startStatsSse(int modelId) {
    _statsSub = _api.listenModelStats(modelId).listen((raw) {
      try {
        final json = jsonDecode(raw);
        final data = json['data'];
        if (data == null) return;

        totalRequests.value = data['request_total'] ?? 0;
        successRequests.value = data['request_success'] ?? 0;
        failRequests.value = data['request_fail'] ?? 0;

        totalInference.value = data['inference_total'] ?? 0;
        successInference.value = data['inference_ok'] ?? 0;
        failInference.value = (data['inference_ng'] ?? 0) + (data['inference_error'] ?? 0);
      } catch (_) {}
    });
  }

  // ---------------------------------------------------------
  // Latency SSE
  // ---------------------------------------------------------
  void _startLatencySse(int modelId) {
    _latencySub = _api.listenModelLatency(modelId).listen((raw) {
      try {
        final json = jsonDecode(raw);
        final data = json['data'];
        if (data == null) return;

        final latency = data['latency'];
        if (latency == null || latency is! Map) return;

        List<double> _parseValues(dynamic node) {
          if (node is! List || node.isEmpty || node.first is! Map) return [];
          final values = node.first['values'];
          if (values is! List) return [];
          return values.map<double>((e) => (e['value'] as num?)?.toDouble() ?? 0.0).toList();
        }

        List<DateTime> _parseTimestamps(dynamic node) {
          if (node is! List || node.isEmpty || node.first is! Map) return [];
          final values = node.first['values'];
          if (values is! List) return [];
          return values.map<DateTime>((e) => DateTime.parse(e['ts'])).toList();
        }

        queueLatency.value = _parseValues(latency['queue']);
        inputLatency.value = _parseValues(latency['input']);
        inferLatency.value = _parseValues(latency['infer']);
        outputLatency.value = _parseValues(latency['output']);

        latencyTimestamps.value = _parseTimestamps(latency['queue']);
      } catch (_) {}
    });
  }

  // ---------------------------------------------------------
  // Notification SSE
  // ---------------------------------------------------------
  void _startNotificationSse() {
    _notiSub = _api.listenModelNotification().listen((raw) {
      try {
        final json = jsonDecode(raw);

        final data = json['data'];
        if (data == null) return;

        // Heartbeat
        if (data['heartbeat'] == true) return;

        // History
        if (data['history'] != null) {
          final list = (data['history'] as List).map((e) => ServerNotificationItem.fromJson(e)).toList();

          serverNotifications.assignAll(list);
        }
      } catch (_) {
        // silent fail
      }
    });
  }

  @override
  void onClose() {
    _statsSub?.cancel();
    _latencySub?.cancel();
    _notiSub?.cancel();
    super.onClose();
  }
}
