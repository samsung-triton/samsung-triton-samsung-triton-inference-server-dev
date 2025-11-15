import 'package:fl_chart/fl_chart.dart';

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

  static final mock = ServerMetrics(
    cpuUsage: 30,
    ramUsage: 50,
    gpuUtilization: 40,
    gpuVram: 60,
    models: [
      ModelPerf(key: "model1", name: "Model 1", success: 2720, fail: 174),
      ModelPerf(key: "model2", name: "Model 2", success: 2650, fail: 244),
      ModelPerf(key: "ensemble1", name: "Ensemble 1", success: 2500, fail: 394),
    ],
  );
}

// ✅ GPU VRAM 시계열 Mock 데이터
class ServerGpuMockData {
  static List<FlSpot> get vramUsage => const [
    FlSpot(0, 15),
    FlSpot(3, 35),
    FlSpot(6, 65),
    FlSpot(9, 80),
    FlSpot(12, 55),
    FlSpot(15, 45),
    FlSpot(18, 60),
    FlSpot(21, 75),
  ];
}

// ✅ RAM 시계열 Mock 데이터
class ServerRamMockData {
  static List<FlSpot> get ramUsage => const [
    FlSpot(0, 10),
    FlSpot(3, 25),
    FlSpot(6, 55),
    FlSpot(9, 75),
    FlSpot(12, 45),
    FlSpot(15, 60),
    FlSpot(18, 40),
    FlSpot(21, 70),
  ];
}

class ModelPerf {
  final String key; // "model1"
  final String name; // "Model 1"
  final int success;
  final int fail;

  ModelPerf({required this.key, required this.name, required this.success, required this.fail});

  int get total => success + fail;

  double get percent => total == 0 ? 0 : (success / total) * 100;

  ModelPerf copyWith({int? success, int? fail}) {
    return ModelPerf(key: key, name: name, success: success ?? this.success, fail: fail ?? this.fail);
  }
}
