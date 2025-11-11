import 'package:get/get.dart';
import 'package:triton/model/dashboard/server_metrics.dart';

/// [ServerCudaController]
/// - CUDA 및 GPU 연산 관련 지표(SM Util, Tensor Core Util, FP32, Throughput) 관리
/// - 추후 Triton API 연동 시 `/server/cuda` endpoint로 교체 예정
class ServerCudaController extends GetxController {
  /// 현재 CUDA 지표 데이터
  final metrics = ServerMetrics.mock.obs;

  /// 로딩 상태
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 초기 데이터 세팅
    fetch();
  }

  /// ✅ 임시 fetch() (mock 기반)
  /// - BE 연동 전 단계에서는 랜덤 수치로 변동 시뮬레이션
  Future<void> fetch() async {
    loading.value = true;

    await Future.delayed(const Duration(milliseconds: 300));

    final current = metrics.value;
    final updated = ServerMetrics(
      smUtil: (current.smUtil + 5) % 100,
      tensorCoreUtil: (current.tensorCoreUtil + 3) % 100,
      fp32Util: (current.fp32Util + 4) % 100,
      inferenceThroughput: (current.inferenceThroughput + 10) % 400,
      gpuVram: current.gpuVram,
      cpuUsage: current.cpuUsage,
      ramUsage: current.ramUsage,
    );

    metrics.value = updated;
    loading.value = false;
  }
}
