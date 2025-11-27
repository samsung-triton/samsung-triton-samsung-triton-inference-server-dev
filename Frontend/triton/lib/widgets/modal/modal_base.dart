// 모달 전체 베이스
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:triton/theme/app_colors.dart';
import 'package:triton/theme/typography.dart';

class ModalBase extends StatelessWidget {
  final String title;
  final List<Widget> children;

  final double width;
  final double borderRadius;
  final Color backgroundColor;
  final Color titleColor;
  final Color dividerColor;
  final Color borderColor;

  final double? contentSpacing;
  final bool showDivider;

  const ModalBase({
    super.key,
    required this.title,
    required this.children,
    this.width = 428,
    this.borderRadius = 8,
    this.backgroundColor = white,
    this.titleColor = primaryDarker,
    this.dividerColor = primaryDarker,
    this.borderColor = Colors.transparent,
    this.contentSpacing = 0,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            // 제목 + 내용
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목
                Center(
                  child: Text(
                    title,
                    style: T.t20(color: titleColor, bold: true),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 4),

                // 구분선
                if (showDivider)
                  Center(
                    child: Container(width: width - 32, height: 1, color: dividerColor),
                  ),

                if (contentSpacing != null) SizedBox(height: contentSpacing),

                // 모달 본문 영역
                ...children,
              ],
            ),

            // 오른쪽 상단 X 버튼
            Positioned(
              right: 4,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
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
