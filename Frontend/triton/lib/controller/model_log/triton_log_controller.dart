//Triton 로그 컨트롤러
import 'package:get/get.dart';
import 'package:web/web.dart' as web;
import 'dart:js_util' as js_util;

class TritonLogController extends GetxController {
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
    // yolov8-detector
    {
      'model': 'yolov8-detector',
      'date': '2025-11-01 09:15:22.104512',
      'level': 'INFO',
      'message': 'Model initialized successfully',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-01 10:45:33.712400',
      'level': 'DEBUG',
      'message': 'Loading weights from checkpoint',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-02 08:13:41.982112',
      'level': 'INFO',
      'message': 'Preprocessing input batch #1',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-02 11:57:10.774501',
      'level': 'WARN',
      'message': 'Low GPU memory detected, switching to half precision',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-03 14:02:18.441220',
      'level': 'ERROR',
      'message': 'Inference failed due to tensor shape mismatch',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-03 17:29:47.221932',
      'level': 'INFO',
      'message': 'TensorRT optimization completed',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-04 09:44:03.872210',
      'level': 'DEBUG',
      'message': 'Batch size: 16, Input resolution: 640x640',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-04 13:11:26.974332',
      'level': 'INFO',
      'message': 'Inference completed in 24ms',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-05 09:20:58.711009',
      'level': 'INFO',
      'message': 'Exported ONNX model to /models/yolov8.onnx',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-05 11:44:30.882112',
      'level': 'WARN',
      'message': 'Detected empty input tensor in batch #5',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-06 08:59:12.114002',
      'level': 'INFO',
      'message': 'Running inference on validation dataset',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-06 15:22:40.842992',
      'level': 'DEBUG',
      'message': 'Validation accuracy: 92.3%',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-07 10:33:21.711041',
      'level': 'INFO',
      'message': 'Quantization aware training started',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-07 14:09:00.513932',
      'level': 'WARN',
      'message': 'Gradient overflow detected, applying scaler',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-08 09:11:59.871022',
      'level': 'ERROR',
      'message': 'Failed to load calibration dataset',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-08 13:55:18.232002',
      'level': 'INFO',
      'message': 'Reverted to previous checkpoint version',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Profiling inference latency per layer',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-10 10:45:02.554002',
      'level': 'INFO',
      'message': 'Batch inference completed successfully',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-10 14:31:21.872112',
      'level': 'ERROR',
      'message': 'Invalid tensor dimensions during concatenation',
    },
    {
      'model': 'yolov8-detector',
      'date': '2025-11-11 09:12:48.321222',
      'level': 'INFO',
      'message': 'Model shutdown and resources released',
    },
    // 🔵 resnet-50
    {
      'model': 'resnet-50',
      'date': '2025-11-01 09:30:12.671002',
      'level': 'INFO',
      'message': 'Model initialized successfully',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-02 10:15:43.971002',
      'level': 'DEBUG',
      'message': 'Layer weights loaded: 50/50',
    },
    {'model': 'resnet-50', 'date': '2025-11-02 11:50:11.971002', 'level': 'INFO', 'message': 'Forward pass complete'},
    {'model': 'resnet-50', 'date': '2025-11-03 14:25:05.971002', 'level': 'WARN', 'message': 'CPU fallback triggered'},
    {
      'model': 'resnet-50',
      'date': '2025-11-03 16:39:20.971002',
      'level': 'ERROR',
      'message': 'NaN value detected in output tensor',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-04 09:10:35.971002',
      'level': 'INFO',
      'message': 'Batch normalization layers updated',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-04 12:33:49.971002',
      'level': 'DEBUG',
      'message': 'Gradient accumulation step: 4/8',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-05 10:22:41.971002',
      'level': 'INFO',
      'message': 'Loss value stabilized at 0.023',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-05 15:45:13.971002',
      'level': 'WARN',
      'message': 'Learning rate too high, applying decay schedule',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-06 09:12:54.971002',
      'level': 'INFO',
      'message': 'Evaluation mode activated',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-06 11:59:21.971002',
      'level': 'DEBUG',
      'message': 'Batch size: 32, Input resolution: 224x224',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-07 14:18:17.971002',
      'level': 'ERROR',
      'message': 'Overflow in gradient tensor detected',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-07 17:55:48.971002',
      'level': 'INFO',
      'message': 'Checkpoints saved successfully',
    },
    {'model': 'resnet-50', 'date': '2025-11-08 09:47:03.971002', 'level': 'INFO', 'message': 'Forward pass complete'},
    {'model': 'resnet-50', 'date': '2025-11-08 11:09:01.971002', 'level': 'WARN', 'message': 'CPU fallback triggered'},
    {
      'model': 'resnet-50',
      'date': '2025-11-09 09:11:54.971002',
      'level': 'DEBUG',
      'message': 'Weight gradients clipped (threshold=0.1)',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'INFO',
      'message': 'Training step #340 completed',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-10 10:58:33.971002',
      'level': 'INFO',
      'message': 'Validation accuracy reached 94.8%',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-10 11:09:01.971002',
      'level': 'INFO',
      'message': 'Model initialized successfully',
    },
    {
      'model': 'resnet-50',
      'date': '2025-11-11 09:59:10.971002',
      'level': 'INFO',
      'message': 'Model shutdown and GPU resources released',
    },

