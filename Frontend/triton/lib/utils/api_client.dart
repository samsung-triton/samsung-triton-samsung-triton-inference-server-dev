// api 모음 파일
import 'dart:convert';
import 'package:get/get.dart';

// 앱 전체에서 공통으로 사용하는 API 클라이언트.
class ApiClient extends GetConnect {
  static const String _baseUrl = 'http://213.181.122.2:53617';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 10);
    super.onInit();
  }

  // ---------------------------------------------------------------------------
  // 내부 공통 처리
  // ---------------------------------------------------------------------------

  /// Get 요청 공통 래퍼
  Future<dynamic> _get(String path, {String? apiName}) async {
    final res = await get(path);
    return _unwrapResponse(res, apiName ?? path);
  }

  /// Post 요청 공통 래퍼
  Future<dynamic> _postJson(String path, dynamic body, {String? apiName}) async {
    final res = await post(path, body, contentType: 'application/json');
    return _unwrapResponse(res, apiName ?? path);
  }

  /// 임의 메서드용 공통 래퍼 (현재는 delete 용도)
  Future<dynamic> _requestRaw(String path, String method, {dynamic body, String? apiName}) async {
    final res = await httpClient.request(path, method, body: body);
    return _unwrapResponse(res, apiName ?? '$method $path');
  }

  /// 공통 응답 언래핑
  dynamic _unwrapResponse(Response res, String apiName) {
    // 1) 요청 실패: message 반환
    if (!res.isOk) {
      print('[ApiClient] $apiName Api Error: ${res.statusCode} ${res.statusText}');
      return res.body['message'];
    }

    // 2) 요청 성공: data 반환
    dynamic body = res.body;
    final data = body['data'];
    return data;
  }

  // ---------------------------------------------------------------------------
  // 권한 관련
  // ---------------------------------------------------------------------------

  // 로그인
  Future<dynamic> login({required String loginId, required String password}) {
    return _postJson('/api/v1/auth/login', {'loginId': loginId, 'password': password}, apiName: 'login');
  }

  // 마스터키 확인
  Future<dynamic> verifyMasterKey({required int masterKey}) {
    return _postJson('/api/v1/masterkey/verify', {'masterKey': masterKey}, apiName: 'verifyMasterKey');
  }

  // ---------------------------------------------------------------------------
  // 서버 관리
  // ---------------------------------------------------------------------------

  // 서버 상태
  Future<dynamic> getServerStatus() {
    return _get('/api/v1/server/status', apiName: 'getServerStatus');
  }

  // 서버 시작
  Future<dynamic> startServer({required String userLoginId}) {
    return _postJson('/api/v1/server/start', {
      'user_login_id': userLoginId,
      'description': null,
    }, apiName: 'startServer');
  }

  // 서버 중지
  Future<dynamic> stopServer({required String userLoginId, required String description}) {
    return _postJson('/api/v1/server/stop', {
      'user_login_id': userLoginId,
      'description': description,
    }, apiName: 'stopServer');
  }

  // 서버 재시작
  Future<dynamic> restartServer({required String userLoginId, required String description}) {
    return _postJson('/api/v1/server/restart', {
      'user_login_id': userLoginId,
      'description': description,
    }, apiName: 'restartServer');
  }

  // ---------------------------------------------------------------------------
  // 서버 대시보드 (Server Dashboard)
  // ---------------------------------------------------------------------------

  // 서버 메트릭스 정보
  Future<dynamic> getServerMetrics() {
    return _get('/api/v1/dashboard/server/metrics', apiName: 'getServerMetrics');
  }

  // GPU / 리소스 시계열 정보
  Future<dynamic> getServerTimeSeries() {
    return _get('/api/v1/dashboard/server/timeseries', apiName: 'getServerTimeSeries');
  }

  // GET /api/v1/models/standard-time
  Future<dynamic> getStandardTime() {
    return _get('/api/v1/models/standard-time', apiName: 'getStandardTime');
  }

  // POST /api/v1/models/standard-time
  Future<dynamic> updateStandardTime(String baseTime) {
    return _postJson('/api/v1/models/standard-time', {'base_time': baseTime}, apiName: 'updateStandardTime');
  }

  // ---------------------------------------------------------------------------
  // 모델 대시보드 (Model Dashboard)
  // ---------------------------------------------------------------------------

  // 모델 통계 (inference count, success, fail 등)
  Future<dynamic> getModelStats({required String modelName}) {
    return _get('/api/v1/dashboard/model/stats?model_name=$modelName', apiName: 'getModelStats');
  }

  // 모델 latency timeseries
  Future<dynamic> getModelLatency({required String modelName}) {
    return _get('/api/v1/dashboard/model/latency?model_name=$modelName', apiName: 'getModelLatency');
  }

  // ---------------------------------------------------------------------------
  // 모델 관리
  // ---------------------------------------------------------------------------

  // 모델 목록 조회
  Future<dynamic> getModelList() {
    return _get('/api/v1/models', apiName: 'getModelList');
  }

  // 단일 모델 최초 등록 (파일 업로드 등이라 contentType 고정 안 함)
  Future<dynamic> createModel(dynamic body) {
    return post('/api/v1/models', body).then((res) => _unwrapResponse(res, 'createModel'));
  }

  // 앙상블 모델 등록
  Future<dynamic> createEnsembleModel(dynamic body) {
    return post('/api/v1/models/register/ensemble', body).then((res) => _unwrapResponse(res, 'createEnsembleModel'));
  }

  // 모델 삭제
  Future<dynamic> deleteModel({required int modelId, required String loginId, required String description}) {
    return _requestRaw(
      '/api/v1/models/$modelId',
      'DELETE',
      body: jsonEncode({'loginId': loginId, 'description': description}),
      apiName: 'deleteModel',
    );
  }

  // 모델 버전 목록 + Config 조회
  Future<dynamic> getModelVersionsAndConfig({required int modelId}) {
    return _get('/api/v1/models/$modelId', apiName: 'getModelVersionsAndConfig');
  }

  // 모델 버전 or 설정 추가
  Future<dynamic> addModelAssets({required int modelId, required dynamic body}) {
    return post('/api/v1/models/$modelId/assets', body).then((res) => _unwrapResponse(res, 'addModelAssets'));
  }

  // 모델 버전 삭제
  Future<dynamic> deleteModelVersion({
    required int modelId,
    required int version,
    required String loginId,
    required String description,
  }) {
    return _requestRaw(
      '/api/v1/models/$modelId/versions/$version',
      'DELETE',
      body: jsonEncode({'loginId': loginId, 'description': description}),
      apiName: 'deleteModelVersion',
    );
  }

  // ---------------------------------------------------------------------------
  // Config 관리
  // ---------------------------------------------------------------------------

  // config 롤백 목록
  Future<dynamic> getConfigHistory({required int modelId}) {
    return _get('/api/v1/models/$modelId/config', apiName: 'getConfigHistory');
  }

  // config 저장 및 Triton 적용
  Future<dynamic> applyConfig({
    required int modelId,
    required String loginId,
    required String description,
    required String configContent,
  }) {
    return _postJson(
      '/api/v1/models/$modelId/config/apply',
      jsonEncode({'loginId': loginId, 'description': description, 'configContent': configContent}),
      apiName: 'applyConfig',
    );
  }

  // config 삭제
  Future<dynamic> deleteConfig({
    required int modelId,
    required int configId,
    required String loginId,
    required String description,
  }) {
    return _requestRaw(
      '/api/v1/models/$modelId/config/$configId',
      'DELETE',
      body: jsonEncode({'loginId': loginId, 'description': description}),
      apiName: 'deleteConfig',
    );
  }

  //Serverlog - server 로그 조회 & 필터링
  Future<dynamic> getApiLog({
    required int startDate,
    required String endDate,
    String? username,
    String? type,
    String? description,
  }) {
    return _requestRaw(
      '/api/v1/logs/api',
      'POST',
      body: jsonEncode({
        'startDate': startDate,
        'endDate': endDate,
        'username': username,
        'type': type,
        'description': description,
      }),
      apiName: 'getApiLog',
    );
  }
}
