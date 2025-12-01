// 계정 관리 컨트롤러
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/utils/api_client.dart';

class AuthController extends GetxController {
  // 로컬 스토리지 (계정)
  final authStorage = GetStorage('auth');
  static const _kLoginedId = 'loginedId';
  static const _kRole = 'role';

  // 공통 API 클라이언트 사용
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
  }

  // 로그인 기능
  Future<bool> login(String id, String pw) async {
    if (id.trim().isEmpty || pw.trim().isEmpty) {
      return false;
    }

    try {
      // 로그인 api 연동
      final dynamic data = await _api.login(loginId: id, password: pw);

      // 데이터가 String이면 에러메세지
      if (data is String) {
        return false;
      }

      // role 확인
      final String serverRole = data['role']?.toString() ?? '';

      // loginId 과 role 저장
      _persistSession(id, serverRole);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 로그아웃 기능
  void logout() {
    _clearSession();
  }

  // 로그인 정보 저장
  void _persistSession(String loginedId, String role) {
    authStorage.write(_kLoginedId, loginedId);
    authStorage.write(_kRole, role);
  }

  // 로그인 정보 삭제
  void _clearSession() {
    authStorage.remove(_kLoginedId);
    authStorage.remove(_kRole);
  }
}
