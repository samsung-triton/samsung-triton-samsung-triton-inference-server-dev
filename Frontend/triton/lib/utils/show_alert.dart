// lib/utils/global_alert.dart
import 'package:get/get.dart';

class ShowAlert {
  // 전역 상태 (컨트롤러 없이 static Rx)
  static final RxBool _isVisible = false.obs;
  static final RxString _title = 'Notification'.obs;
  static final RxString _message = ''.obs;

  // 읽기용 getter
  static RxBool get isVisible => _isVisible;
  static RxString get title => _title;
  static RxString get message => _message;

  // 보여주기
  static void show({String title = 'Notification', required String message}) {
    _title.value = title;
    _message.value = message;
    _isVisible.value = true;
  }

  // 숨기기
  static void hide() {
    _isVisible.value = false;
  }
}
