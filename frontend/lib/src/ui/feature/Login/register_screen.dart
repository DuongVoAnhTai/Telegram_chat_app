import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/helpers/constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Hàm kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  // Hàm xử lý khi nhấn nút Continue
  void _handleContinue() {
    String email = _emailController.text.trim();
    if (_isValidEmail(email)) {
      // Điều hướng đến GetCodeScreen với email
      context.go('/get-code?email=$email&type=register');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập email hợp lệ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSizes.spacingLarge * 2),
                Icon(
                  Icons.telegram,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: AppSizes.spacingSmall),
                Text(
                  "Telegram lite",
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeTitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.spacingSmall / 2),
                Text(
                  "Create a new account",
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeBody,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.spacingLarge),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(FontAwesomeIcons.envelope, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeButton,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingSmall),
                TextButton(
                  onPressed: () {
                    context.go('/login'); // Quay lại LoginScreen
                  },
                  child: Text(
                    "Already have an account? Sign in",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: AppSizes.fontSizeBody,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}