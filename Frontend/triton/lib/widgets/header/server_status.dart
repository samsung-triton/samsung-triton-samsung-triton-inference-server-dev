import 'package:flutter/material.dart';

import '../../theme/typography.dart';
import '../../theme/app_colors.dart';

import 'dart:async';

class ServerStatus extends StatefulWidget {
  final String status;
  final DateTime? startTime;

  const ServerStatus({super.key, required this.status, this.startTime});

  @override
  State<ServerStatus> createState() => _ServerStatusWidgetState();
}

class _ServerStatusWidgetState extends State<ServerStatus> {
  late Timer _timer; //1초마다 시작되는 타이머
  Duration _elapsed = Duration.zero; //서버 가동 시간을 나타내는 변수. 시,분,초

  @override
  void initState() {
    // 초기상태
    super.initState();

    // 서버가 실행 중이라면 타이머 시작
    if (widget.status == "running" && widget.startTime != null) {
      _updateElapsed();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateElapsed());
    }
  }

  // 시간 계산
  void _updateElapsed() {
    final now = DateTime.now().toUtc();
    final diff = now.difference(widget.startTime!);
    setState(() => _elapsed = diff);
  }

  // 타이머 중지 -> 버튼이랑 연동 필요 or 백엔드랑 연동 필요
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //초를 시,분,초 단위로 환산
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final bool running = widget.status == "running";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: running ? black : lightGray, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: running ? statusGreen : statusRed, shape: BoxShape.circle),
          ),
          running
              ? Text(_formatDuration(_elapsed), style: T.t16(color: white, bold: false))
              : Text("stopped", style: T.t16(color: black, bold: false)),
        ],
      ),
    );
  }
}
