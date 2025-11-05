import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/typography.dart';
import 'package:flutter/services.dart';

class InputMedium extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool enabled;
  final bool hasError;
  final bool readOnly;
  final bool enableInteractiveSelection;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets padding;
  final int maxLength;

  const InputMedium({
    Key? key,
    this.hintText = '',
    this.controller,
    this.enabled = true,
    this.hasError = false,
    this.readOnly = false,
    this.enableInteractiveSelection = true,
    this.width = 200,
    this.height = 24,
    this.borderRadius = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.maxLength = 200,
  }) : super(key: key);

  @override
  State<InputMedium> createState() => _InputMediumState();
}

class _InputMediumState extends State<InputMedium> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Color _borderColor() {
    if (!widget.enabled) return lightGray;
    if (widget.hasError) return statusRed;
    return lightGray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height, // ✅ 높이 고정 가능
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: _borderColor(), width: 1),
      ),
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        keyboardType: TextInputType.text,
        maxLines: 1,
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        style: T.t12(color: darkGray),
        cursorColor: primaryNormal,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: T.t12(color: gray),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }
}
