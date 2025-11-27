// 서버 메트릭 스냅샷 데이터 구조

/// 서버 단일 스냅샷(CPU / RAM / GPU / VRAM)
class ServerMetrics {
  // CPU 사용률(%)
  final double cpuUsage;

  // RAM 사용률(%)
  final double ramUsage;

  // GPU Utilization(%)
  final double gpuUtilization;

  // GPU VRAM 사용률(%)
  final double gpuVram;

  // 모델별 추론 스냅샷 리스트
  final List<ModelPerf> models;

  ServerMetrics({
    required this.cpuUsage,
    required this.ramUsage,
    required this.gpuUtilization,
    required this.gpuVram,
    required this.models,
  });
}

/// 모델별 단건 추론 성능 스냅샷
class ModelPerf {
  // 모델 고유 키
  final String key;

  // 모델명
  final String name;

  // 성공 횟수
  final int success;

  // 실패 횟수
  final int fail;

  ModelPerf({required this.key, required this.name, required this.success, required this.fail});

  // 전체 시도 횟수
  int get total => success + fail;

  // 성공 비율(%)
  double get percent => total == 0 ? 0 : (success / total) * 100;

  // 값 일부 변경 후 복제
  ModelPerf copyWith({int? success, int? fail}) {
    return ModelPerf(key: key, name: name, success: success ?? this.success, fail: fail ?? this.fail);
  }
}
