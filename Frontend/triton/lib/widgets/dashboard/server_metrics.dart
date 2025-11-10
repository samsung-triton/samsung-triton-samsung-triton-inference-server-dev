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

  // ✅ 임시 Mock 데이터 (BE 연동 전 테스트용)
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
