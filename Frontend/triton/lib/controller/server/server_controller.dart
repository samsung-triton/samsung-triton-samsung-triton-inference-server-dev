// 헤더 컨트롤러
import 'dart:async';
import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/utils/show_alert.dart';
import 'dart:convert';

// 서버 상태
class ServerStatus {
  final String status; // 'running' | 'stopped'
  final DateTime? startedAt; // 예: 2025-11-04T15:32:10+09:00
  const ServerStatus({required this.status, required this.startedAt});
}

class ServerController extends GetxController {
  // 상태
  final Rx<ServerStatus?> serverStatus = Rx<ServerStatus?>(null);
  final RxString uptimeHms = '00:00:00'.obs;
  final RxBool isBusy = false.obs;
  final RxString lastError = ''.obs;

  late final ApiClient _api;

  Timer? _tick;
  StreamSubscription<String>? _sseSub;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    _startUptimeTicker();
    refreshStatus();
    _listenServerStatus();
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

  void _listenServerStatus() {
    _sseSub = _api.listenServerStatus().listen((data) {
      final json = jsonDecode(data);

      final status = json['status'];
      final startedAt = json['started_at'];

      serverStatus.value = ServerStatus(
        status: status == 'ready' ? 'running' : 'stopped',
        startedAt: startedAt != null ? DateTime.tryParse(startedAt) : null,
      );
    });
  }

  Future<void> refreshStatus() async {
    try {
      isBusy.value = true;
      lastError.value = '';

      final data = await _api.getServerStatus();

      final status = data['status'] ?? 'unknown'; // ready / not_ready

      final startedAtString = data['started_at'] ?? data['startedAt'];
      final hasStartedAt = startedAtString != null && startedAtString.isNotEmpty;

      // 서버가 ready 상태이고 startedAt도 있을 때만 running
      final isRunning = status == 'ready' && hasStartedAt;

      DateTime? startedAt;
      if (isRunning) {
        startedAt = DateTime.tryParse(startedAtString!);
      }

      serverStatus.value = ServerStatus(status: isRunning ? 'running' : 'stopped', startedAt: startedAt);
    } catch (e) {
      lastError.value = '상태 조회 실패: $e';
      serverStatus.value = null;
    } finally {
      isBusy.value = false;
    }
  }

  // 제어: 시작
  Future<bool> startServer() async {
    try {
      isBusy.value = true;
      lastError.value = '';

      // 로그인 사용자 ID 불러오기
      final authStorage = GetStorage('auth');
      final userLoginId = authStorage.read('loginedId');

      if (userLoginId == null || userLoginId.isEmpty) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final dynamic data = await _api.startServer(userLoginId: userLoginId);

      if (data is String) {
        // Alert 테스트 해야함
        ShowAlert.show(message: data);
        return false;
      }

      final startedAt = DateTime.tryParse(data['started_at'] ?? data['startedAt'] ?? '');
      serverStatus.value = ServerStatus(status: 'running', startedAt: startedAt ?? DateTime.now());

      ShowAlert.show(message: "Server started successfully.");
      return true;
    } catch (e) {
      lastError.value = '서버 시작 실패: $e'; //alert로 띄울지, 메세지 커스텀 할지
      print('[startServer] 예외 발생: $e'); //에러 로그 출력, 테스트 후 삭제 예정

      return false;
    } finally {
      isBusy.value = false;
    }
  }

  // 제어: 중지
  Future<bool> stopServer(String description) async {
    try {
      isBusy.value = true;
      lastError.value = '';

      final authStorage = GetStorage('auth');
      final userLoginId = authStorage.read('loginedId');

      if (userLoginId == null || userLoginId.isEmpty) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final dynamic data = await _api.stopServer(userLoginId: userLoginId, description: description);

      if (data is String) {
        // Alert 테스트 해야함
        ShowAlert.show(message: data);
        return false;
      }

      serverStatus.value = ServerStatus(status: 'stopped', startedAt: null);
      return true;
    } catch (e) {
      lastError.value = '서버 중지 실패: $e'; //alert로 띄울지, 메세지 커스텀 할지
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  // 제어: 재시작
  Future<bool> restartServer(String description) async {
    try {
      isBusy.value = true;
      lastError.value = '';

      final authStorage = GetStorage('auth');
      final userLoginId = authStorage.read('loginedId');

      if (userLoginId == null || userLoginId.isEmpty) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final dynamic data = await _api.restartServer(userLoginId: userLoginId, description: description);

      if (data is String) {
        // Alert 테스트 해야함
        ShowAlert.show(message: data);
        return false;
      }

      final startedAt = DateTime.tryParse(data['started_at'] ?? data['startedAt'] ?? '');
      serverStatus.value = ServerStatus(status: 'running', startedAt: startedAt ?? DateTime.now());
      return true;
    } catch (e) {
      lastError.value = '서버 재시작 실패: $e'; //alert로 띄울지, 메세지 커스텀 할지
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> verifyMasterKey(String masterKey) async {
    try {
      if (masterKey.isEmpty) {
        return false;
      }

      // 서버는 int를 받으니까 변환 필요
      final keyInt = int.tryParse(masterKey);
      if (keyInt == null) {
        return false;
      }

      final data = await _api.verifyMasterKey(masterKey: keyInt);

      // 서버가 오류 메시지를 String으로 보냈을 때
      if (data is String) {
        // Alert 테스트 해야함
        ShowAlert.show(message: data);
        return false;
      }
      return true;
    } catch (e) {
      lastError.value = "마스터키 검증 실패: $e"; // //alert로 띄울지, 메세지 커스텀 할지
      return false;
    }
  }
}
