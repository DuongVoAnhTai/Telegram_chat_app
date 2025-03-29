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
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePhotoSection(),
            _buildUsernameSection(),
            SizedBox(height: AppSizes.spacingMedium),
            _buildBioSection(),
            SizedBox(height: AppSizes.spacingMedium),
            _buildDateOfBirthSection(),
            SizedBox(height: AppSizes.spacingSmall),
            _buildAdditionalInfoSection(),
            SizedBox(height: AppSizes.spacingLarge),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      leadingWidth: 90,
      leading: _buildCancelButton(context),
      actions: [_buildDoneButton()],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.pop(),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        "Cancel",
        style: TextStyle(fontSize: AppSizes.fontSizeBody, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildDoneButton() {
    return TextButton(
      onPressed: () => print("Done button pressed"),
      child: Text(
        "Done",
        style: TextStyle(fontSize: AppSizes.fontSizeBody, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => print("Set new photo tapped"),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                child: Icon(Icons.camera_alt, size: 40, color: AppColors.primaryColor),
              ),
            ),
            Text("Set New Photo", style: TextStyle(fontSize: AppSizes.fontSizeBody, color: AppColors.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameSection() {
    return _buildTextFieldSection("Username", username, "Enter your name and add an optional profile photo.");
  }

  Widget _buildBioSection() {
    return _buildTextFieldSection("Bio", profileInfo["Bio"], "You can add a few lines about yourself.", maxLines: 3);
  }

  Widget _buildDateOfBirthSection() {
    return _buildReadOnlyTextField(
      "Date of Birth",
      profileInfo["Dob"] ?? "Add new",
      "Only your contacts can see your birthday.",
      onTap: () => print("Edit Date of Birth tapped"),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Column(
          children: [
            _buildInfoItem(profileInfo["PhoneNumber"] ?? "Add new", "Change Number tapped"),
            _buildDivider(),
            _buildInfoItem(shortName.isNotEmpty ? "@$shortName" : "Add new", "Edit Username tapped"),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldSection(String hint, String? value, String helperText, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
            controller: TextEditingController(text: value),
          ),
          Padding(
            padding: EdgeInsets.only(left: AppSizes.paddingOnly),
            child: Text(helperText, style: TextStyle(fontSize: AppSizes.fontSizeSubBody, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTextField(String hint, String value, String helperText, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
            ),
            controller: TextEditingController(text: value),
            onTap: onTap,
          ),
          Padding(
            padding: EdgeInsets.only(left: AppSizes.paddingOnly),
            child: Text(helperText, style: TextStyle(fontSize: AppSizes.fontSizeSubBody, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text, String logMessage) {
    return InkWell(
      onTap: () => print(logMessage),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingOnly, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: AppSizes.fontSizeBody)),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingOnly),
      child: Divider(color: AppColors.textSecondary, thickness: 0.5),
    );
  }

}
