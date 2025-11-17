import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';
import 'package:web/web.dart' as web;
import 'dart:js_util' as js_util;

class ServerLogItem {
  final String date;
  final String username;
  final String type;
  final String description;

  const ServerLogItem({required this.date, required this.username, required this.type, required this.description});

  factory ServerLogItem.fromJson(Map<String, dynamic> json) {
    //YYYY-MM-DD HH:MM:SS 형태 변환
    final rawDate = json['date']?.toString() ?? '';

    String formattedDate;
    try {
      final d = DateTime.parse(rawDate);
      formattedDate =
          "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')} "
          "${d.hour.toString().padLeft(2, '0')}:"
          "${d.minute.toString().padLeft(2, '0')}:"
          "${d.second.toString().padLeft(2, '0')}";
    } catch (_) {
      formattedDate = rawDate; // 파싱 실패하면 raw 그대로
    }

    return ServerLogItem(
      date: formattedDate,
      username: json['username']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class ServerLogController extends GetxController {
  final serverlogs = <ServerLogItem>[].obs;

  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    sort.value = 'all'; // sort 드롭다운 미선택시 디폴트 all
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // 필터 입력값
  final serverName = ''.obs;
  final logType = RxnString(); //null 허용
  final sort = RxnString();
  final keyword = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  String get safeLogType => logType.value ?? ""; //null 안전하게 처리
  String get safeSort => sort.value ?? "";
  String get safeKeyword => keyword.value;

  /// 필터링 결과 (UI에 바인딩)
  final filteredLogs = <ServerLogItem>[].obs;

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> applyFilter() async {
    if (serverName.value.isEmpty) {
      filteredLogs.clear();
      return;
    }

    if (serverName.value == "server") {
      return getServerLogs();
    } else if (serverName.value == "triton") {
      //return fetchApiLogs(); //triton 함수 작성 후 업데이트 예정
    }
  }

  Future<void> getServerLogs() async {
    final start = _formatDate(startDate.value!);
    final end = _formatDate(endDate.value!);

    try {
      final typeFilter = logType.value ?? "";

      final usernameFilter = safeSort == 'user name' ? safeKeyword : "";
      final descriptionFilter = safeSort == 'description' ? safeKeyword : "";
      final grobalSearchFilter = safeSort == 'all' ? safeKeyword : "";

      final dynamic data = await _api.getApiLog(
        startDate: start,
        endDate: end,
        type: typeFilter,
        username: usernameFilter,
        description: descriptionFilter,
        grobalSearch: grobalSearchFilter,
      );

      if (data is String) {
        // Alert 테스트 해야함
        ShowAlert.show(message: "The filter is invalid. Please check again.");
      }

      final List<dynamic> rawLogs = data as List<dynamic>;

      final fetchedLogs = rawLogs.map((rawLog) => ServerLogItem.fromJson(rawLog)).toList();

      filteredLogs.assignAll(fetchedLogs);
    } catch (e) {
      // Alert 테스트 해야함
      ShowAlert.show(message: "Failed to retrieve server logs.");
    }
  }

  void resetFilter() {
    // 리셋될 때도 디폴트값 지정
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    logType.value = '';
    sort.value = 'all';
    keyword.value = '';
  }
}

// 로그 다운로드 기능
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
      final date = log.date;
      buffer.writeln(' $date | ${log.type} | ${log.username} | ${log.description}');
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
