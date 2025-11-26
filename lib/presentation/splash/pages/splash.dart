import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/presentation/choose_mode/pages/choose_mode.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset(AppVectors.logo, width: 250)),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacement(context, ChooseModePage.route());
  }
}
