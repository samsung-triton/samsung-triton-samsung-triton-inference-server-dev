import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModalBase extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onClose;

  final double width;
  final double borderRadius;
  final Color backgroundColor;
  final Color titleColor;
  final Color dividerColor;
  final Color borderColor;

  final double? contentSpacing;
  final bool showDivider;

  const ModalBase({
    Key? key,
    required this.title,
    required this.children,
    this.onClose,
    this.width = 428,
    this.borderRadius = 8,
    this.backgroundColor = white,
    this.titleColor = primaryDarker,
    this.dividerColor = primaryDarker,
    this.borderColor = lightGray,
    this.contentSpacing = 16,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            // ───── 제목 + 내용 ─────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ───── 제목 (중앙 정렬) ─────
                Center(
                  child: Text(
                    title,
                    style: T.t20(color: titleColor, bold: true),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 4),

                // ───── 구분선 ─────
                if (showDivider)
                  Center(
                    child: Container(width: width - 32, height: 1, color: dividerColor),
                  ),

                // ───── 본문 간격 ─────
                if (contentSpacing != null) SizedBox(height: contentSpacing),

                // ───── 모달 본문 삽입 영역 ─────
                ...children,
              ],
            ),

            // ───── 오른쪽 상단 X 버튼 (절대 위치) ─────
            Positioned(
              right: 4,
              child: InkWell(
                onTap: onClose ?? () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: SvgPicture.asset(
                  'assets/icons/icon_close.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(gray, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
