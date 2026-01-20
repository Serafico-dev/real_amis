import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/presentation/main/pages/main_page.dart';

class SplashLoggedInPage extends StatefulWidget {
  const SplashLoggedInPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const SplashLoggedInPage());

  @override
  State<SplashLoggedInPage> createState() => _SplashLoggedInPageState();
}

class _SplashLoggedInPageState extends State<SplashLoggedInPage>
    with SingleTickerProviderStateMixin {
  static const _logoWidth = 250.0;
  static const _fadeDuration = Duration(milliseconds: 800);
  static const _splashDuration = Duration(seconds: 2);

  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fadeDuration);
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.bgDark : AppColors.bgLight,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Image.asset(AppVectors.logo, width: _logoWidth),
        ),
      ),
    );
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(_splashDuration);
    if (!mounted) return;
    Navigator.pushReplacement(context, MainPage.route());
  }
}
