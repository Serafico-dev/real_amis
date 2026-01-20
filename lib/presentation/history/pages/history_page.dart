import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const HistoryPage());

  static const _loremShort =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec dignissim justo sed faucibus dictum. Suspendisse pellentesque id nunc et rhoncus. Sed non tincidunt purus. Sed faucibus, est eget egestas euismod, dui quam varius quam, et aliquam lectus sapien non felis.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarNoNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _HistorySection(title: 'Il club', text: _loremShort),
            _HistorySection(
              title: 'Il logo',
              text: _loremShort,
              imageAsset: AppVectors.logo,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final String title;
  final String text;
  final String? imageAsset;

  const _HistorySection({
    required this.title,
    required this.text,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final cardColor = isDarkMode ? AppColors.cardDark : AppColors.cardLight;
    final titleColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final textColor = isDarkMode
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(color: textColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (imageAsset != null) ...[
              const SizedBox(height: 16),
              Image.asset(imageAsset!, height: 200),
            ],
          ],
        ),
      ),
    );
  }
}
