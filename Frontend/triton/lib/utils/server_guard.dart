// 서버가 가동중인지 확인하는 유틸
import 'package:get/get.dart';
import 'package:triton/controller/server/server_controller.dart';

bool isServerRunning() {
  final server = Get.find<ServerController>();
  return server.serverStatus.value?.status == 'running';
}
