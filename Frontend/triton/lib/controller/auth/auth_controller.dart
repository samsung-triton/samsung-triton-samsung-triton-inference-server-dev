import 'package:get/get.dart';

class AuthController extends GetxController {
  // 상태 변수들
  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  // 로그인 입력값
  final loginId = ''.obs;
  final password = ''.obs;

  // 사용자 정보
  final userId = RxnInt();
  final userName = ''.obs;

  // 더미 로그인 계정 리스트 (테스트용)
  final dummyUsers = [
    {'loginId': 'jieun', 'password': '1234', 'name': 'Jieunnnnnnny'},
    {'loginId': 'minju', 'password': '1234', 'name': 'minju'},
  ];

  /// 로그인 로직
  Future<bool> login() async {
    if (loginId.isEmpty || password.isEmpty) {
      print('[AuthController] ❌ 아이디 또는 비밀번호가 비어있습니다.');
      return false;
    }

    isLoading.value = true;

    try {
      final inputId = loginId.value.trim();
      final inputPw = password.value.trim();

      // 더미 계정에서 로그인 검증
      final user = dummyUsers.firstWhereOrNull((u) => u['loginId'] == inputId && u['password'] == inputPw);

      await Future.delayed(const Duration(milliseconds: 400)); // 가짜 대기

      if (user == null) {
        print('[AuthController] ❌ 로그인 실패: 아이디 또는 비밀번호 불일치');
        return false;
      }

      // 로그인 성공 → 사용자 정보 세팅
      userId.value = 100 + dummyUsers.indexOf(user);
      userName.value = user['name']!;
      isLoggedIn.value = true;

      print('[AuthController] ✅ 로그인 성공 (${userName.value})');
      return true;
    } catch (e) {
      print('[AuthController] ❌ 로그인 중 오류 발생: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 사용자 정보 조회 (로그인된 상태일 때)
  void printUserInfo() {
    if (!isLoggedIn.value) {
      print('[AuthController] ⚠️ 로그인되지 않았습니다.');
      return;
    }

    print('''
[AuthController] 사용자 정보
- ID: ${userId.value}
- 로그인ID: ${loginId.value}
- 이름: ${userName.value}
''');
  }

  /// 로그아웃
  void logout() {
    userId.value = null;
    loginId.value = '';
    password.value = '';
    userName.value = '';
    isLoggedIn.value = false;
    print('[AuthController] 🧹 로그아웃 완료');
  }
}
