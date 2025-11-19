import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';
import 'package:web/web.dart' as web;
import 'dart:js_util' as js_util;

class TritonLogItem {
  final String ts;
  final String level;
  final String message;

  const TritonLogItem({required this.ts, required this.level, required this.message});

  factory TritonLogItem.fromJson(Map<String, dynamic> json) {
    //YYYY-MM-DD HH:MM:SS 형태 변환
    final rawDate = json['ts'];

    String formattedDate;
    try {
      final d = DateTime.parse(rawDate);
      //final d = DateTime.parse(rawDate).toLocal();
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

    return TritonLogItem(
      ts: formattedDate,
      level: json['level']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class TritonLogController extends GetxController {
  final tritonlogs = <TritonLogItem>[].obs;

  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // 필터 입력값
  final logLevel = RxnString(); //null 허용
  final keyword = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final modelName = ''.obs;

  final RxString cursor = ''.obs; // 백엔드에서 받은 다음 cursor 값
  final RxBool isLoadingMore = false.obs; // 중복 호출 방지

  String get safeLogevel => logLevel.value ?? ""; //null 안전하게 처리
  String get safeKeyword => keyword.value;
  final RxBool hasMore = true.obs; // 데이터 더 있는지 여부

  /// 필터링 결과 (UI에 바인딩)
  final filteredLogs = <TritonLogItem>[].obs;

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> applyFilter() async {
    cursor.value = '';
    filteredLogs.clear();
    hasMore.value = true;

    await fetchMoreLogs();
  }

  Future<void> fetchMoreLogs() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      final res = await _api.getTritonLog(
        startDate: _formatDate(startDate.value!),
        endDate: _formatDate(endDate.value!),
        level: logLevel.value,
        grobalSearch: keyword.value,
        cursor: cursor.value.isEmpty ? null : cursor.value,
      );

      // 서버 응답에서 logs 추가
      final data = res['data'] ?? {};

      final List<dynamic> raw = data['logs'] ?? [];
      final newLogs = raw.map((e) => TritonLogItem.fromJson(e)).toList();
      filteredLogs.addAll(newLogs);

      final next = data['next_cursor'];

      if (next == null || next == "") {
        hasMore.value = false;
      } else {
        cursor.value = next; // 다음 스크롤 요청시 그대로 사용
      }
    } catch (e) {
      ShowAlert.show(message: "Failed to retrieve Triton logs.");
    }

    isLoadingMore.value = false;
  }

  void resetFilter() {
    // 리셋될 때도 디폴트값 지정
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    logLevel.value = '';
    keyword.value = '';
  }
}

// 로그 다운로드 기능
extension FilterExportExtension on TritonLogController {
  Future<void> exportFilteredLogsAsTxt() async {
    if (filteredLogs.isEmpty) {
      ShowAlert.show(message: "No filtered logs to export.");
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Triton Logs Export ===');
    buffer.writeln('Created at: ${DateTime.now()}');
    buffer.writeln('');

    for (var log in filteredLogs) {
      final date = log.ts;
      buffer.writeln(' $date | ${log.level} | ${log.message}');
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
