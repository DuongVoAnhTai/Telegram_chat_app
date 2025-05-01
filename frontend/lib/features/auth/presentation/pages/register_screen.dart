import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/helpers/constants.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  bool _isPasswordVisible = false;

  // Hàm kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  void _onRegister() {
    BlocProvider.of<AuthBloc>(context).add(
      RegisterEvent(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  // Hàm xử lý khi nhấn nút Continue
  void _handleContinue() {
    String email = _emailController.text.trim();
    if (_isValidEmail(email)) {
      // Điều hướng đến GetCodeScreen với email
      context.go('/get-code?email=$email&type=register');
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
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: AppColors.textPrimary, // Set text color to black
                  ),
                  decoration: InputDecoration(
                    hintText: "Username",
                    prefixIcon: Icon(
                      FontAwesomeIcons.user, // User icon
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppSizes.spacingMedium,
                ), // Space after username
                // --- Password Field (Added) ---
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(
                    color: AppColors.textPrimary, // Set text color to black
                  ),
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: Icon(
                      FontAwesomeIcons.lock, // Lock icon
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: () {
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
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingMedium),
                BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    // return AuthButton(text: 'Register', onPressed: _onRegister);
                    return SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          "Register",
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
                      // Navigator.pushNamed(context, '/login');
                      context.go("/login");
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Vui lòng nhập email hợp lệ")),
                      );
                    }
                  },
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
