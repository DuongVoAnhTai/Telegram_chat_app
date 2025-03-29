import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/helpers/constants.dart';

class EditProfileScreen extends StatelessWidget {
  // Giá trị mặc định (sẽ được thay thế bằng dữ liệu từ backend sau này)
  final String username = "HarryNguyen";
  final String shortName = "harry_n";
  final Map<String, String> profileInfo = {
    "Bio":
        "Game developer with a passion for creating immersive experiences in Flutter and Unity.",
    "Dob": "17/11/2004",
    "PhoneNumber": "+84 123 456 789",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leadingWidth: 90, // Điều chỉnh cho vừa với chữ "Cancel"
        leading: TextButton(
          onPressed: () {
            context.pop(); // Quay lại ProfileScreen
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16), // Căn chỉnh padding
            alignment: Alignment.centerLeft, // Đảm bảo text căn trái
          ),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: AppSizes.fontSizeBody,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print("Done button pressed");
            },
            child: Text(
              "Done",
              style: TextStyle(
                fontSize: AppSizes.fontSizeBody,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spacingMedium,
              ),
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Logic chọn ảnh sẽ được thêm sau
                        print("Set new photo tapped");
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryColor.withOpacity(
                          0.2,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      "Set New Photo",
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeBody,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Username
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Username",
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: TextEditingController(text: username),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: AppSizes.paddingOnly),
                    child: Text(
                      "Enter your name and add an optional profile photo.",
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSubBody,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            // Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Bio",
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: TextEditingController(text: profileInfo["Bio"]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: AppSizes.paddingOnly),
                    child: Text(
                      "You can add a few lines about yourself. Choose who can see your bio in Settings.",
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSubBody,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            // Date of Birth
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    readOnly: true, // Chỉ đọc
                    decoration: InputDecoration(
                      hintText: "Date of Birth",
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    controller: TextEditingController(
                      text: profileInfo["Dob"] ?? "Add new",
                    ),
                    onTap: () {
                      // Logic chỉnh sửa Dob sẽ được thêm sau
                      print("Edit Date of Birth tapped");
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: AppSizes.paddingOnly),
                    child: Text(
                      "Only your contacts can see your birthday.",
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSubBody,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print("Change Number tapped");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingOnly,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              profileInfo["PhoneNumber"] ?? "Add new",
                              style: TextStyle(fontSize: AppSizes.fontSizeBody),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingOnly,
                      ),
                      child: Divider(
                        color: AppColors.textSecondary,
                        thickness: 0.5, // Độ dày của Divider
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        print("Edit Username tapped");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingOnly,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              shortName.isNotEmpty ? "@$shortName" : "Add new",
                              style: TextStyle(fontSize: AppSizes.fontSizeBody),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingLarge),
          ],
        ),
      ),
    );
  }
}
