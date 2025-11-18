//전체 컨트롤러

import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';

class TritonInferLogController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();

  final modelList = <String>[].obs; // 드롭다운 표시용 모델 리스트

  @override
  void onInit() {
    super.onInit();
    fetchLogModelList();
  }

  /// 로그 필터용 모델 목록 API 호출
  Future<void> fetchLogModelList() async {
    try {
      final data = await _api.getLogModelList();

      if (data is String) {
        // Alert 테스트 해야함
        ShowAlert.show(message: data);
      }

      final List<String> fetched = (data['models'] as List).map((e) => e.toString()).toList();

      modelList.assignAll(fetched);

      if (!modelList.contains('triton')) {
        modelList.add('triton');
      }
    } catch (e) {
      //print("❌ getLogModelList() 에러: $e");
    }
  }
}
