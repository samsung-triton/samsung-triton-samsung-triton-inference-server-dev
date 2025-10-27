// 공통 헤더 위젯
import 'package:flutter/material.dart';
import 'package:triton/util/menu_util.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Row(
        children: [
          const SizedBox(width: 24),
          ...List.generate(MenuUtil.menuList.length, (index) {
            return Text(MenuUtil.menuList[index]);
          }),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
