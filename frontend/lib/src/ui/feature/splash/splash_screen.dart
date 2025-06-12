import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/helpers/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500), // Tổng thời gian 1.5 giây
      vsync: this,
    );

    // Hiệu ứng scale: logo to dần từ 30% lên 70%
    _scaleAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // Hiệu ứng opacity: fade in rồi fade out
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 50), // Fade in
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 50), // Fade out
    ]).animate(_controller);

    // Hiệu ứng position: dịch chuyển lên giống vị trí trên LoginScreen
    _positionAnimation = Tween<Offset>(
      begin: Offset(0, 0), // Ở giữa
      end: Offset(0, -0.5), // Dịch lên trên (tương ứng với LoginScreen)
    ).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();

    // Chuyển sang LoginScreen sau khi hoàn tất animation
    Timer(Duration(milliseconds: 1500), () {
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _positionAnimation.value * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.telegram,
                        size: AppSizes.iconSizeLarge * 1.5,
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}