// lib/controller/dashboard/dashboard_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';

import 'package:triton/utils/api_client.dart';
import 'package:triton/controller/dashboard/server_dashboard_controller.dart';
import 'package:triton/controller/dashboard/model_dashboard_controller.dart';

enum DashboardType { server, model, ensemble }

// ==================================================================
// MODEL LIST DTO
// ==================================================================
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

// ==================================================================
// DASHBOARD CONTROLLER — SSE ONLY
// ==================================================================
class DashboardController extends GetxController {
  final selectedType = DashboardType.server.obs;
  final selectedModelId = RxnInt();

  final modelList = <DashboardModelItem>[].obs;
  final lastUpdated = Rxn<DateTime>();

  final resetTime = ''.obs;
  final resetHour = 0.obs;
  final resetMinute = 0.obs;

  late final ApiClient _api;
  final _authStorage = GetStorage('auth');
  final role = ''.obs;

  bool get isDevel => role.value.toUpperCase() == 'DEVEL';

  late final ServerDashboardController serverCtrl;
  late final ModelDashboardController modelCtrl;

  StreamSubscription<String>? _modelSseSub;

  // ==================================================================
  @override
  void onInit() {
    super.onInit();

    _api = Get.find<ApiClient>();
    role.value = _authStorage.read<String>('role') ?? '';

    // Lazy load
    if (!Get.isRegistered<ServerDashboardController>()) {
      Get.lazyPut(() => ServerDashboardController(), fenix: true);
    }
    if (!Get.isRegistered<ModelDashboardController>()) {
      Get.lazyPut(() => ModelDashboardController(), fenix: true);
    }

    serverCtrl = Get.find<ServerDashboardController>();
    modelCtrl = Get.find<ModelDashboardController>();

    fetchResetTime();
    _startModelListSse();
  }

  // ==================================================================
  // MODEL LIST SSE
  // ==================================================================
  void _startModelListSse() {
    _modelSseSub = _api.listenDashboardModelList().listen((raw) {
      try {
        final json = jsonDecode(raw);
        final list = json['data']?['models'] as List?;

        if (list != null) {
          modelList.assignAll(list.map((m) => DashboardModelItem.fromJson(m)).toList());
        }

        lastUpdated.value = DateTime.now();
      } catch (_) {}
    });
  }

  // ==================================================================
  // Dashboard 화면 전환 → SSE 재연결
  // ==================================================================
  void changeType(DashboardType type, {int? modelId}) {
    selectedType.value = type;
    selectedModelId.value = modelId;

    if (type == DashboardType.server) {
      serverCtrl.restartSse();
    } else if (type == DashboardType.model && modelId != null) {
      modelCtrl.restartSse(modelId);
    }

    lastUpdated.value = DateTime.now();
  }

  // ==================================================================
  // Reset Time
  // ==================================================================
  Future<void> fetchResetTime() async {
    try {
      final res = await _api.getStandardTime();
      resetTime.value = res['base_time'];

      final parts = resetTime.value.split(':');
      resetHour.value = int.parse(parts[0]);
      resetMinute.value = int.parse(parts[1]);
    } catch (_) {}
  }

  Future<void> updateResetTime() async {
    if (!isDevel) return;

    final hh = resetHour.value.toString().padLeft(2, '0');
    final mm = resetMinute.value.toString().padLeft(2, '0');

    try {
      final res = await _api.updateStandardTime("$hh:$mm");

      resetTime.value = res['base_time'];
      final p = resetTime.value.split(':');
      resetHour.value = int.parse(p[0]);
      resetMinute.value = int.parse(p[1]);
    } catch (_) {}
  }

  // ==================================================================
  // 패널의 Update 버튼 → SSE 재시작
  // ==================================================================
  Future<void> manualUpdate() async {
    await fetchResetTime();

    if (selectedType.value == DashboardType.server) {
      serverCtrl.restartSse();
    } else if (selectedType.value == DashboardType.model && selectedModelId.value != null) {
      modelCtrl.restartSse(selectedModelId.value!);
    }

    lastUpdated.value = DateTime.now();
  }

  // ==================================================================
  @override
  void onClose() {
    _modelSseSub?.cancel();
    super.onClose();
  }

  String get formattedLastUpdated {
    final t = lastUpdated.value;
    if (t == null) return '-';
    return DateFormat('MMM d, yyyy • hh:mm a').format(t);
  }

  // ==================================================================
  void setResetHour(String hh) {
    resetHour.value = int.tryParse(hh) ?? 0;
  }

  void setResetMinute(String mm) {
    resetMinute.value = int.tryParse(mm) ?? 0;
  }
}
