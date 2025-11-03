import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triton/screen/dashboard/dashboard_screen.dart';

import 'package:triton/screen/login/login_Screen.dart';
import 'package:triton/screen/model_log/model_log_screen.dart';
import 'package:triton/screen/model_manage/model_manage_screen.dart';
import 'package:triton/screen/server_log/server_log_screen.dart';

// 라우트 경로 관리용 클래스
class Routes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const modelManage = '/model_manage';
  static const modelLog = '/model_log';
  static const serverLog = '/server_log';
}

// 임시용 헤더 프레임
class AppFrame extends StatelessWidget {
  final Widget child;
  const AppFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0), child: _HeaderNav()),
      ),
      body: child,
    );
  }
}

class _HeaderNav extends StatelessWidget {
  const _HeaderNav();

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _NavItem(label: 'Dashboard', to: Routes.dashboard, selected: loc.startsWith(Routes.dashboard)),
          _NavItem(label: 'Model Manage', to: Routes.modelManage, selected: loc.startsWith(Routes.modelManage)),
          _NavItem(label: 'Model Log', to: Routes.modelLog, selected: loc.startsWith(Routes.modelLog)),
          _NavItem(label: 'Server Log', to: Routes.serverLog, selected: loc.startsWith(Routes.serverLog)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String to;
  final bool selected;

  const _NavItem({required this.label, required this.to, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.go(to),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: selected ? color.primary : Colors.transparent, width: 3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color.primary : color.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// 실직적인 Router를 담당하는 인스턴스
final appRouter = GoRouter(
  initialLocation: Routes.login,
  routes: [
    // 로그인은 별개 라우팅으로 분리
    GoRoute(path: Routes.login, name: 'login', builder: (_, __) => const LoginScreen()),

    // 로그인 이후의 페이지들
    // 공통 프레임(헤더) 아래의 하위 라우트들
    ShellRoute(
      builder: (_, __, child) => AppFrame(child: child),
      routes: [
        GoRoute(path: Routes.dashboard, name: 'dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: Routes.modelManage, name: 'model_manage', builder: (_, __) => const ModelManageScreen()),
        GoRoute(path: Routes.modelLog, name: 'model_log', builder: (_, __) => const ModelLogScreen()),
        GoRoute(path: Routes.serverLog, name: 'server_log', builder: (_, __) => const ServerLogScreen()),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(body: Center(child: Text('404: ${state.matchedLocation}'))),
);
