import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'router.dart';
import 'package:triton/utils/api_client.dart';
import './theme/app_colors.dart';

void main() {
  Get.put<ApiClient>(ApiClient(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Triton',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(scaffoldBackgroundColor: white),
    );
  }
}
