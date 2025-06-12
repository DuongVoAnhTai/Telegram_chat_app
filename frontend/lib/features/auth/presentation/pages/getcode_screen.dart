import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:go_router/go_router.dart';

class GetCodeScreen extends StatefulWidget {
  final String email;
  final String type; // Thêm type để phân biệt login/register

  GetCodeScreen({required this.email, required this.type});

  @override
  _GetCodeScreenState createState() => _GetCodeScreenState();
}

class _GetCodeScreenState extends State<GetCodeScreen> {
  final int _otpLength = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  // Biến cho bộ đếm ngược
  Timer? _timer;
  int _countdownSeconds = 120; // 2 phút = 120 giây
  bool _isResendEnabled = true; // Ban đầu có thể nhấn Resend ngay

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    // Không gọi _startCountdown ở đây để cho phép Resend ngay từ đầu
  }

  // Hàm bắt đầu đếm ngược
  void _startCountdown() {
    setState(() {
      _isResendEnabled = false;
      _countdownSeconds = 120;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  // Hàm xử lý khi nhấn nút Verify
  void _handleVerify() {
    String code = _controllers.map((controller) => controller.text).join();
    if (code.length == _otpLength) {
      // In ra type để kiểm tra, sau này có thể gửi lên backend
      print("Mã OTP hợp lệ: $code, Type: ${widget.type}");
      // Ví dụ: Gửi lên backend với email và type
      // await api.verifyOtp(email: widget.email, code: code, type: widget.type);
      context.go('/home');

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đủ $_otpLength ký tự")),
      );
    }
  }

  // Hàm xử lý khi nhấn Resend code
  void _handleResend() {
    if (_isResendEnabled) {
      print("Resend code");
      _startCountdown(); // Bắt đầu đếm ngược sau khi nhấn
    }
  }

  // Hàm định dạng thời gian đếm ngược
  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
                  "Enter the code we just sent to",
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeBody,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeBody,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSizes.spacingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_otpLength, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          counterText: "",
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.length == 1 && index < _otpLength - 1) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index - 1]);
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: AppSizes.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeButton,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingSmall),
                TextButton(
                  onPressed: _handleResend,
                  child: Text(
                    _isResendEnabled
                        ? "Resend code"
                        : "Resend code (${_formatCountdown(_countdownSeconds)})",
                    style: TextStyle(
                      color:
                          _isResendEnabled
                              ? AppColors.primaryColor
                              : AppColors.textSecondary,
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
    _timer?.cancel(); // Hủy timer khi dispose
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
