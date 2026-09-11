import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.35,
    );
  }

  static TextStyle heading1(Color color) => _base(size: 28, weight: FontWeight.w700, color: color);
  static TextStyle heading2(Color color) => _base(size: 22, weight: FontWeight.w700, color: color);
  static TextStyle heading3(Color color) => _base(size: 18, weight: FontWeight.w600, color: color);
  static TextStyle bodyLarge(Color color) => _base(size: 16, weight: FontWeight.w400, color: color);
  static TextStyle bodyMedium(Color color) => _base(size: 14, weight: FontWeight.w400, color: color);
  static TextStyle bodySmall(Color color) => _base(size: 12, weight: FontWeight.w400, color: color);
  static TextStyle button(Color color) => _base(size: 15, weight: FontWeight.w600, color: color);

  static const TextStyle heading1Static = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary);
}