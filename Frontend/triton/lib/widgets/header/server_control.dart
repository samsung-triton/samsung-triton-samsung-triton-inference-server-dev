import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServerControl extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRestart;

  const ServerControl({super.key, required this.onStart, required this.onStop, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton('assets/icons/start_black.svg', onStart),
        const SizedBox(width: 12),
        _buildIconButton('assets/icons/stop_black.svg', onStop),
        const SizedBox(width: 12),
        _buildIconButton('assets/icons/restart_black.svg', onRestart),
      ],
    );
  }

  // 내부용 helper 함수
  Widget _buildIconButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent, // 클릭 시 배경 없음
          ),
          child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
