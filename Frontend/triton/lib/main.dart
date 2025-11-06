import 'package:flutter/material.dart';
import 'router.dart';

import './theme/app_colors.dart';

void main() {
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
