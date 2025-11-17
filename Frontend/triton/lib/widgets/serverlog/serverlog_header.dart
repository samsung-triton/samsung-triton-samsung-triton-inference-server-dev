import 'package:flutter/material.dart';
import 'package:triton/widgets/modellog/DownloadIconButton.dart';
import 'package:triton/widgets/modellog/dropdown.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';
import 'package:triton/widgets/serverlog/filter_block_server.dart';
import 'package:get/get.dart';
import 'package:triton/controller/server_log/server_log_controller.dart';
import 'package:triton/widgets/serverlog/filter_block_triton.dart';

class ServerLogHeader extends StatefulWidget {
  const ServerLogHeader({super.key});

  @override
  State<ServerLogHeader> createState() => _ServerLogHeaderState();
}

class _ServerLogHeaderState extends State<ServerLogHeader> with SingleTickerProviderStateMixin {
  bool _isFilterOpen = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerLogController>();

    return Column(
      children: [
        const SizedBox(height: 8),

        // 상단 헤더
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //왼쪽 :Model Log + Dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Server Log", style: T.t16(color: black, bold: true)),
                  const SizedBox(width: 12),
                  Dropdown(
                    items: const ['triton', 'server'],
                    width: 160,
                    hintText: "server name",
                    onChanged: (value) {
                      controller.serverName.value = value ?? '';

                      if (value == "triton") {
                        controller.applyFilter();
                      } else if (value == "server") {
                        controller.applyFilter();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  DownloadIconButton(onPressed: controller.exportFilteredLogsAsTxt),
                ],
              ),

              // 오른쪽: filter 토글
              Obx(() {
                if (controller.serverName.value.isEmpty) {
                  return const SizedBox.shrink(); // server name 선택 전에는 숨김
                }

                return GestureDetector(
                  onTap: () => setState(() => _isFilterOpen = !_isFilterOpen),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_isFilterOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: black, size: 24),
                      const SizedBox(width: 2),
                      Text("filter", style: T.t16(color: black)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // 필터 영역 (열리면 아래 컨텐츠 밀림)
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isFilterOpen
              ? Obx(() {
                  final server = controller.serverName.value;

                  if (server == 'triton') {
                    return const FilterBlockTriton();
                  }
                  if (server == 'server') {
                    return const FilterBlockServer();
                  }
                  return const SizedBox.shrink();
                })
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
