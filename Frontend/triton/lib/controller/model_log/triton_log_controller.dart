//Triton Log 드롭다운 컨트롤러
import 'package:get/get.dart';
import 'package:triton/utils/api_client.dart';
import 'package:triton/utils/show_alert.dart';

class TritonLogController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();

  final RxList<String> modelList = <String>[].obs;
  final RxString modelName = ''.obs;

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
        ShowAlert.show(message: "Failed to retrieve model list.");
      }

      final List<String> fetched = (data['models'] as List).map((e) => e.toString()).toList();

      modelList.assignAll(['Triton Server', ...fetched]);
    } catch (e) {
      ShowAlert.show(message: "Failed to retrieve model list.");
    }
  }
}
