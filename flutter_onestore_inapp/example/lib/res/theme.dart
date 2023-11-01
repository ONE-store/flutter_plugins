import 'package:flutter/material.dart';
import 'colors.dart';

class AppThemes {
  static const titleTextTheme = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: AppColors.primaryText
  );

  static const bodyPrimaryTextTheme = TextStyle(
    fontSize: 14,
    color: AppColors.primaryText
  );

  static const bodySecondaryTextTheme = TextStyle(
      fontSize: 14,
      color: AppColors.secondaryText
  );
}