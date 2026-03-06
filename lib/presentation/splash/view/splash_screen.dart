import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../../core/route/route_name.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _navigateToNextScreen();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigate to main screen
      // You can add logic here to check for:
      // - First time user -> Onboarding
      // - Logged in user -> Bottom Nav
      // - Not logged in -> Login

      Navigator.pushReplacementNamed(context, RouteName.bottomNavRoute);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorManager.primary, ColorManager.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo Placeholder
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: ColorManager.whiteColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.blackColor.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.flutter_dash,
                        size: 60,
                        color: ColorManager.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App Name
                    Text(
                      AppString.appName,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.whiteColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      AppString.splashSubtitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: ColorManager.whiteColor.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 48.h),

                    // Loading Indicator
                    SizedBox(
                      width: 32.w,
                      height: 32.h,
                      child: CircularProgressIndicator(
                        color: ColorManager.whiteColor,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
