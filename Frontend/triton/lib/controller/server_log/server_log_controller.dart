import 'package:get/get.dart';
import 'package:web/web.dart' as web;
import 'dart:js_util' as js_util;

class ServerLogController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // 필터 입력값
  final serverName = ''.obs;
  //final logType = ''.obs;
  final sort = ''.obs;
  final keyword = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  /// 고정된 더미 로그 데이터 (100개)
  final List<Map<String, dynamic>> dummyLogs = [
    {
      'username': 'tester1',
      'date': '2025-11-01 10:15:03',
      'type': 'triton',
      'detail': 'model load',
      'description': 'Model yolov8 loaded successfully.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-01 12:47:15',
      'type': 'server',
      'detail': 'server restart',
      'description': 'Server restarted due to maintenance.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-02 09:30:21',
      'type': 'triton',
      'detail': 'inference request',
      'description': 'Inference request processed successfully.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-02 14:12:42',
      'type': 'server',
      'detail': 'CPU overload',
      'description': 'High CPU usage detected, auto-scaling initiated.',
    },
    {
      'username': 'tester1',
      'date': '2025-11-03 11:09:33',
      'type': 'triton',
      'detail': 'model reload',
      'description': 'Model reloaded due to config update.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-03 13:56:19',
      'type': 'server',
      'detail': 'RAM alert',
      'description': 'Server memory usage exceeded threshold.',
    },
    {
      'username': 'tester5',
      'date': '2025-11-04 08:22:48',
      'type': 'triton',
      'detail': 'health check',
      'description': 'Triton health check passed.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-04 16:45:52',
      'type': 'server',
      'detail': 'server restart',
      'description': 'Server rebooted after GPU driver update.',
    },
    {
      'username': 'tester1',
      'date': '2025-11-05 09:40:28',
      'type': 'triton',
      'detail': 'model unload',
      'description': 'Model unregistered from repository.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-05 18:21:44',
      'type': 'server',
      'detail': 'disk warning',
      'description': 'Disk usage reached 85% capacity.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-06 10:10:58',
      'type': 'triton',
      'detail': 'BLS chain',
      'description': 'BLS ensemble executed successfully.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-06 20:31:16',
      'type': 'server',
      'detail': 'connection lost',
      'description': 'Network connection temporarily lost.',
    },
    {
      'username': 'tester5',
      'date': '2025-11-07 08:05:29',
      'type': 'triton',
      'detail': 'model load',
      'description': 'Model resnet50 loaded successfully.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-07 22:44:12',
      'type': 'server',
      'detail': 'security patch',
      'description': 'Server patched to latest version.',
    },
    {
      'username': 'tester1',
      'date': '2025-11-08 07:51:41',
      'type': 'triton',
      'detail': 'model reload',
      'description': 'Model retrained weights reloaded.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-08 18:17:55',
      'type': 'server',
      'detail': 'GPU allocation',
      'description': 'GPU instance reassigned to task group.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-09 11:03:33',
      'type': 'triton',
      'detail': 'ensemble run',
      'description': 'Ensemble inference completed without errors.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-09 20:42:50',
      'type': 'server',
      'detail': 'server restart',
      'description': 'Restarted after failed inference session.',
    },
    {
      'username': 'tester1',
      'date': '2025-11-10 08:30:26',
      'type': 'triton',
      'detail': 'model validation',
      'description': 'Model validation succeeded with 98.3% accuracy.',
    },
    {
      'username': 'tester5',
      'date': '2025-11-10 16:11:39',
      'type': 'server',
      'detail': 'CPU overload',
      'description': 'Auto-throttling triggered to reduce load.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-11 09:28:12',
      'type': 'triton',
      'detail': 'BLS chain',
      'description': 'Batch inferencing executed via BLS chain.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-11 18:44:19',
      'type': 'server',
      'detail': 'network recovery',
      'description': 'Recovered from temporary disconnection.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-12 07:55:43',
      'type': 'triton',
      'detail': 'model unload',
      'description': 'Old model version removed from registry.',
    },
    {
      'username': 'tester1',
      'date': '2025-11-12 20:12:57',
      'type': 'server',
      'detail': 'GPU driver update',
      'description': 'NVIDIA driver updated to v550.42.',
    },
    {
      'username': 'tester5',
      'date': '2025-11-13 08:48:24',
      'type': 'triton',
      'detail': 'health check',
      'description': 'Triton backend health check successful.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-13 17:05:36',
      'type': 'server',
      'detail': 'RAM alert',
      'description': 'Memory consumption exceeded 90%.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-14 09:34:18',
      'type': 'triton',
      'detail': 'inference request',
      'description': 'Processed 128 inference requests in 5 minutes.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-14 19:29:55',
      'type': 'server',
      'detail': 'security patch',
      'description': 'Security patch 2025-11 applied.',
    },
    {
      'username': 'tester1',
      'date': '2025-11-15 07:41:27',
      'type': 'triton',
      'detail': 'ensemble run',
      'description': 'New ensemble pipeline registered successfully.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-15 21:18:46',
      'type': 'server',
      'detail': 'server restart',
      'description': 'Restarted automatically after system check.',
    },
    {
      'username': 'tester5',
      'date': '2025-11-16 08:13:12',
      'type': 'triton',
      'detail': 'model load',
      'description': 'Transformer model loaded and initialized.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-16 18:59:22',
      'type': 'server',
      'detail': 'connection lost',
      'description': 'Lost connection to monitoring service.',
    },
    {
      'username': 'tester2',
      'date': '2025-11-17 09:25:37',
      'type': 'triton',
      'detail': 'model reload',
      'description': 'Reloaded model with latest configuration.',
    },
    {
      'username': 'tester1',
      'date': '2025-11-17 21:02:10',
      'type': 'server',
      'detail': 'GPU allocation',
      'description': 'GPU resources dynamically reassigned.',
    },
    {
      'username': 'tester3',
      'date': '2025-11-18 08:55:46',
      'type': 'triton',
      'detail': 'BLS chain',
      'description': 'Batch ensemble executed across 3 models.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-18 18:23:31',
      'type': 'server',
      'detail': 'disk warning',
      'description': 'Disk cleanup performed successfully.',
    },
    {
      'username': 'tester5',
      'date': '2025-11-19 10:05:25',
      'type': 'triton',
      'detail': 'health check',
      'description': 'All models passed performance test.',
    },
    {
      'username': 'tester4',
      'date': '2025-11-20 20:48:02',
      'type': 'server',
      'detail': 'CPU overload',
      'description': 'Temporary slowdown detected under high load.',
    },
  ];

  /// 필터링 결과 (UI에 바인딩)
  final RxList<Map<String, dynamic>> filteredLogs = <Map<String, dynamic>>[].obs;

  /// 필터 적용
  Future<void> applyFilter() async {
    // 터미널 로그 -> 삭제 예정
    print('🟦 [applyFilter]');
    print(' serverName : ${serverName.value}');
    print(' startDate : ${startDate.value}');
    print(' endDate   : ${endDate.value}');
    print(' sort      : ${sort.value}');
    print(' keyword   : ${keyword.value}');

    if (serverName.value.isEmpty) {
      filteredLogs.clear(); // 아무것도 표시 안 함
      return;
    }

    final field = _mapSortToField(sort.value);

    final filtered = dummyLogs.where((log) {
      final matchesServer = serverName.value.isEmpty || log['type'] == serverName.value;

      // ✅ 선택한 필드 기준으로 검색
      bool matchesKeyword = true;
      if (keyword.value.isNotEmpty) {
        final kw = keyword.value.toLowerCase();
        if (field.isEmpty) {
          // 전체 검색 (모든 주요 필드)
          matchesKeyword =
              (log['username']?.toString().toLowerCase().contains(kw) ?? false) ||
              (log['detail']?.toString().toLowerCase().contains(kw) ?? false) ||
              (log['description']?.toString().toLowerCase().contains(kw) ?? false);
        } else {
          // 특정 필드 검색
          matchesKeyword = log[field]?.toString().toLowerCase().contains(kw) ?? false;
        }
      }

      final logDate = DateTime.parse(log['date']);
      final matchesStart = startDate.value == null || !logDate.isBefore(startDate.value!);
      final matchesEnd = endDate.value == null || !logDate.isAfter(endDate.value!);

      return matchesServer && matchesKeyword && matchesStart && matchesEnd;
    }).toList();

    // RxList에 반영
    filteredLogs.assignAll(filtered);
    print('[FilterControllerServer] ✅ 필터 완료 (${filteredLogs.length}건)');
  }

  String _mapSortToField(String label) {
    switch (label) {
      case 'user name':
        return 'username';
      case 'details':
        return 'detail';
      case 'description':
        return 'description';
      default:
        return ''; // 이제 이 경우엔 "전체 검색"으로 처리됨
    }
  }

  void resetFilter() {
    // 리셋될 때도 디폴트값 지정
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    //logType.value = '';
    keyword.value = '';
    serverName.value = '';
  }
}

// 확장 기능 (다운로드 기능 포함)
extension FilterExportExtension on ServerLogController {
  Future<void> exportFilteredLogsAsTxt() async {
    if (filteredLogs.isEmpty) {
      web.window.alert('No filtered logs to export.');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Server Logs Export ===');
    buffer.writeln('Created at: ${DateTime.now()}');
    buffer.writeln('');

    for (var log in filteredLogs) {
      final date = log['date'].toString().split('.')[0];
      buffer.writeln(' $date | ${log['type']} | ${log['username']}  | ${log['detail']} | ${log['description']}');
      buffer.writeln('');
    }

    final blob = web.Blob(js_util.jsify([buffer.toString()]));

    final url = web.URL.createObjectURL(blob);
    web.HTMLAnchorElement()
      ..href = url
      ..download = 'filtered_logs_${DateTime.now().toIso8601String()}.txt'
      ..click();

    web.URL.revokeObjectURL(url);
  }
}
