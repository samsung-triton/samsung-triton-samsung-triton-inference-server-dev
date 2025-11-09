import 'package:flutter/material.dart';
import '../../theme/typography.dart';
import '../../theme/app_colors.dart';
import 'package:get/get.dart';
import '../../controller/auth/auth_controller.dart';

class NameText extends StatelessWidget {
  final double width;
  const NameText({super.key, this.width = 100});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return SizedBox(
      width: width,
      child: Obx(() {
        final displayName = auth.userName.value.isNotEmpty ? auth.userName.value : 'Guest'; //이름 없으면 guest

        return FittedBox(
          fit: BoxFit.scaleDown, // 텍스트가 넘칠 때 자동 축소
          alignment: Alignment.center,
          child: Text(
            displayName,
            style: T.t20(color: black, bold: false),
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // 너무 길면 ... 표시
          ),
        );
      }),
    );
  }
}
