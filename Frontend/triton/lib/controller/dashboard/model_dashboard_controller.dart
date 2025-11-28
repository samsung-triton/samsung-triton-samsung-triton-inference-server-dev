// 모델 대시보드 컨트롤러

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';

// 서버 알림 DTO
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

class ModelDashboardController extends GetxController {
  late final ApiClient _api;

  // 요청 / 추론 통계
  RxInt totalRequests = 0.obs;
  RxInt successRequests = 0.obs;
  RxInt failRequests = 0.obs;

  RxInt totalInference = 0.obs;
  RxInt successInference = 0.obs;
  RxInt failInference = 0.obs;

  // 요청 성공률(%)
  double get requestPercent => totalRequests.value == 0 ? 0 : (successRequests.value / totalRequests.value) * 100;

  // 추론 성공률(%)
  double get inferencePercent => totalInference.value == 0 ? 0 : (successInference.value / totalInference.value) * 100;

  // 지연 시간 데이터
  RxList<double> queueLatency = <double>[].obs;
  RxList<double> inputLatency = <double>[].obs;
  RxList<double> inferLatency = <double>[].obs;
  RxList<double> outputLatency = <double>[].obs;
  RxList<DateTime> latencyTimestamps = <DateTime>[].obs;

  // 서버 알림 리스트
  RxList<ServerNotificationItem> serverNotifications = <ServerNotificationItem>[].obs;

  // SSE 구독 핸들
  StreamSubscription<String>? _statsSub;
  StreamSubscription<String>? _latencySub;
  StreamSubscription<String>? _notiSub;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  // SSE 중단
  void stopSse() {
    _statsSub?.cancel();
    _latencySub?.cancel();
    _notiSub?.cancel();
  }

  // SSE 재연결
  void restartSse(int modelId) {
    stopSse();
    _startStatsSse(modelId);
    _startLatencySse(modelId);
    _startNotificationSse();
  }

  // 모델 통계 SSE
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

  // 레이턴시 SSE
  void _startLatencySse(int modelId) {
    _latencySub = _api.listenModelLatency(modelId).listen((raw) {
      try {
        final json = jsonDecode(raw);
        final data = json['data'];
        if (data == null) return;

        final latency = data['latency'];
        if (latency == null || latency is! Map) return;

        List<double> parseValues(dynamic node) {
          if (node is! List || node.isEmpty || node.first is! Map) return [];
          final values = node.first['values'];
          if (values is! List) return [];
          return values.map<double>((e) => (e['value'] as num?)?.toDouble() ?? 0.0).toList();
        }

        List<DateTime> parseTimestamps(dynamic node) {
          if (node is! List || node.isEmpty || node.first is! Map) return [];
          final values = node.first['values'];
          if (values is! List) return [];
          return values.map<DateTime>((e) => DateTime.parse(e['ts'])).toList();
        }

        queueLatency.value = parseValues(latency['queue']);
        inputLatency.value = parseValues(latency['input']);
        inferLatency.value = parseValues(latency['infer']);
        outputLatency.value = parseValues(latency['output']);

        latencyTimestamps.value = parseTimestamps(latency['queue']);
      } catch (_) {}
    });
  }

  // 알림 SSE
  void _startNotificationSse() {
    _notiSub = _api.listenModelNotification().listen((raw) {
      try {
        String clean = raw.trim();
        if (clean.startsWith("data:")) clean = clean.substring(5).trim();

        final json = jsonDecode(clean);
        final data = json['data'];
        if (data == null) return;

        if (data['heartbeat'] == true) return;

        if (data['history'] != null) {
          final list = (data['history'] as List).map((e) => ServerNotificationItem.fromJson(e)).toList();
          serverNotifications.assignAll(list);
          return;
        }

        if (data['ts'] != null) {
          final item = ServerNotificationItem.fromJson(data);
          serverNotifications.insert(0, item);
          return;
        }
      } catch (_) {}
    });
  }

  @override
  void onClose() {
    stopSse();
    super.onClose();
  }
}
