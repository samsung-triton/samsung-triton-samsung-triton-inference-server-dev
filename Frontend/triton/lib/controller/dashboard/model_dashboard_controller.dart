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
  // 🔹 2) Latency Stats (dummy 유지 → 다음 브랜치)
  // ============================================================
  RxList<double> queueLatency = <double>[].obs;
  RxList<double> inputLatency = <double>[].obs;
  RxList<double> inferLatency = <double>[].obs;
  RxList<double> outputLatency = <double>[].obs;

  // ============================================================
  // 🔹 3) Notifications (dummy 유지 → 다음 브랜치)
  // ============================================================
  RxList<NotificationLog> notifications = <NotificationLog>[].obs;

  // ============================================================
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  // ============================================================
  // 🔥 fetchAll(modelName) → 지금은 Inference Stats만 실제 API로 호출
  // ============================================================
  Future<void> fetchAll(String modelName) async {
    loading.value = true;

    // 🔥 1) Inference Stats만 실제 API 연동
    await _fetchInference(modelName);

    // 🔥 2) 나머지는 dummy 유지
    await Future.wait([_fetchLatency(modelName), _fetchNotifications(modelName)]);

    loading.value = false;
  }

  // ============================================================
  // 🔥 Inference Fetch (실제 API 연동)
  // ============================================================
  Future<void> _fetchInference(String modelName) async {
    try {
      // 지금 DashboardController가 modelId를 전달했기 때문에 modelName = "3" 같은 값이 들어옴
      final id = int.tryParse(modelName);
      if (id == null) throw "Invalid model id: $modelName";

      // API 호출
      final data = await _api.getDashboardModelStats(id);

      // API 응답 구조:
      // {
      //   request_total,
      //   request_success,
      //   request_fail,
      //   inference_total,
      //   inference_ok,
      //   inference_ng,
      //   inference_error
      // }

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
  // 🔹 Latency Fetch (dummy)
  // ============================================================
  Future<void> _fetchLatency(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 120));

    queueLatency.value = [10, 20, 30];
    inputLatency.value = [20, 15, 10];
    inferLatency.value = [100, 120, 140];
    outputLatency.value = [5, 7, 8];
  }

  // ============================================================
  // 🔹 Notifications Fetch (dummy)
  // ============================================================
  Future<void> _fetchNotifications(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 120));

    notifications.value = [
      NotificationLog(level: "INFO", message: "Dummy notification", timestamp: DateTime.now().toIso8601String()),
    ];
  }

  // ============================================================
  // Apply Methods (실제 값이 여기로 저장됨)
  // ============================================================
}
