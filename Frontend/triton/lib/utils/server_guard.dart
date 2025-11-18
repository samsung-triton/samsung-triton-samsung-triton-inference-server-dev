// 서버가 가동중인지 확인하는 유틸
import 'package:get/get.dart';
import 'package:triton/controller/server/server_controller.dart';

Future<bool> isServerRunning() async {
  final server = Get.find<ServerController>();

  await server.refreshStatus();

  final status = server.serverStatus.value?.status;
  return status == 'running';
}
