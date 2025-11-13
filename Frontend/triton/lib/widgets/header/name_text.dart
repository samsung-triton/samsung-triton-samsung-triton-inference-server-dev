import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

class NameText extends StatelessWidget {
  final double width;
  const NameText({super.key, this.width = 100});

  GetStorage get _authStorage => GetStorage('auth');

  @override
  Widget build(BuildContext context) {
    final displayName = _authStorage.read<String>('loginedId') ?? '';

    return SizedBox(
      width: width,
      child: FittedBox(
        fit: BoxFit.scaleDown, // 텍스트가 넘칠 때 자동 축소
        alignment: Alignment.center,
        child: Text(
          displayName,
          style: T.t20(color: black, bold: false),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // 너무 길면 ... 표시
        ),
      ),
    );
  }
}
