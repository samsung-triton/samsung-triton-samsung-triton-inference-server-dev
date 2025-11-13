import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_storage/get_storage.dart';

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

  // 로그인/권한 체크
  redirect: (context, state) {
    final authStorage = GetStorage('auth');
    final loginedId = authStorage.read<String>('loginedId');
    final role = authStorage.read<String>('role');

    final loc = state.matchedLocation;
    final isLoginRoute = loc == Routes.login;

    // 1) 로그인 안 되어 있으면: 로그인 페이지만 허용
    if (loginedId == null || loginedId.isEmpty) {
      if (!isLoginRoute) {
        return Routes.login;
      }
      return null;
    }

    // 2) role에 따른 접근 제어: OPER
    if (role == 'OPER') {
      // dashboard만 허용
      const allowedForOper = {Routes.dashboard};
      if (!allowedForOper.contains(loc)) {
        return Routes.dashboard;
      }
      return null;
    }

    // 2) role에 따른 접근 제어: DEVEL
    if (role == 'DEVEL') {
      // 로그인 제외 모든 페이지 허용
      const allowedForDevel = {Routes.dashboard, Routes.modelManage, Routes.modelLog, Routes.serverLog};
      if (!allowedForDevel.contains(loc)) {
        return Routes.dashboard;
      }
      return null;
    }

    // 3) role이 이상한 값이면 그냥 다시 로그인 시키기
    return Routes.login;
  },

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
