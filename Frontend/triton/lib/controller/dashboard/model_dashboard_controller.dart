import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/widgets/dashboard/model_metrics.dart';

class ModelDashboardController extends GetxController {
  late final ApiClient _api;

  // ============================================================
  // 🔹 1) Inference Stats (API 결과 저장)
  // ============================================================
  RxInt totalRequests = 0.obs;
  RxInt successRequests = 0.obs;
  RxInt failRequests = 0.obs;

  RxInt totalInference = 0.obs;
  RxInt successInference = 0.obs;
  RxInt failInference = 0.obs;

  double get requestPercent => totalRequests.value == 0 ? 0 : (successRequests.value / totalRequests.value) * 100;

  double get inferencePercent => totalInference.value == 0 ? 0 : (successInference.value / totalInference.value) * 100;

  // ============================================================
  // 🔹 2) Latency Stats (API 결과 저장)
  // ============================================================
  RxList<double> queueLatency = <double>[].obs;
  RxList<double> inputLatency = <double>[].obs;
  RxList<double> inferLatency = <double>[].obs;
  RxList<double> outputLatency = <double>[].obs;

  // 타임스탬프 (원하면 ModelLatencyChart에서 활용 가능)
  RxList<DateTime> latencyTimestamps = <DateTime>[].obs;

  // ============================================================
  // 🔹 3) Notifications (dummy 유지 → 다음 브랜치)
  // ============================================================
  RxList<NotificationLog> notifications = <NotificationLog>[].obs;

  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  // ============================================================
  // 🔥 fetchAll(modelId)
  // ============================================================
  // ============================================================
  // 🔥 fetchAll(modelId)
  // ============================================================
  Future<void> fetchAll(int modelId) async {
    loading.value = true;

    await Future.wait([
      _fetchInference(modelId),
      _fetchLatency(modelId),
      _fetchNotifications(modelId), // 아직 dummy
    ]);

    loading.value = false;
  }

  // ============================================================
  // 🔥 Inference Stats API 연동
  // ============================================================
  Future<void> _fetchInference(int modelId) async {
    try {
      final data = await _api.getDashboardModelStats(modelId);

      totalRequests.value = data['request_total'] ?? 0;
      successRequests.value = data['request_success'] ?? 0;
      failRequests.value = data['request_fail'] ?? 0;

      totalInference.value = data['inference_total'] ?? 0;
      successInference.value = data['inference_ok'] ?? 0;

      failInference.value = (data['inference_ng'] ?? 0) + (data['inference_error'] ?? 0);
    } catch (e) {
      print("❌ Inference Stats API 실패: $e");
    }
  }

  // ============================================================
  // 🔥 Latency API 연동
  // ============================================================
  Future<void> _fetchLatency(int modelId) async {
    try {
      final res = await _api.getDashboardModelLatency(modelId);

      // latency = { queue: [...], input: [...], infer: [...], output: [...] }
      final latency = res['latency'];

      if (latency == null) {
        print("❌ latency 데이터 없음");
        return;
      }

      // 공통 파서: values → List<double>
      List<double> _parseValues(List<dynamic>? list) {
        if (list == null || list.isEmpty) return [];
        final values = list.first['values'] as List?;
        if (values == null) return [];
        return values.map((e) => (e['value'] as num).toDouble()).toList();
      }

      // timestamps도 같이 파싱
      List<DateTime> _parseTimestamps(List<dynamic>? list) {
        if (list == null || list.isEmpty) return [];
        final values = list.first['values'] as List?;
        if (values == null) return [];
        return values.map((e) => DateTime.parse(e['ts'])).toList();
      }

      queueLatency.value = _parseValues(latency['queue']);
      inputLatency.value = _parseValues(latency['input']);
      inferLatency.value = _parseValues(latency['infer']);
      outputLatency.value = _parseValues(latency['output']);

      // timestamps (하나만 사용)
      latencyTimestamps.value = _parseTimestamps(latency['queue']);
    } catch (e) {
      print("❌ Latency API 실패: $e");
    }
  }

  // ============================================================
  // 🔹 Notifications (dummy)
  // ============================================================
  Future<void> _fetchNotifications(int modelId) async {
    await Future.delayed(const Duration(milliseconds: 120));

    notifications.value = [
      NotificationLog(level: "INFO", message: "Dummy notification", timestamp: DateTime.now().toIso8601String()),
    ];
  }
}
