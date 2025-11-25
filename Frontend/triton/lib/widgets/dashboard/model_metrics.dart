// lib/models/model_metrics.dart
//
// ⚠️ 현재 SSE 대시보드에서는 사용되지 않는 Legacy DTO입니다.
//    필요 없으면 파일 삭제 가능합니다.
//

/// ===============================================
/// 🔹 Inference 통계 DTO
/// ===============================================
class InferenceStats {
  final int total;
  final int success;
  final int fail;

  double get successRate => total == 0 ? 0 : (success / total) * 100;

  InferenceStats({required this.total, required this.success, required this.fail});

  factory InferenceStats.fromJson(Map<String, dynamic> json) {
    return InferenceStats(total: json['total'] ?? 0, success: json['success'] ?? 0, fail: json['fail'] ?? 0);
  }
}

/// ===============================================
/// 🔹 Latency 통계 DTO
/// ===============================================
class LatencyStats {
  final List<double> queue;
  final List<double> input;
  final List<double> infer;
  final List<double> output;

  LatencyStats({required this.queue, required this.input, required this.infer, required this.output});

  factory LatencyStats.fromJson(Map<String, dynamic> json) {
    return LatencyStats(
      queue: (json['queue'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      input: (json['input'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      infer: (json['infer'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      output: (json['output'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
    );
  }
}
