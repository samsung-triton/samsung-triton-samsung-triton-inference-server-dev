import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:triton/controller/dashboard/server_cpu_controller.dart';
import 'package:triton/controller/dashboard/server_gpu_controller.dart';
import 'package:triton/controller/dashboard/server_cuda_controller.dart';
import 'package:triton/controller/dashboard/server_ram_controller.dart';

/// 대시보드 타입 (서버 / 모델)
enum DashboardType { server, model, ensemble }

/// 중앙 통합 컨트롤러
/// - 하위 서버/모델 컨트롤러를 통합 관리
/// - 60초마다 자동 fetch
/// - 상단 헤더에서 Last Updated 시간 표시
class DashboardController extends GetxController {
  /// 현재 선택된 대시보드 유형
  final selectedType = DashboardType.server.obs;
  final selectedItem = ''.obs; // ← 추가됨

  /// 마지막 갱신 시각
  final lastUpdated = Rxn<DateTime>();

  /// 60초 주기 타이머
  Timer? _timer;

  /// 하위 컨트롤러 참조
  late final ServerCudaController cudaController;
  late final ServerCpuController cpuController;
  late final ServerGpuController gpuController;
  late final ServerRamController ramController;

  @override
  void onInit() {
    super.onInit();

    // ✅ 등록 안 되어 있으면 직접 등록 (중복 방지)
    if (!Get.isRegistered<ServerCudaController>()) {
      Get.lazyPut(() => ServerCudaController(), fenix: true);
    }
    if (!Get.isRegistered<ServerCpuController>()) {
      Get.lazyPut(() => ServerCpuController(), fenix: true);
    }
    if (!Get.isRegistered<ServerGpuController>()) {
      Get.lazyPut(() => ServerGpuController(), fenix: true);
    }
    if (!Get.isRegistered<ServerRamController>()) {
      Get.lazyPut(() => ServerRamController(), fenix: true);
    }

    // ✅ 안전하게 컨트롤러 가져오기
    cudaController = Get.find<ServerCudaController>();
    cpuController = Get.find<ServerCpuController>();
    gpuController = Get.find<ServerGpuController>();
    ramController = Get.find<ServerRamController>();

    // ✅ 초기 1회 fetch
    _fetchCurrentGroup();

    // ✅ 60초 주기 자동 갱신
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchCurrentGroup();
    });
  }

  /// 서버/모델 전환
  void changeType(DashboardType type, {String? item}) {
    selectedType.value = type;
    if (item != null) {
      selectedItem.value = item;
    } else {
      selectedItem.value = '';
    }
    _fetchCurrentGroup();
  }

  /// 현재 선택된 타입의 하위 컨트롤러들 fetch
  Future<void> _fetchCurrentGroup() async {
    switch (selectedType.value) {
      case DashboardType.server:
        await Future.wait([
          cudaController.fetch(),
          cpuController.fetch(),
          gpuController.fetch(),
          ramController.fetch(),
        ]);
        break;

      case DashboardType.model:
        // TODO: Model 관련 컨트롤러 fetch 추가 예정
        break;
      case DashboardType.ensemble:
        // TODO: Ensemble 관련 컨트롤러 fetch 추가 예정
        break;
    }

    // ✅ 공통 갱신 시간 업데이트
    lastUpdated.value = DateTime.now();
  }

  /// UI 표시에 사용할 포맷 문자열
  String get formattedLastUpdated {
    final t = lastUpdated.value;
    if (t == null) return '-';
    return DateFormat('MMM d, yyyy • hh:mm a').format(t);
  }

  /// ✅ 즉시 수동 업데이트 (Update 버튼 클릭 시)
  Future<void> manualUpdate() async {
    await _fetchCurrentGroup();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
