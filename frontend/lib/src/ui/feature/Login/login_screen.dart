import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Hàm kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  void _handleContinue() {
    String email = _emailController.text.trim();
    if (_isValidEmail(email)) {
      // Điều hướng đến GetCodeScreen với tham số email
      context.go('/get-code?email=$email&type=login');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập email hợp lệ")));
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
                  "Sign in to your account",
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeBody,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.spacingLarge),
                TextField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress, // Thay đổi thành email
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(
                      FontAwesomeIcons.envelope,
                      color: AppColors.primaryColor,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _handleContinue, // Gọi hàm xử lý
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
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
                    context.go('/register'); // Điều hướng sang RegisterScreen
                  },
                  child: Text(
                    "Create new account",
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
