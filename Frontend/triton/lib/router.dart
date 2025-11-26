// 화면 이동을 위한 라우터
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_storage/get_storage.dart';

import 'package:triton/screen/dashboard/dashboard_screen.dart';
import 'package:triton/screen/login/login_Screen.dart';
import 'package:triton/screen/Triton_log/triton_log_screen.dart';
import 'package:triton/screen/model_manage/model_manage_screen.dart';
import 'package:triton/screen/server_log/server_log_screen.dart';

import 'package:triton/app_frame.dart';

// 라우트 경로 관리용 클래스
class Routes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const modelManage = '/model_manage';
  static const tritonLog = '/triton_log';
  static const serverLog = '/server_log';
}

// 라우터 담당하는 인스턴스
final appRouter = GoRouter(
  initialLocation: Routes.login,

  // 로그인 | role 권한 체크
  redirect: (context, state) {
    final authStorage = GetStorage('auth');
    final loginedId = authStorage.read<String>('loginedId');
    final role = authStorage.read<String>('role');

    final loc = state.matchedLocation;
    final isLoginRoute = loc == Routes.login;

    // 비로그인 접근 제어
    if (loginedId == null || loginedId.isEmpty) {
      // 로그인 페이지만 허용
      if (!isLoginRoute) {
        return Routes.login;
      }
      return null;
    }

    // OPER 접근 제어
    if (role == 'OPER') {
      // dashboard만 허용
      const allowedForOper = {Routes.dashboard};
      if (!allowedForOper.contains(loc)) {
        return Routes.dashboard;
      }
      return null;
    }

    // DEVEL 접근 제어
    if (role == 'DEVEL') {
      // 로그인 제외 모든 페이지 허용
      const allowedForDevel = {Routes.dashboard, Routes.modelManage, Routes.tritonLog, Routes.serverLog};
      if (!allowedForDevel.contains(loc)) {
        return Routes.dashboard;
      }
      return null;
    }

    // role이 이상한 값이면 그냥 다시 로그인
    return Routes.login;
  },

  routes: [
    // 공통 프레임(헤더) 아래의 하위 라우트들
    ShellRoute(
      // 프레임(헤더)
      builder: (_, __, child) => AppFrame(child: child),

      // 실라우터
      routes: [
        GoRoute(
          path: Routes.login,
          name: 'login',
          pageBuilder: (_, state) => const NoTransitionPage(child: LoginScreen()),
        ),
        GoRoute(
          path: Routes.dashboard,
          name: 'dashboard',
          pageBuilder: (_, state) => const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: Routes.modelManage,
          name: 'model_manage',
          pageBuilder: (_, state) => const NoTransitionPage(child: ModelManageScreen()),
        ),
        GoRoute(
          path: Routes.tritonLog,
          name: 'triton_log',
          pageBuilder: (_, state) => const NoTransitionPage(child: TritonLogScreen()),
        ),
        GoRoute(
          path: Routes.serverLog,
          name: 'server_log',
          pageBuilder: (_, state) => const NoTransitionPage(child: ServerLogScreen()),
        ),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(body: Center(child: Text('404: ${state.matchedLocation}'))),
);
