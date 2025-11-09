import 'package:get/get.dart';

class DashboardItem {
  final int id;
  final String name;

  /// 서버 활성화 여부 (대시보드에서 선택 or 실행 중)
  final bool isActive;

  /// Triton 상태 (READY / UNAVAILABLE)
  final bool isReady;

  /// CPU / GPU 사용률
  final double cpuUsage;
  final double gpuUsage;

  const DashboardItem({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isReady,
    required this.cpuUsage,
    required this.gpuUsage,
  });

  DashboardItem copyWith({int? id, String? name, bool? isActive, bool? isReady, double? cpuUsage, double? gpuUsage}) {
    return DashboardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isReady: isReady ?? this.isReady,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      gpuUsage: gpuUsage ?? this.gpuUsage,
    );
  }
}

class DashboardController extends GetxController {
  /// 전체 서버 리스트
  final servers = <DashboardItem>[].obs;

  /// 현재 선택된 서버 ID
  final selectedId = RxnInt();

  /// 현재 선택된 메뉴 (서버 / 모델 / 앙상블)
  /// 'server' / 'model1' / 'model2' / 'ensemble1' 등
  final selectedMenu = 'server'.obs;

  /// 초기 로드 (서버 상태 불러오기)
  Future<void> loadServers() async {
    // TODO: 실제 Triton API 연동 (지금은 더미 데이터)
    final dummy = List.generate(
      4,
      (i) => DashboardItem(
        id: i + 1,
        name: i < 2 ? "Model ${i + 1}" : "Ensemble ${i - 1}",
        isActive: i == 0, // 첫 번째 서버만 활성화
        isReady: i % 3 != 0, // 일부는 READY, 일부는 UNAVAILABLE
        cpuUsage: 30 + (i * 8) % 70,
        gpuUsage: 20 + (i * 10) % 80,
      ),
    );
    servers.assignAll(dummy);

    if (servers.isNotEmpty) {
      selectServer(servers.first.id);
    }
  }

  /// 서버 선택 (기존)
  void selectServer(int id) {
    selectedId.value = id;
  }

  /// ✅ 메뉴 변경 (서버 ↔ 모델/앙상블)
  void changeMenu(String menu) {
    selectedMenu.value = menu;
  }

  /// ✅ 서버 추가 (더미)
  void addServer() {
    final newId = (servers.isEmpty ? 1 : servers.last.id + 1);
    servers.add(
      DashboardItem(id: newId, name: "Server-$newId", isActive: true, isReady: true, cpuUsage: 0, gpuUsage: 0),
    );
  }

  /// ✅ 선택된 메뉴가 서버인지 여부 확인
  bool get isServerView => selectedMenu.value == 'server';

  @override
  void onInit() {
    super.onInit();
    loadServers(); // 시작 시 1회 로딩
  }
}
