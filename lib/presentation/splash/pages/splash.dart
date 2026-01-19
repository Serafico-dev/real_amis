import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/presentation/choose_mode/pages/choose_mode.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const SplashPage());

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _startRedirect();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Image.asset(AppVectors.logo, width: 250),
        ),
      ),
    );
  }

  Future<void> _startRedirect() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(context, ChooseModePage.route());
  }
}