    // 🟣 llama-3
    {
      'model': 'llama-3',
      'date': '2025-11-01 09:10:01.971002',
      'level': 'INFO',
      'message': 'Language model loaded successfully',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-01 11:32:42.971002',
      'level': 'DEBUG',
      'message': 'Tokenizer initialized with 32K vocab',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-02 10:24:15.971002',
      'level': 'INFO',
      'message': 'Prompt processed: 128 tokens',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-02 13:11:33.971002',
      'level': 'DEBUG',
      'message': 'Batch tokenization took 56ms',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-03 09:44:12.971002',
      'level': 'INFO',
      'message': 'Response generated in 1.2s',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-03 12:51:44.971002',
      'level': 'WARN',
      'message': 'Token overflow in sentence #43',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-04 10:39:09.971002',
      'level': 'ERROR',
      'message': 'Attention layer dimension mismatch',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-04 15:12:28.971002',
      'level': 'INFO',
      'message': 'Cache updated for new vocabulary',
    },
    {'model': 'llama-3', 'date': '2025-11-05 09:27:35.971002', 'level': 'DEBUG', 'message': 'KV cache hits: 92.4%'},
    {
      'model': 'llama-3',
      'date': '2025-11-05 14:10:51.971002',
      'level': 'INFO',
      'message': 'Inference completed with temperature=0.7',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-06 10:55:03.971002',
      'level': 'WARN',
      'message': 'Context length exceeded 8192 tokens',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-06 13:22:47.971002',
      'level': 'INFO',
      'message': 'Sampling method switched to nucleus (top_p=0.9)',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-07 09:18:22.971002',
      'level': 'DEBUG',
      'message': 'Batch tokenization took 56ms',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-07 11:09:01.971002',
      'level': 'INFO',
      'message': 'Cache updated for new vocabulary',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-08 09:59:55.971002',
      'level': 'ERROR',
      'message': 'Attention layer dimension mismatch',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'WARN',
      'message': 'Token overflow in sentence #43',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-09 10:30:02.971002',
      'level': 'INFO',
      'message': 'Response generated in 1.2s',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Tokenizer initialized with 32K vocab',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-10 11:09:01.971002',
      'level': 'INFO',
      'message': 'Language model loaded successfully',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-11 09:19:44.971002',
      'level': 'INFO',
      'message': 'Session closed and memory released',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-12 09:19:44.971002',
      'level': 'INFO',
      'message':
          'Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released. Session closed and memory released.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-11 09:19:44.971002',
      'level': 'INFO',
      'message': 'Session closed and memory released',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-12 10:25:12.512341',
      'level': 'DEBUG',
      'message': 'Model checkpoint successfully loaded from cache.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-13 14:42:07.923411',
      'level': 'INFO',
      'message': 'Inference started with batch size 16.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-14 21:58:31.114009',
      'level': 'WARN',
      'message': 'Token overflow detected — sequence truncated.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-15 11:09:44.443002',
      'level': 'INFO',
      'message': 'Session initialized on GPU:0 with mixed precision.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-16 08:33:25.111542',
      'level': 'DEBUG',
      'message': 'Optimizer state restored successfully.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-17 19:12:54.994003',
      'level': 'INFO',
      'message': 'Evaluation completed on validation set (loss=0.037).',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-18 22:08:47.000001',
      'level': 'ERROR',
      'message': 'CUDA out of memory — attempted allocation 1.2GB.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-19 07:42:33.231222',
      'level': 'INFO',
      'message': 'Model parameters updated after gradient accumulation.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-20 17:20:41.871992',
      'level': 'INFO',
      'message': 'Batch normalization statistics synchronized across GPUs.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-21 09:45:13.651234',
      'level': 'DEBUG',
      'message': 'Tokenizer vocabulary reloaded from disk.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-22 13:31:12.432554',
      'level': 'INFO',
      'message': 'Model compiled with optimization level O2.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-23 18:03:22.991002',
      'level': 'WARN',
      'message': 'Throughput degraded: inference latency exceeded threshold.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-24 07:50:09.241002',
      'level': 'INFO',
      'message': 'Pipeline parallelism initialized (4 stages).',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-25 16:02:41.071002',
      'level': 'INFO',
      'message': 'Session checkpoint saved successfully to /checkpoints/',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-26 11:29:05.811002',
      'level': 'DEBUG',
      'message': 'Graph optimization pass took 0.028s.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-27 20:12:44.971002',
      'level': 'INFO',
      'message': 'Weights quantized to INT8 for deployment.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-28 09:45:57.231002',
      'level': 'WARN',
      'message': 'Minor precision loss detected during quantization.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-29 22:19:11.514002',
      'level': 'INFO',
      'message': 'User session timeout after 30 minutes of inactivity.',
    },
    {
      'model': 'llama-3',
      'date': '2025-11-30 15:33:59.114002',
      'level': 'INFO',
      'message': 'Inference service stopped and GPU memory released.',
    },

