import 'package:flutter/foundation.dart';

/// ===============================================
/// 🔹 Inference 통계 DTO
/// ===============================================
///
/// BE 응답 예시:
/// {
///   "total": 50,
///   "success": 45,
///   "fail": 5
/// }
class InferenceStats {
  final int total;
  final int success;
  final int fail;

  double get successRate => total == 0 ? 0 : (success / total) * 100;

  InferenceStats({required this.total, required this.success, required this.fail});

  factory InferenceStats.fromJson(Map<String, dynamic> json) {
    return InferenceStats(total: json["total"] ?? 0, success: json["success"] ?? 0, fail: json["fail"] ?? 0);
  }
}

/// ===============================================
/// 🔹 Latency 통계 DTO
/// ===============================================
///
/// BE 응답 예시:
/// {
///   "queue": [20, 25, 15],
///   "input": [40, 30, 20],
///   "infer": [120, 100, 110],
///   "output": [25, 20, 15]
/// }
class LatencyStats {
  final List<double> queue;
  final List<double> input;
  final List<double> infer;
  final List<double> output;

  LatencyStats({required this.queue, required this.input, required this.infer, required this.output});

  factory LatencyStats.fromJson(Map<String, dynamic> json) {
    return LatencyStats(
      queue: (json["queue"] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      input: (json["input"] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      infer: (json["infer"] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      output: (json["output"] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
    );
  }
}

/// ===============================================
/// 🔹 Notification 로그 DTO
/// ===============================================
///
/// BE 응답 예시:
/// {
///   "level": "WARN",
///   "message": "Inference delayed",
///   "timestamp": "2025-02-17T09:21:00Z"
/// }
class NotificationLog {
  final String level;
  final String message;
  final String timestamp;

  NotificationLog({required this.level, required this.message, required this.timestamp});

  factory NotificationLog.fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      level: json["level"] ?? "INFO",
      message: json["message"] ?? "",
      timestamp: json["timestamp"] ?? "",
    );
  }
}

/// ===============================================
/// 🔹 ModelMetrics (전체 모델 지표 통합)
/// ===============================================
///
/// BE 응답 예시:
/// {
///   "inference": {...},
///   "latency": {...},
///   "notifications": [{...}, {...}]
/// }
class ModelMetrics {
  final InferenceStats inference;
  final LatencyStats latency;
  final List<NotificationLog> notifications;

  ModelMetrics({required this.inference, required this.latency, required this.notifications});

  factory ModelMetrics.fromJson(Map<String, dynamic> json) {
    return ModelMetrics(
      inference: InferenceStats.fromJson(json["inference"] ?? {}),
      latency: LatencyStats.fromJson(json["latency"] ?? {}),
      notifications: (json["notifications"] as List<dynamic>? ?? []).map((e) => NotificationLog.fromJson(e)).toList(),
    );
  }
}
