import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String family = 'Cairo';
  static const display = TextStyle(
      fontFamily: family,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      fontVariations: [FontVariation('wght', 700)],
      color: AppColors.ink,
      height: 1.25);
  static const h1 = TextStyle(
      fontFamily: family,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontVariations: [FontVariation('wght', 700)],
      color: AppColors.ink,
      height: 1.57);
  static const h2 = TextStyle(
      fontFamily: family,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontVariations: [FontVariation('wght', 700)],
      color: AppColors.ink,
      height: 1.64);
  static const h3 = TextStyle(
      fontFamily: family,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation('wght', 600)],
      color: AppColors.ink,
      height: 1.78);
  static const title = h2;
  static const heading = h3;
  static const body = TextStyle(
      fontFamily: family,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
      height: 1.75);
  static const bodyMedium = TextStyle(
      fontFamily: family,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation('wght', 600)],
      color: AppColors.ink,
      height: 1.75);
  static const label = TextStyle(
      fontFamily: family,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontVariations: [FontVariation('wght', 500)],
      color: AppColors.ink,
      height: 1.7);
  static const caption = TextStyle(
      fontFamily: family,
      fontSize: 12,
      fontVariations: [FontVariation('wght', 400)],
      color: AppColors.secondary,
      height: 1.67);
  static const button = TextStyle(
      fontFamily: family,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation('wght', 600)],
      color: Colors.white,
      height: 1.4);
}
