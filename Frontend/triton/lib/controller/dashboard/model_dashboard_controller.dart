import 'package:get/get.dart';
import 'package:triton/widgets/dashboard/model_metrics.dart';

/// ===================================================================
///  ModelDashboardController
///  - 기존 3개 컨트롤러(Inference / Latency / Notifications) 통합 버전
///  - DashboardController에서 model 변경 시 → fetchAll(modelName) 호출
/// ===================================================================
class ModelDashboardController extends GetxController {
  // ============================================================
  // 🔹 1) Inference Stats
  // ============================================================

  RxInt totalRequests = 0.obs;
  RxInt successRequests = 0.obs;
  RxInt failRequests = 0.obs;

  RxInt totalInference = 0.obs;
  RxInt successInference = 0.obs;
  RxInt failInference = 0.obs;

  double get requestPercent {
    if (totalRequests.value == 0) return 0;
    return (successRequests.value / totalRequests.value) * 100;
  }

  double get inferencePercent {
    if (totalInference.value == 0) return 0;
    return (successInference.value / totalInference.value) * 100;
  }

  // ============================================================
  // 🔹 2) Latency Stats
  // ============================================================

  RxList<double> queueLatency = <double>[].obs;
  RxList<double> inputLatency = <double>[].obs;
  RxList<double> inferLatency = <double>[].obs;
  RxList<double> outputLatency = <double>[].obs;

  // ============================================================
  // 🔹 3) Notifications
  // ============================================================

  RxList<NotificationLog> notifications = <NotificationLog>[].obs;

  // ============================================================
  // 🔹 4) 로딩 상태
  // ============================================================
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 자동 fetch 없음 (DashboardController에서 modelName 전달해야 함)
  }

  // ============================================================
  // 🔥 fetchAll(modelName) → inference/latency/notification 통합 로딩
  // ============================================================
  Future<void> fetchAll(String modelName) async {
    loading.value = true;

    await Future.wait([_fetchInference(modelName), _fetchLatency(modelName), _fetchNotifications(modelName)]);

    loading.value = false;
  }

  // ============================================================
  // 🔹 fetch 부분: 기존 컨트롤러의 mock 데이터 그대로 사용
  // ============================================================

  Future<void> _fetchInference(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 200));

    late ModelMetrics mockMetrics;

    if (modelName == "model1") {
      mockMetrics = ModelMetrics(
        inference: InferenceStats(total: 100, success: 95, fail: 5),
        latency: LatencyStats(queue: [10, 15, 20], input: [30, 25, 20], infer: [80, 75, 70], output: [10, 12, 15]),
        notifications: [],
      );
    } else if (modelName == "model2") {
      mockMetrics = ModelMetrics(
        inference: InferenceStats(total: 60, success: 45, fail: 15),
        latency: LatencyStats(queue: [20, 25, 30], input: [40, 35, 30], infer: [120, 110, 105], output: [20, 18, 15]),
        notifications: [],
      );
    } else {
      mockMetrics = ModelMetrics(
        inference: InferenceStats(total: 50, success: 45, fail: 5),
        latency: LatencyStats(queue: [20, 25, 15], input: [40, 30, 20], infer: [120, 100, 110], output: [25, 20, 15]),
        notifications: [],
      );
    }

    _applyInference(mockMetrics.inference);
  }

  Future<void> _fetchLatency(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 250));

    late LatencyStats latency;

    if (modelName == "model1") {
      latency = LatencyStats(
        queue: [10, 12, 14, 15],
        input: [30, 28, 25, 20],
        infer: [80, 76, 70, 75],
        output: [12, 10, 9, 11],
      );
    } else if (modelName == "model2") {
      latency = LatencyStats(
        queue: [20, 25, 22, 27],
        input: [40, 38, 36, 33],
        infer: [120, 115, 110, 112],
        output: [25, 22, 20, 18],
      );
    } else {
      latency = LatencyStats(queue: [20, 25, 15], input: [40, 30, 20], infer: [120, 100, 110], output: [25, 20, 15]);
    }

    _applyLatency(latency);
  }

  Future<void> _fetchNotifications(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 200));

    late List<NotificationLog> list;

    if (modelName == "model1") {
      list = [
        NotificationLog(
          level: "INFO",
          message: "Model1: Warmup completed",
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)).toIso8601String(),
        ),
        NotificationLog(
          level: "WARN",
          message: "Model1: Queue spike detected",
          timestamp: DateTime.now().subtract(const Duration(minutes: 7)).toIso8601String(),
        ),
        NotificationLog(
          level: "ERROR",
          message: "Model1: Tensor RT failure",
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)).toIso8601String(),
        ),
      ];
    } else if (modelName == "model2") {
      list = [
        NotificationLog(
          level: "INFO",
          message: "Model2: Running optimized path",
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
        ),
        NotificationLog(
          level: "WARN",
          message: "Model2: VRAM usage high",
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        ),
        NotificationLog(
          level: "INFO",
          message: "Model2: Batch size tuned",
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
        ),
      ];
    } else {
      list = [
        NotificationLog(
          level: "INFO",
          message: "Model default loaded",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
        ),
        NotificationLog(
          level: "WARN",
          message: "Model queue latency increased",
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        ),
        NotificationLog(
          level: "ERROR",
          message: "Model inference timeout",
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        ),
      ];
    }

    notifications.value = list;
  }

  // ============================================================
  // 🔹 내부 Apply 메서드
  // ============================================================

  void _applyInference(InferenceStats stats) {
    totalRequests.value = stats.total;
    successRequests.value = stats.success;
    failRequests.value = stats.fail;

    totalInference.value = stats.total;
    successInference.value = stats.success;
    failInference.value = stats.fail;
  }

  void _applyLatency(LatencyStats stats) {
    queueLatency.value = List<double>.from(stats.queue);
    inputLatency.value = List<double>.from(stats.input);
    inferLatency.value = List<double>.from(stats.infer);
    outputLatency.value = List<double>.from(stats.output);
  }
}
