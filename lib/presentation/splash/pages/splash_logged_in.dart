import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/presentation/main/pages/main_page.dart';

class SplashLoggedInPage extends StatefulWidget {
  const SplashLoggedInPage({super.key});

  @override
  State<SplashLoggedInPage> createState() => _SplashLoggedInPageState();
}

class _SplashLoggedInPageState extends State<SplashLoggedInPage> {
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
    Navigator.pushReplacement(context, MainPage.route());
  }
}
