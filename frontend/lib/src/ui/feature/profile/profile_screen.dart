import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:http/retry.dart';

class ProfileScreen extends StatelessWidget {
  final String username = "HarryNguyen";
  final bool isOnline = true;
  final Map<String, String> profileInfo = {
    "Bio":
        "Game developer with a passion for creating immersive experiences in Unity.",
    "Phone": "+84 123 456 789",
    "Email": "harrynguyen@example.com",
    "Dob": "17/11/2004",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topBarSection(context),
              // Thông tin người dùng
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.padding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar
                    _avatarSection(),
                    SizedBox(height: AppSizes.spacingMedium),
                    // Tên người dùng
                    _nameUserSection(),
                    // Trạng thái hoạt động
                    _activeStatusSection(),
                    SizedBox(height: AppSizes.spacingSmall),
                    Divider(color: AppColors.textSecondary),
                    SizedBox(height: AppSizes.spacingSmall),
                    _bioSection(),
                    SizedBox(height: AppSizes.spacingMedium),
                    _informationUserSection(),
                    // Các thông tin còn lại (Phone, Email, Dob)
                    SizedBox(
                      height: AppSizes.spacingLarge,
                    ), // Khoảng trống cuối
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _topBarSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              context.push('/edit-profile');
            },
            child: Text(
              "Edit",
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Center _avatarSection() {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.primaryColor,
        child: Text(
          username[0],
          style: TextStyle(
            fontSize: AppSizes.fontSizeTitle,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Center _nameUserSection() {
    return Center(
      child: Text(
        username,
        style: TextStyle(
          fontSize: AppSizes.fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Center _activeStatusSection() {
    return Center(
      child: Text(
        isOnline ? "Online" : "Offline",
        style: TextStyle(
          fontSize: AppSizes.fontSizeBody,
          color: isOnline ? Colors.green : AppColors.textSecondary,
        ),
      ),
    );
  }

  Column _bioSection() {
    return Column(
      children: [
        Center(
          child: Text(
            "Bio",
            style: TextStyle(
              fontSize: AppSizes.fontSizeBody,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: AppSizes.spacingSmall),
        Center(
          child: Text(
            textAlign: TextAlign.center,
            profileInfo["Bio"]!,
            style: TextStyle(
              fontSize: AppSizes.fontSizeBody,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Column _informationUserSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Phone",
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              profileInfo["Phone"]!,
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Email",
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              profileInfo["Email"]!,
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Dob",
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              profileInfo["Dob"]!,
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
