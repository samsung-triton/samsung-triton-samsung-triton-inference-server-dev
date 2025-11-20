import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:triton/router.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/controller/auth/auth_controller.dart';

import './theme/app_colors.dart';

void main() async {
  await GetStorage.init('auth');

  Get.put<ApiClient>(ApiClient(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Triton Server Monitor',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(scaffoldBackgroundColor: white),
    );
  }
}
