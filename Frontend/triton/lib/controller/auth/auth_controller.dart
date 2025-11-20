import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/utils/api_client.dart';

class AuthController extends GetxController {
  // 로컬 스토리지
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

  Future<bool> login(String id, String pw) async {
    if (id.trim().isEmpty || pw.trim().isEmpty) {
      print('[Auth] ❌ 아이디/비밀번호 비어있음');
      return false;
    }

    try {
      final dynamic data = await _api.login(loginId: id, password: pw);

      // 데이터가 String이면 에러메세지
      if (data is String) {
        print(data);
        return false;
      }

      final String serverRole = data['role']?.toString() ?? '';
      print('[Auth] ✅ 로그인 성공 (id=$id, role=$serverRole)');

      _persistSession(id, serverRole); // loginId & role 저장
      return true;
    } catch (e) {
      print('[Auth] ❌ 예외: $e');
      return false;
    }
  }

  void logout() {
    _clearSession();
    print('[Auth] ✅ 로그아웃 완료');
  }

  // 세션 저장
  void _persistSession(String loginedId, String role) {
    authStorage.write(_kLoginedId, loginedId);
    authStorage.write(_kRole, role);
  }

  // 세션 삭제
  void _clearSession() {
    authStorage.remove(_kLoginedId);
    authStorage.remove(_kRole);
  }
}
