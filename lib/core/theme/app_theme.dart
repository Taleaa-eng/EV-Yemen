import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.brand,
            primary: AppColors.brand,
            surface: AppColors.surface,
            error: AppColors.error),
        fontFamily: AppTextStyles.family,
        appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            toolbarHeight: 56,
            elevation: 1,
            scrolledUnderElevation: 0,
            shadowColor: Color(0x1F0A240C),
            centerTitle: false,
            titleTextStyle: AppTextStyles.heading,
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18)),
                side: BorderSide(color: AppColors.border))),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            hintStyle:
                const TextStyle(color: AppColors.secondary, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.brand, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5))),
      );
}
