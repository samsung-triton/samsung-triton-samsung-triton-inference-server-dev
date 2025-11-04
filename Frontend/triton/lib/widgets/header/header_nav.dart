//헤더 좌측 메뉴 바
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:triton/widgets/header/menu_text.dart';

import 'package:triton/router.dart';

class HeaderNav extends StatelessWidget {
  const HeaderNav({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;

    return Container(
      height: 48,
      alignment: Alignment.center, //menu를 정렬, 내부 자식들에게는 영향 X
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          MenuText(label: 'Dashboard', to: Routes.dashboard, selected: loc.startsWith(Routes.dashboard)),
          MenuText(label: 'Model Manage', to: Routes.modelManage, selected: loc.startsWith(Routes.modelManage)),
          MenuText(label: 'Model Log', to: Routes.modelLog, selected: loc.startsWith(Routes.modelLog)),
          MenuText(label: 'Server Log', to: Routes.serverLog, selected: loc.startsWith(Routes.serverLog)),
        ],
      ),
    );
  }
}
