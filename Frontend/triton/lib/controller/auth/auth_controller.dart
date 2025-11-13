import 'dart:convert';
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
      // ✅ 공통 API 사용
      final resp = await _api.login(loginId: id, password: pw);

      if (!resp.isOk || resp.body == null) {
        print('[Auth] ❌ HTTP ${resp.statusCode} : ${resp.statusText}');
        return false;
      }

      // resp.body 타입 안전하게 처리 (Map이거나 String일 수 있어서)
      final Map<String, dynamic> body = switch (resp.body) {
        Map<String, dynamic> m => m,
        _ => jsonDecode(resp.bodyString!) as Map<String, dynamic>,
      };

      // ← 응답은 항상 { code, message, data:{ role } } 라고 가정
      final String code = body['code'] as String;
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final String serverRole = data['role']?.toString() ?? '';

      if (code == 'AUTH-001' && serverRole.isNotEmpty) {
        _persistSession(id, serverRole); // loginId & role 저장
        print('[Auth] ✅ 로그인 성공 (`id=$id), role=${serverRole}');
        return true;
      } else {
        final msg = body['message'];
        print('[Auth] ❌ 실패 코드: $code / $msg');
        return false;
      }
    } catch (e) {
      print('[Auth] ❌ 예외: $e');
      return false;
    }
  }

  void logout() {
    _clearSession();
    print('[Auth] 🧹 로그아웃 완료');
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
