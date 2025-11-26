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
      return false;
    }

    try {
      final dynamic data = await _api.login(loginId: id, password: pw);

      // 데이터가 String이면 에러메세지
      if (data is String) {
        return false;
      }

      final String serverRole = data['role']?.toString() ?? '';

      _persistSession(id, serverRole); // loginId & role 저장
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _clearSession();
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
