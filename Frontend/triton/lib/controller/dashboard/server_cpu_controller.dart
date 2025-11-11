import 'package:get/get.dart';
import 'package:triton/widgets/dashboard/server_metrics.dart';

class ServerCpuController extends GetxController {
  final metrics = ServerMetrics.mock.obs; // 초기값: mock

  final loading = false.obs;

  Future<void> fetch() async {
    loading.value = true;

    // ⏱ BE 연동 전이므로 mock 데이터를 일정 시간 뒤에 갱신하는 식으로 흉내
    await Future.delayed(const Duration(milliseconds: 400));

    // 랜덤한 CPU 사용률을 mock처럼 업데이트
    final updated = ServerMetrics(
      smUtil: metrics.value.smUtil,
      tensorCoreUtil: metrics.value.tensorCoreUtil,
      fp32Util: metrics.value.fp32Util,
      inferenceThroughput: metrics.value.inferenceThroughput,
      gpuVram: metrics.value.gpuVram,
      cpuUsage: (metrics.value.cpuUsage + 10) % 100, // 간단히 값 변화
      ramUsage: metrics.value.ramUsage,
    );

    metrics.value = updated;
    loading.value = false;
  }
}
