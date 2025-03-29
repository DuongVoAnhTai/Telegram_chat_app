import 'package:flutter/material.dart';
import 'package:frontend/core/helpers/constants.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Settings Page",
        style: TextStyle(
          fontSize: AppSizes.fontSizeTitle,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}