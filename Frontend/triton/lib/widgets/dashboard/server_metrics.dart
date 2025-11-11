import 'package:fl_chart/fl_chart.dart';

class ServerMetrics {
  final double smUtil;
  final double tensorCoreUtil;
  final double fp32Util;
  final int inferenceThroughput;
  final double gpuVram;
  final double cpuUsage;
  final double ramUsage;

  const ServerMetrics({
    required this.smUtil,
    required this.tensorCoreUtil,
    required this.fp32Util,
    required this.inferenceThroughput,
    required this.gpuVram,
    required this.cpuUsage,
    required this.ramUsage,
  });

  static const mock = ServerMetrics(
    smUtil: 74,
    tensorCoreUtil: 45,
    fp32Util: 63,
    inferenceThroughput: 214,
    gpuVram: 58,
    cpuUsage: 53,
    ramUsage: 45,
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
