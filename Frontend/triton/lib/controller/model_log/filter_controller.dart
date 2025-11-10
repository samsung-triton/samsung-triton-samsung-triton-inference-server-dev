import 'package:get/get.dart';

class FilterController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // 필터 입력값
  final modelName = ''.obs;
  final logLevel = ''.obs;
  final keyword = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  /// 고정된 더미 로그 데이터 (100개)
  final List<Map<String, dynamic>> dummyLogs = [
    {
      'model': 'yolov8-detector',
      'date': '2020-02-26 11:45:01.971002',
      'level': 'INFO',
      'message': 'Model initialized successfully',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Loading weights from checkpoint',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'INFO',
      'message': 'Preprocessing input batch #1',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'WARN',
      'message': 'Low GPU memory detected, switching to half precision',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'ERROR',
      'message': 'Inference failed due to tensor shape mismatch',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'INFO',
      'message': 'TensorRT optimization completed',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Batch size: 16, Input resolution: 640x640',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'INFO',
      'message': 'Inference completed in 24ms',
    },

    // 🔵 resnet-50
    {
      'model': 'resnet-50',
      'date': '2025-11-10 11:09:01.971002',
      'level': 'INFO',
      'message': 'Model initialized successfully',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Layer weights loaded: 50/50',
    },
    {'model': 'resnet-50', 'date': '2025-11-08 11:09:01.971002', 'level': 'INFO', 'message': 'Forward pass complete'},
    {'model': 'resnet-50', 'date': '2025-11-08 11:09:01.971002', 'level': 'WARN', 'message': 'CPU fallback triggered'},
    {
      'model': 'resnet-50',
      'date': '2025-11-07 11:09:01.971002',
      'level': 'ERROR',
      'message': 'NaN value detected in output tensor',
    },

    // 🟣 llama-3
    {
      'model': 'llama-3',
      'date': '2025-11-10 11:09:01.971002',
      'level': 'INFO',
      'message': 'Language model loaded successfully',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Tokenizer initialized with 32K vocab',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'INFO',
      'message': 'Response generated in 1.2s',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'WARN',
      'message': 'Token overflow in sentence #43',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'ERROR',
      'message': 'Attention layer dimension mismatch',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-07 11:09:01.971002',
      'level': 'INFO',
      'message': 'Cache updated for new vocabulary',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-07 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Batch tokenization took 56ms',
    },

    // 🟠 custom-ensemble
    {
      'model': 'custom-ensemble',
      'date': '2025-11-10 11:09:01.971002',
      'level': 'INFO',
      'message': 'Pipeline initialized',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Sub-model A weights loaded',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'INFO',
      'message': 'Ensemble inference started',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-06 11:09:01.971002',
      'level': 'WARN',
      'message': 'Sub-model B returned empty tensor',
    },
  ];

  /// 필터링 결과 (UI에 바인딩)
  final RxList<Map<String, dynamic>> filteredLogs = <Map<String, dynamic>>[].obs;

  /// 필터 적용
  Future<void> applyFilter() async {
    // 터미널 로그 -> 삭제 예정
    print('🟦 [applyFilter]');
    print(' modelName : ${modelName.value}');
    print(' startDate : ${startDate.value}');
    print(' endDate   : ${endDate.value}');

    if (modelName.value.isEmpty) {
      filteredLogs.clear(); // 아무것도 표시 안 함
      return;
    }

    final filtered = dummyLogs.where((log) {
      final matchesModel = modelName.value.isEmpty || log['model'] == modelName.value;
      final matchesLevel = logLevel.value.isEmpty || log['level'] == logLevel.value;
      final matchesKeyword =
          keyword.value.isEmpty || log['message'].toLowerCase().contains(keyword.value.toLowerCase());
      final logDate = log['date'] as DateTime;
      final matchesStart = startDate.value == null || !logDate.isBefore(startDate.value!);
      final matchesEnd = endDate.value == null || !logDate.isAfter(endDate.value!);

      return matchesModel && matchesLevel && matchesKeyword && matchesStart && matchesEnd;
    }).toList();

    filteredLogs.assignAll(filtered);
    print('[FilterController] ✅ 필터링 완료 (${filteredLogs.length}건)'); // 필터링 된 갯수 -> 삭제 예정
  }

  void resetFilter() {
    // 리셋될 때도 디폴트값 지정
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    logLevel.value = '';
    keyword.value = '';
    modelName.value = '';
  }
}