    // 🟠 custom-ensemble
    {
      'model': 'custom-ensemble',
      'date': '2025-11-01 09:12:01.971002',
      'level': 'INFO',
      'message': 'Pipeline initialized',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-01 10:35:22.971002',
      'level': 'DEBUG',
      'message': 'Sub-model A weights loaded',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-02 09:44:18.971002',
      'level': 'INFO',
      'message': 'Sub-model B initialized with config v1.3',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-02 11:19:41.971002',
      'level': 'DEBUG',
      'message': 'Sub-model C weights verified (SHA256 ok)',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-03 09:21:03.971002',
      'level': 'INFO',
      'message': 'Ensemble inference started',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-03 13:09:55.971002',
      'level': 'INFO',
      'message': 'Model A→B→C sequence configured',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-04 08:57:44.971002',
      'level': 'DEBUG',
      'message': 'Batch input distributed to sub-models',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-04 11:48:27.971002',
      'level': 'WARN',
      'message': 'Sub-model B returned empty tensor',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-05 10:33:14.971002',
      'level': 'ERROR',
      'message': 'Fusion layer dimension mismatch detected',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-05 14:52:38.971002',
      'level': 'INFO',
      'message': 'Fallback path activated (Model C only)',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-06 11:09:01.971002',
      'level': 'WARN',
      'message': 'Sub-model B returned empty tensor',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-06 15:26:09.971002',
      'level': 'DEBUG',
      'message': 'Intermediate outputs cached for analysis',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-07 09:42:32.971002',
      'level': 'INFO',
      'message': 'Fusion node output verified successfully',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-07 12:18:57.971002',
      'level': 'DEBUG',
      'message': 'Latency per model: A=22ms, B=31ms, C=18ms',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-08 11:09:01.971002',
      'level': 'INFO',
      'message': 'Ensemble inference started',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-08 14:40:44.971002',
      'level': 'ERROR',
      'message': 'Output tensor fusion failed at node #7',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-09 11:09:01.971002',
      'level': 'DEBUG',
      'message': 'Sub-model A weights loaded',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-09 13:23:17.971002',
      'level': 'INFO',
      'message': 'Pipeline validation accuracy: 93.1%',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-10 11:09:01.971002',
      'level': 'INFO',
      'message': 'Pipeline initialized',
    },
    {
      'model': 'custom-ensemble',
      'date': '2025-11-11 09:59:33.971002',
      'level': 'INFO',
      'message': 'Pipeline shutdown and cache cleared',
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
      final logDate = DateTime.parse(log['date']);
      final matchesStart = startDate.value == null || !logDate.isBefore(startDate.value!);
      final matchesEnd = endDate.value == null || !logDate.isAfter(endDate.value!);

      return matchesModel && matchesLevel && matchesKeyword && matchesStart && matchesEnd;
    }).toList();

    filteredLogs.assignAll(filtered);
    print('[FilterController] ✅ 필터 완료 (${filteredLogs.length}건)'); // 필터링 된 갯수 -> 삭제
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

// 확장 기능 (다운로드 기능 포함)
extension FilterExportExtension on TritonLogController {
  Future<void> exportFilteredLogsAsTxt() async {
    if (filteredLogs.isEmpty) {
      web.window.alert('No filtered logs to export.');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Logs Export ===');
    buffer.writeln('Created at: ${DateTime.now()}');
    buffer.writeln('');

    for (var log in filteredLogs) {
      final date = log['date'].toString().split('.')[0];
      buffer.writeln('${log['model']} | $date | [${log['level']}] | ${log['message']}');
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
