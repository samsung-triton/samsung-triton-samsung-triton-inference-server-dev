//모델 로그 컨트롤러
import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';
import 'package:web/web.dart' as web;
import 'dart:js_util' as js_util;

//모델 로그 아이템 DTO
class ModelLogItem {
  final String ts;
  final String level;
  final String message;
  final String modelName;

  const ModelLogItem({required this.ts, required this.level, required this.message, required this.modelName});

  factory ModelLogItem.fromJson(Map<String, dynamic> json) {
    //YYYY-MM-DD HH:MM:SS 형태 변환
    final rawDate = json['ts'];

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

    return ModelLogItem(
      ts: formattedDate,
      level: json['level']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      modelName: json['model_name']?.toString() ?? '',
    );
  }
}

//모델 로그 필터링 컨트롤러
class ModelLogController extends GetxController {
  //로딩 상태 표시
  final RxBool isLoading = false.obs;

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
  final modelName = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final logLevel = RxnString(); //null 허용
  final keyword = ''.obs;
  final RxString cursor = ''.obs; // 다음 cursor 값

  final RxBool isLoadingMore = false.obs; // 중복 호출 방지

  String get safeLogevel => logLevel.value ?? ""; //null 안전하게 처리
  String get safeKeyword => keyword.value;
  final RxBool hasMore = true.obs; // 데이터 더 있는지 여부

  /// 필터링 결과
  final filteredLogs = <ModelLogItem>[].obs;

  //날짜 포맷팅
  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  //필터 적용 함수
  Future<void> applyFilter() async {
    cursor.value = '';
    filteredLogs.clear();
    hasMore.value = true;

    await fetchMoreLogs();
  }

  //로그 무한 스크롤 처리 함수
  Future<void> fetchMoreLogs() async {
    //더이상 로딩 할 게 없으면 종료
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    isLoading.value = true;

    try {
      final res = await _api.getInferLog(
        modelName: modelName.value,
        startDate: _formatDate(startDate.value!),
        endDate: _formatDate(endDate.value!),
        level: logLevel.value,
        grobalSearch: keyword.value,
        cursor: cursor.value.isEmpty ? "" : cursor.value,
      );

      //응답 파싱
      final data = res['data'] ?? {};

      final List<dynamic> raw = data['logs'] ?? [];
      final newLogs = raw.map((e) => ModelLogItem.fromJson(e)).toList();
      filteredLogs.addAll(newLogs);

      //커서 값 덮어쓰기
      final next = data['next_cursor'];

      if (next == null || next == "") {
        hasMore.value = false;
      } else {
        cursor.value = next;
      }
    } catch (e) {
      ShowAlert.show(message: "Failed to retrieve Triton logs.");
    }

    isLoadingMore.value = false;
    isLoading.value = false;
  }

  //필터 리셋 함수
  void resetFilter() {
    // 디폴트값 지정
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    logLevel.value = '';
    keyword.value = '';
  }
}

// 로그 다운로드
extension FilterExportExtension on ModelLogController {
  Future<void> exportFilteredLogsAsTxt() async {
    if (filteredLogs.isEmpty) {
      ShowAlert.show(message: "No filtered logs to export.");
      return;
    }

    //파일 내 양식
    final buffer = StringBuffer();
    buffer.writeln('=== Model Logs Export ===');
    buffer.writeln('Created at: ${DateTime.now()}');
    buffer.writeln('');

    for (var log in filteredLogs) {
      final date = log.ts;
      buffer.writeln(' $date | ${log.modelName} | ${log.level} | ${log.message}');
      buffer.writeln('');
    }

    final blob = web.Blob(js_util.jsify([buffer.toString()]));

    //다운로드 양식
    final url = web.URL.createObjectURL(blob);
    web.HTMLAnchorElement()
      ..href = url
      ..download = 'filtered_logs_${DateTime.now().toIso8601String()}.txt'
      ..click();

    web.URL.revokeObjectURL(url);
  }
}
