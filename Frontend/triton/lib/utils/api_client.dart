// api 모음 파일
import 'dart:convert';
import 'package:get/get.dart';

// 앱 전체에서 공통으로 사용하는 API 클라이언트.
class ApiClient extends GetConnect {
  static const String _baseUrl = 'http://163.5.212.63:39890';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 10);

    super.onInit();
  }

  // ---------------------------------------------------------------------------
  // 권한 관련
  // ---------------------------------------------------------------------------

  // 로그인
  Future<Response> login({required String loginId, required String password}) {
    return post('/api/v1/auth/login', {'loginId': loginId, 'password': password}, contentType: 'application/json');
  }

  // 마스터키 확인
  Future<Response> verifyMasterKey({required int masterKey}) {
    return post('/api/v1/masterkey/verify', {'masterKey': masterKey}, contentType: 'application/json');
  }

  // ---------------------------------------------------------------------------
  // 서버 관리
  // ---------------------------------------------------------------------------

  // 서버 상태
  Future<Response> getServerStatus() {
    return get('/api/v1/server/status');
  }

  // 서버 시작
  Future<Response> startServer({required String userLoginId}) {
    return post('/api/v1/server/start', {
      'user_login_id': userLoginId,
      'description': null,
    }, contentType: 'application/json');
  }

  // 서버 중지
  Future<Response> stopServer({required String userLoginId, required String description}) {
    return post('/api/v1/server/stop', {
      'user_login_id': userLoginId,
      'description': description,
    }, contentType: 'application/json');
  }

  // 서버 재시작
  Future<Response> restartServer({required String userLoginId, required String description}) {
    return post('/api/v1/server/restart', {
      'user_login_id': userLoginId,
      'description': description,
    }, contentType: 'application/json');
  }

  // ---------------------------------------------------------------------------
  // 대시보드 메트릭 / 타임시리즈
  // ---------------------------------------------------------------------------

  // 서버 메트릭스 정보
  // GET /api/v1/dashboard/server/metrics
  Future<Response> getServerMetrics() {
    return get('/api/v1/dashboard/server/metrics');
  }

  // GPU / 리소스 시계열 정보
  // GET /api/v1/dashboard/server/timeseries
  Future<Response> getServerTimeSeries() {
    return get('/api/v1/dashboard/server/timeseries');
  }

  // ---------------------------------------------------------------------------
  // 모델 관리
  // ---------------------------------------------------------------------------

  // 모델 목록 조회
  // (관례대로 GET /api/v1/models 로 가정)
  Future<Response> getModelList() {
    return get('/api/v1/models');
  }

  // 단일 모델 최초 등록
  /// body 예시:
  /// {
  ///   "modelName": "string",
  ///   "modelType": "string",
  ///   "LoginId": "string",
  ///   "description": "string",
  ///   "setupFile": ...,
  ///   "modelFile": ...
  /// }
  ///
  Future<Response> createModel(dynamic body) {
    return post('/api/v1/models', body);
  }

  // 앙상블 모델 등록
  /// body 예시:
  /// {
  ///   "modelName": "string",
  ///   "modelType": "string",
  ///   "LoginId": "string",
  ///   "description": "string",
  ///   "setupFile": ...
  /// }
  ///
  Future<Response> createEnsembleModel(dynamic body) {
    return post('/api/v1/models/register/ensemble', body);
  }

  // 모델 삭제
  Future<Response> deleteModel({required int modelId, required String loginId, required String description}) {
    return httpClient.request(
      '/api/v1/models/$modelId',
      'DELETE',
      body: jsonEncode({'LoginId': loginId, 'description': description}),
    );
  }

  // 모델 버전 목록 + Config 조회
  Future<Response> getModelVersionsAndConfig({required int modelId}) {
    return get('/api/v1/models/$modelId');
  }

  /// 모델 버전 or 설정 추가
  /// body 예시:
  /// {
  ///   "LoginId": "string",
  ///   "description": "string",
  ///   "modelFile": ...,
  ///   "setupFile": ...
  /// }
  Future<Response> addModelVersion({required int modelId, required dynamic body}) {
    return post('/api/v1/models/$modelId/versions', body);
  }

  /// 모델 버전 삭제
  Future<Response> deleteModelVersion({
    required int modelId,
    required int version,
    required String loginId,
    required String description,
  }) {
    return httpClient.request(
      '/api/v1/models/$modelId/versions/$version',
      'DELETE',
      body: jsonEncode({'loginId': loginId, 'description': description}),
    );
  }

  // ---------------------------------------------------------------------------
  // Config 관리
  // ---------------------------------------------------------------------------

  /// config 롤백 목록
  Future<Response> getConfigHistory({required int modelId}) {
    return get('/api/v1/models/$modelId/config');
  }

  /// config 저장 및 Triton 적용
  Future<Response> applyConfig({
    required int modelId,
    required String loginId,
    required String description,
    required String configContent,
  }) {
    return patch(
      '/api/v1/models/$modelId/config/apply',
      jsonEncode({'loginId': loginId, 'description': description, 'configContent': configContent}),
      contentType: 'application/json',
    );
  }

  /// config 삭제
  Future<Response> deleteConfig({
    required int modelId,
    required int configId,
    required String loginId,
    required String description,
  }) {
    return httpClient.request(
      '/api/v1/models/$modelId/config/$configId',
      'DELETE',
      body: jsonEncode({'loginId': loginId, 'description': description}),
    );
  }
}
