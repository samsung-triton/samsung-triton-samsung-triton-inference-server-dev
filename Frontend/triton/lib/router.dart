import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triton/screen/dashboard/dashboard_screen.dart';

import 'package:triton/screen/login/login_Screen.dart';
import 'package:triton/screen/model_log/model_log_screen.dart';
import 'package:triton/screen/model_manage/model_manage_screen.dart';
import 'package:triton/screen/server_log/server_log_screen.dart';

import 'package:triton/app_frame.dart';

// 라우트 경로 관리용 클래스
class Routes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const modelManage = '/model_manage';
  static const modelLog = '/model_log';
  static const serverLog = '/server_log';
}

// 실직적인 Router를 담당하는 인스턴스
final appRouter = GoRouter(
  initialLocation: Routes.login,
  routes: [
    // 공통 프레임(헤더) 아래의 하위 라우트들
    ShellRoute(
      builder: (_, __, child) => AppFrame(child: child),
      routes: [
        GoRoute(path: Routes.login, name: 'login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: Routes.dashboard, name: 'dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: Routes.modelManage, name: 'model_manage', builder: (_, __) => const ModelManageScreen()),
        GoRoute(path: Routes.modelLog, name: 'model_log', builder: (_, __) => const ModelLogScreen()),
        GoRoute(path: Routes.serverLog, name: 'server_log', builder: (_, __) => const ServerLogScreen()),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(body: Center(child: Text('404: ${state.matchedLocation}'))),
);
