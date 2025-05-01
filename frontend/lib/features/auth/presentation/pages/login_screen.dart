import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to toggle password visibility
  bool _isPasswordVisible = false;
  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Hàm kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  void _onLogin() {
    print(
      "Email: ${_emailController.text} - Password: ${_passwordController.text}",
    );
    BlocProvider.of<AuthBloc>(context).add(
      LoginEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
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
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: AppColors.textPrimary, // Set text color to black
                  ),
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
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Toggle based on state
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(
                    color: AppColors.textPrimary, // Set text color to black
                  ),
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: Icon(
                      FontAwesomeIcons.lock, // Using FontAwesome icon
                      color: AppColors.primaryColor,
                      size: 20, // Optional: Adjust icon size
                    ),
                    // Suffix icon to toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? FontAwesomeIcons
                                .eyeSlash // Icon when visible
                            : FontAwesomeIcons.eye, // Icon when hidden
                        color: AppColors.textSecondary,
                        size: 18, // Adjust icon size
                      ),
                      onPressed: () {
                        // Update the state to toggle visibility
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: BorderSide.none, // No visible border line
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
                    ), // Adjust padding if needed
                  ),
                ),
                SizedBox(height: AppSizes.spacingMedium),
                BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    // return AuthButton(text: 'Login', onPressed: _onLogin);
                    return SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _onLogin, // Gọi hàm xử lý
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: AppSizes.fontSizeButton,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      // String email = _emailController.text.trim();
                      // // Điều hướng đến GetCodeScreen với tham số email
                      // context.go('/get-code?email=$email&type=login');
                      context.go("/home");
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Vui lòng nhập email và mật khẩu hợp lệ",
                          ),
                        ),
                      );
                    }
                  },
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
    _passwordController.dispose();
    super.dispose();
  }
}
