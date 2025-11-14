import 'package:get/get.dart';
import 'package:triton/widgets/dashboard/model_metrics.dart';

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
  }

  // ============================================================
  // 🔥 fetchAll(modelName) → inference/latency/notifications 로딩
  // ============================================================
  Future<void> fetchAll(String modelName) async {
    loading.value = true;

    await Future.wait([_fetchInference(modelName), _fetchLatency(modelName), _fetchNotifications(modelName)]);

    loading.value = false;
  }

  // ============================================================
  // 🔹 Inference Fetch
  // ============================================================
  Future<void> _fetchInference(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final key = modelName.trim().toLowerCase();

    late InferenceStats stats;

    if (key == "model1") {
      stats = InferenceStats(total: 100, success: 95, fail: 5);
    } else if (key == "model2") {
      stats = InferenceStats(total: 60, success: 45, fail: 15);
    } else if (key == "ensemble1") {
      stats = InferenceStats(total: 120, success: 102, fail: 18);
    } else {
      stats = InferenceStats(total: 50, success: 45, fail: 5);
    }

    _applyInference(stats);
  }

  // ============================================================
  // 🔹 Latency Fetch
  // ============================================================
  Future<void> _fetchLatency(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final key = modelName.trim().toLowerCase();

    late LatencyStats latency;

    if (key == "model1") {
      latency = LatencyStats(
        queue: [10, 12, 14, 16, 18],
        input: [30, 28, 25, 22, 20],
        infer: [80, 76, 72, 70, 68],
        output: [12, 11, 10, 9, 8],
      );
    } else if (key == "model2") {
      latency = LatencyStats(
        queue: [20, 22, 24, 26, 28],
        input: [40, 38, 36, 34, 32],
        infer: [120, 118, 115, 112, 110],
        output: [20, 19, 18, 17, 16],
      );
    } else if (key == "ensemble1") {
      latency = LatencyStats(
        queue: [25, 27, 29, 30, 33],
        input: [45, 43, 40, 38, 35],
        infer: [130, 128, 124, 120, 118],
        output: [22, 21, 20, 19, 18],
      );
    } else {
      latency = LatencyStats(
        queue: [15, 17, 20, 23, 25],
        input: [35, 33, 30, 28, 25],
        infer: [110, 108, 105, 102, 100],
        output: [18, 17, 16, 15, 14],
      );
    }

    _applyLatency(latency);
  }

  // ============================================================
  // 🔹 Notifications Fetch
  // ============================================================
  Future<void> _fetchNotifications(String modelName) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final key = modelName.trim().toLowerCase();

    late List<NotificationLog> list;

    if (key == "model1") {
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
    } else if (key == "model2") {
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
    } else if (key == "ensemble1") {
      list = [
        NotificationLog(
          level: "INFO",
          message: "Ensemble1: Loaded model group",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
        ),
        NotificationLog(
          level: "WARN",
          message: "Ensemble1: Sync latency increased",
          timestamp: DateTime.now().subtract(const Duration(minutes: 6)).toIso8601String(),
        ),
        NotificationLog(
          level: "ERROR",
          message: "Ensemble1: Sub-model timeout",
          timestamp: DateTime.now().subtract(const Duration(minutes: 14)).toIso8601String(),
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
  // Apply Methods
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
