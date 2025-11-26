// 화면 전체 메인
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/router.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/controller/auth/auth_controller.dart';

void main() async {
  // api + 계정 관련 모든 페이지에서 이용
  await GetStorage.init('auth');
  Get.put<ApiClient>(ApiClient(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 라우터 설정
    return MaterialApp.router(
      title: 'Triton Server Monitor',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(scaffoldBackgroundColor: white),
    );
  }
}
