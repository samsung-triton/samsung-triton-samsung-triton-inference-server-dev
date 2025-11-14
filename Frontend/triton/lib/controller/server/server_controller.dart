// 헤더 컨트롤러
import 'dart:async';
import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:get_storage/get_storage.dart';

// 서버 상태
class ServerStatus {
  final String status; // 'running' | 'stopped'
  final DateTime? startedAt; // 예: 2025-11-04T15:32:10+09:00
  const ServerStatus({required this.status, required this.startedAt});
}

class ServerController extends GetxController {
  // 상태
  final Rx<ServerStatus?> serverStatus = Rx<ServerStatus?>(null);
  final RxBool isBusy = false.obs;
  final RxString lastError = ''.obs;
  final RxString uptimeHms = '00:00:00'.obs;

  final ApiClient api = Get.put(ApiClient());

  Timer? _tick;

  @override
  void onInit() {
    super.onInit();
    _startUptimeTicker();
    refreshStatus();
  }

  @override
  void onClose() {
    _tick?.cancel();
    super.onClose();
  }

  // 1초마다 시간 업데이트
  void _startUptimeTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _updateUptime());
  }

  // 시간 문자열 갱신
  void _updateUptime() {
    final s = serverStatus.value;

    if (s == null || s.startedAt == null || s.status != 'running') {
      if (uptimeHms.value != 'stopped') uptimeHms.value = 'stopped';
      return;
    }

    final diff = DateTime.now().toUtc().difference(s.startedAt!.toUtc());
    final hh = diff.inHours.toString().padLeft(2, '0');
    final mm = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (diff.inSeconds % 60).toString().padLeft(2, '0');
    final time = '$hh:$mm:$ss';
    if (uptimeHms.value != time) uptimeHms.value = time;
  }

  // 상태 조회
  Future<void> refreshStatus() async {
    try {
      isBusy.value = true;
      lastError.value = '';

      // TODO: 실제 API로 교체
      // final newStatus = await api.fetchStatus(); // ServerStatus 반환
      // serverStatus.value = newStatus;
      // _updateUptime();

      serverStatus.value = const ServerStatus(status: "stopped", startedAt: null);
    } catch (e) {
      lastError.value = '상태 조회 실패: $e';
      serverStatus.value = null;
    } finally {
      isBusy.value = false;
    }
  }

  // 제어: 시작
  Future<void> startServer() async {
    try {
      isBusy.value = true;
      lastError.value = '';

      // 로그인 사용자 ID 불러오기
      final authStorage = GetStorage('auth');
      final userLoginId = authStorage.read('loginedId');

      if (userLoginId == null || userLoginId.isEmpty) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final response = await api.startServer(userLoginId: userLoginId);
      //print('📬 응답 코드: ${response.statusCode}');
      //print('📦 응답 본문: ${response.body}');
      if (response.statusCode == 200) {
        final data = response.body;
        final startedAt = DateTime.tryParse(data['started_at'] ?? data['startedAt'] ?? '');
        serverStatus.value = ServerStatus(status: 'running', startedAt: startedAt ?? DateTime.now());
        //print('✅ 서버 시작 성공, startedAt = ${serverStatus.value?.startedAt}');
      } else {
        throw Exception('서버 시작 실패 (${response.statusCode})');
      }
    } catch (e) {
      lastError.value = '서버 시작 실패: $e';
      print('❌ [startServer] 예외 발생: $e'); //에러 로그 출력
    } finally {
      isBusy.value = false;
    }
  }

  // 제어: 중지
  Future<void> stopServer(String description) async {
    try {
      isBusy.value = true;
      lastError.value = '';

      final authStorage = GetStorage('auth');
      final userLoginId = authStorage.read('loginedId');

      // TODO:
      // final ok = await api.verifyMasterKey(masterKey);
      // if (!ok) throw Exception('Invalid master key');
      // await api.stopServer(key);
      // await refreshStatus();

      serverStatus.value = const ServerStatus(status: "stopped", startedAt: null);
    } catch (e) {
      lastError.value = '서버 중지 실패: $e';
    } finally {
      isBusy.value = false;
    }
  }

  // 제어: 재시작
  Future<void> restartServer() async {
    try {
      isBusy.value = true;
      lastError.value = '';

      // TODO:
      // final ok = await api.verifyMasterKey(masterKey);
      // if (!ok) throw Exception('Invalid master key');
      // await api.restartServer(key);
      // await refreshStatus();

      serverStatus.value = ServerStatus(status: "running", startedAt: DateTime.now());
    } catch (e) {
      lastError.value = '서버 재시작 실패: $e';
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> verifyMasterKey(String masterKey) async {
    try {
      // TODO: return await api.verifyMasterKey(key);
      if (masterKey.isEmpty || masterKey != "test") return false;
      return true;
    } catch (e) {
      lastError.value = '마스터키 검증 실패: $e';
      return false;
    }
  }
}
