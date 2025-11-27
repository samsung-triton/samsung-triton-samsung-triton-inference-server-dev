// 대시보드 컨트롤러

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';

import 'package:triton/utils/api_client.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

enum DashboardType { server, model, ensemble }

// 모델 리스트 DTO
class DashboardModelItem {
  final int modelId;
  final String modelName;
  final int inferenceTotal;
  final int inferenceOk;
  final double okRatio;

  DashboardModelItem({
    required this.modelId,
    required this.modelName,
    required this.inferenceTotal,
    required this.inferenceOk,
    required this.okRatio,
  });

  factory DashboardModelItem.fromJson(Map<String, dynamic> json) {
    return DashboardModelItem(
      modelId: json['modelId'],
      modelName: json['modelName'],
      inferenceTotal: json['inference_total'],
      inferenceOk: json['inference_ok'],
      okRatio: (json['ok_ratio'] as num).toDouble(),
    );
  }
}

// SSE 기반 모델 리스트 관리 컨트롤러
class DashboardController extends GetxController {
  // 선택된 탭(server/model)
  final selectedType = DashboardType.server.obs;

  // 선택된 모델 ID
  final selectedModelId = RxnInt();

  // 모델 목록
  final modelList = <DashboardModelItem>[].obs;

  // 마지막 갱신 시간
  final lastUpdated = Rxn<DateTime>();

  // Reset Time
  final resetTime = ''.obs;
  final resetHour = 0.obs;
  final resetMinute = 0.obs;

  late final ApiClient _api;
  final _authStorage = GetStorage('auth');

  // 사용자 역할
  final role = ''.obs;
  bool get isDevel => role.value.toUpperCase() == 'DEVEL';

  // 서버/모델 대시보드 컨트롤러
  late final ServerDashboardController serverCtrl;
  late final ModelDashboardController modelCtrl;

  StreamSubscription<String>? _modelSseSub;

  @override
  void onInit() {
    super.onInit();

    _api = Get.find<ApiClient>();
    role.value = _authStorage.read<String>('role') ?? '';

    // Controller Lazy Load
    if (!Get.isRegistered<ServerDashboardController>()) {
      Get.lazyPut(() => ServerDashboardController(), fenix: true);
    }
    if (!Get.isRegistered<ModelDashboardController>()) {
      Get.lazyPut(() => ModelDashboardController(), fenix: true);
    }

    serverCtrl = Get.find<ServerDashboardController>();
    modelCtrl = Get.find<ModelDashboardController>();

    fetchResetTime();

    // 모델 리스트 SSE 시작
    _startModelListSse();
  }

  // 모델 리스트 SSE 시작
  void _startModelListSse() {
    _modelSseSub = _api.listenDashboardModelList().listen((raw) {
      try {
        final json = jsonDecode(raw);
        final list = json['data']?['models'] as List?;

        // 모델 리스트 업데이트
        if (list != null) {
          modelList.assignAll(list.map((m) => DashboardModelItem.fromJson(m)).toList());
        }

        lastUpdated.value = DateTime.now();
      } catch (_) {}
    });
  }

  // 화면 타입 변경(server/model) -> 해당 SSE 재연결
  void changeType(DashboardType type, {int? modelId}) {
    selectedType.value = type;
    selectedModelId.value = modelId;

    // 서버 패널
    if (type == DashboardType.server) {
      serverCtrl.restartSse();
    }
    // 모델 패널
    else if (type == DashboardType.model && modelId != null) {
      modelCtrl.restartSse(modelId);
    }

    lastUpdated.value = DateTime.now();
  }

  // Reset Time 조회
  Future<void> fetchResetTime() async {
    try {
      final res = await _api.getStandardTime();
      resetTime.value = res['base_time'];

      final parts = resetTime.value.split(':');
      resetHour.value = int.parse(parts[0]);
      resetMinute.value = int.parse(parts[1]);
    } catch (_) {}
  }

  // Reset Time 변경
  Future<void> updateResetTime() async {
    if (!isDevel) return;

    final hh = resetHour.value.toString().padLeft(2, '0');
    final mm = resetMinute.value.toString().padLeft(2, '0');

    try {
      // 오늘 날짜 + 사용자가 입력한 Local 시/분
      final now = DateTime.now();
      final localDateTime = DateTime(now.year, now.month, now.day, int.parse(hh), int.parse(mm));

      // UTC로 변환
      final utc = localDateTime.toUtc();

      // UTC에서 HH:mm 추출
      final utcHH = utc.hour.toString().padLeft(2, '0');
      final utcMM = utc.minute.toString().padLeft(2, '0');

      // BE에 UTC 기준 HH:mm 전송
      final utcHHMM = "$utcHH:$utcMM";

      final res = await _api.updateStandardTime(utcHHMM);

      // 화면 상태 업데이트
      resetTime.value = res['base_time'];
      final p = resetTime.value.split(':');
      resetHour.value = int.parse(p[0]);
      resetMinute.value = int.parse(p[1]);
    } catch (_) {}
  }

  // 패널의 수동 갱신 버튼 → 해당 SSE 재시작
  Future<void> manualUpdate() async {
    await fetchResetTime();

    if (selectedType.value == DashboardType.server) {
      serverCtrl.restartSse();
    } else if (selectedType.value == DashboardType.model && selectedModelId.value != null) {
      modelCtrl.restartSse(selectedModelId.value!);
    }

    lastUpdated.value = DateTime.now();
  }

  @override
  void onClose() {
    _modelSseSub?.cancel();
    super.onClose();
  }

  // 마지막 갱신 시간 표시 포맷
  String get formattedLastUpdated {
    final t = lastUpdated.value;
    if (t == null) return '-';
    return DateFormat('MMM d, yyyy • hh:mm a').format(t);
  }

  // Reset Time - 시 설정
  void setResetHour(String hh) {
    resetHour.value = int.tryParse(hh) ?? 0;
  }

  // Reset Time - 분 설정
  void setResetMinute(String mm) {
    resetMinute.value = int.tryParse(mm) ?? 0;
  }
}
