// lib/widgets/dashboard/server_metrics.dart

/// Server snapshot metrics (CPU, RAM, GPU)
class ServerMetrics {
  final double cpuUsage;
  final double ramUsage;
  final double gpuUtilization;
  final double gpuVram;

  final List<ModelPerf> models;

  ServerMetrics({
    required this.cpuUsage,
    required this.ramUsage,
    required this.gpuUtilization,
    required this.gpuVram,
    required this.models,
  });
}

/// Per-model inference snapshot
class ModelPerf {
  final String key;
  final String name;
  final int success;
  final int fail;

  ModelPerf({required this.key, required this.name, required this.success, required this.fail});

  int get total => success + fail;

  double get percent => total == 0 ? 0 : (success / total) * 100;

  ModelPerf copyWith({int? success, int? fail}) {
    return ModelPerf(key: key, name: name, success: success ?? this.success, fail: fail ?? this.fail);
  }
}
