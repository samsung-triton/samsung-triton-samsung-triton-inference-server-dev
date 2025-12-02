//로그 다운로드 버튼
import 'package:flutter/material.dart';
import 'package:triton/theme/app_colors.dart';

class DownloadIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final double borderRadius;

  const DownloadIconButton({
    super.key,
    required this.onPressed,
    this.size = 16,
    this.iconColor = black,
    this.backgroundColor = white,
    this.borderRadius = 4,
  });

  @override
  State<DownloadIconButton> createState() => _DownloadIconButtonState();
}

class _DownloadIconButtonState extends State<DownloadIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _isHovered ? primaryDarkest : widget.backgroundColor,
            border: Border.all(color: lightGray),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.file_download_outlined, color: _isHovered ? white : widget.iconColor, size: widget.size),
          ),
        ),
      ),
    );
  }
}
