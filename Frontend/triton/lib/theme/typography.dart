// 글자 테마 설정
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// 글자 테마 베이스
TextStyle base(double size, {Color? color, bool bold = false}) {
  return GoogleFonts.inter(fontSize: size, color: color ?? black, fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
}

// 글자 크기별 프리셋
class T {
  static TextStyle t8({Color? color, bool bold = false}) => base(8, color: color, bold: bold);
  static TextStyle t10({Color? color, bool bold = false}) => base(10, color: color, bold: bold);
  static TextStyle t12({Color? color, bool bold = false}) => base(12, color: color, bold: bold);
  static TextStyle t16({Color? color, bool bold = false}) => base(16, color: color, bold: bold);
  static TextStyle t20({Color? color, bool bold = false}) => base(20, color: color, bold: bold);
}
