//서버 로그 컨트롤러
import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';
import 'package:web/web.dart' as web;
import 'dart:js_util' as js_util;

//서버 로그 아이템 DTO
class ServerLogItem {
  final String date;
  final String username;
  final String type;
  final String description;

  const ServerLogItem({required this.date, required this.username, required this.type, required this.description});

  factory ServerLogItem.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];

    String formattedDate;
    try {
      final d = DateTime.parse(rawDate).toLocal();
      formattedDate =
          "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')} "
          "${d.hour.toString().padLeft(2, '0')}:"
          "${d.minute.toString().padLeft(2, '0')}:"
          "${d.second.toString().padLeft(2, '0')}";
    } catch (_) {
      formattedDate = rawDate;
    }

    return ServerLogItem(
      date: formattedDate,
      username: json['username']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

//서버 로그 필터링 함수
class ServerLogController extends GetxController {
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

  // 필터 입력
  final logType = RxnString();
  final sort = RxnString();
  final keyword = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  String get safeLogType => logType.value ?? "";
  String get safeSort => sort.value ?? "";
  String get safeKeyword => keyword.value;

  // 필터링 결과
  final filteredLogs = <ServerLogItem>[].obs;

  // 페이지네이션 관련 변수
  int currentPage = 1;
  final int pageSize = 200;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  //날짜 포맷팅
  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  //필터 적용 함수
  Future<void> applyFilter() async {
    currentPage = 1;
    hasMore.value = true;
    filteredLogs.clear();

    await fetchMoreLogs();
  }

  //로그 무한 스크롤 처리 함수
  Future<void> fetchMoreLogs() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    try {
      final start = _formatDate(startDate.value!);
      final end = _formatDate(endDate.value!);

      final usernameFilter = safeSort == 'user name' ? safeKeyword : "";
      final descFilter = safeSort == 'description' ? safeKeyword : "";
      final globalFilter = safeSort == 'all' ? safeKeyword : "";

      final res = await _api.getApiLog(
        page: currentPage,
        size: pageSize,
        startDate: start,
        endDate: end,
        type: safeLogType,
        username: usernameFilter,
        description: descFilter,
        grobalSearch: globalFilter,
      );

      //응답 파싱
      final items = res['items'] as List<dynamic>? ?? [];

      if (items.isEmpty) {
        hasMore.value = false;
        isLoading.value = false;
        return;
      }

      final mapped = items.map((e) => ServerLogItem.fromJson(e)).toList();
      filteredLogs.addAll(mapped);

      // 페이지 증가
      currentPage++;
    } catch (e) {
      ShowAlert.show(message: "Failed to retrieve server logs.");
    }

    isLoading.value = false;
  }

  //필터 리셋 함수
  void resetFilter() {
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59);
    logType.value = '';
    sort.value = 'all';
    keyword.value = '';
  }
}

//로그 다운로드 함수
extension FilterExportExtension on ServerLogController {
  Future<void> exportFilteredLogsAsTxt() async {
    if (filteredLogs.isEmpty) {
      web.window.alert('No filtered logs to export.');
      return;
    }

    //파일 내부 양식
    final buffer = StringBuffer();
    buffer.writeln('=== Server Logs Export ===');
    buffer.writeln('Created at: ${DateTime.now()}');
    buffer.writeln('');

    for (var log in filteredLogs) {
      buffer.writeln(' ${log.date} | ${log.type} | ${log.username} | ${log.description}');
      buffer.writeln('');
    }

    final blob = web.Blob(js_util.jsify([buffer.toString()]));

    final url = web.URL.createObjectURL(blob);

    //다운로드 양식 지정
    web.HTMLAnchorElement()
      ..href = url
      ..download = 'Server_logs_${DateTime.now().toIso8601String()}.txt'
      ..click();

    web.URL.revokeObjectURL(url);
  }
}
