import 'package:flutter/material.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const HistoryPage());

  static const _clubText =
      'Benvenuti nel mondo del Real Amis! 🟢⚪🔴\n\n'
      'Nato nel 2020 a Romano Canavese, il club è stato fondato da un gruppo di amici con tanta passione per il calcio. '
      'Il nostro obiettivo? Giocare con entusiasmo, divertirci insieme e portare avanti lo spirito sportivo in ogni partita. '
      'Oggi il Real Amis è un punto di riferimento per gli appassionati di calcio dilettantistico della zona.';

  static const _logoText =
      'Il nostro logo racconta chi siamo: giovane, dinamico e legato al territorio. '
      'I colori del club rappresentano amicizia, determinazione e voglia di crescere. '
      'Non è solo un simbolo sul campo, ma anche un segno di appartenenza per tifosi e giocatori!';

  static const _valuesText =
      'Amicizia, rispetto, impegno e passione sono i valori che guidano ogni nostro allenamento e partita. '
      'Per noi, vincere è bello, ma divertirsi e stare insieme è ancora più importante.';

  static const _communityText =
      'Siamo molto attivi sui social, specialmente Instagram, dove condividiamo risultati, formazioni e momenti di squadra. '
      'La nostra community segue ogni passo della squadra e ci sostiene in ogni partita!';

  final List<Map<String, String>> _timeline = const [
    {
      'year': '2020',
      'event':
          'Fondazione del Real Amis e prima iscrizione al campionato Amatori ACSI.',
      'image': AppVectors.logo,
    },
    {
      'year': '2021',
      'event':
          'Prima stagione completa: crescita del team e prime soddisfazioni.',
      'image': AppVectors.logo,
    },
    {
      'year': '2022',
      'event':
          'Partecipazione attiva sui social e ampliamento della community.',
      'image': AppVectors.logo,
    },
    {
      'year': '2023',
      'event':
          'Consolidamento nel campionato e ampliamento delle attività con i tifosi.',
      'image': AppVectors.logo,
    },
    {
      'year': '2024',
      'event': 'Vittoria del campionato e ampliamento club',
      'image': AppVectors.logo,
    },
    {
      'year': '2025',
      'event': 'Seconda vittoria di fila del campionato e promozione.',
      'image': AppVectors.logo,
    },
    {
      'year': '2026',
      'event': 'Sguardo verso il futuro',
      'image': AppVectors.logo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const AppBarNoNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HistorySection(title: 'Il club', text: _clubText),
            _HistorySection(
              title: 'Il logo',
              text: _logoText,
              imageAsset: AppVectors.logo,
            ),
            _HistorySection(title: 'I valori', text: _valuesText),
            _HistorySection(title: 'Comunità e social', text: _communityText),
            const SizedBox(height: 20),
            Text(
              'Timeline delle stagioni',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _TimelineItem(timelineItem: _timeline),

            const SizedBox(height: 24),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
              style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
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

class _TimelineItem extends StatelessWidget {
  final List<Map<String, String>> timelineItem;

  const _TimelineItem({required this.timelineItem});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDarkMode
        ? AppColors.textDarkSecondary.withValues(alpha: 0.5)
        : AppColors.textLightSecondary.withValues(alpha: 0.5);
    final indicatorColor = isDarkMode ? AppColors.logoGold : AppColors.logoRed;

    return Column(
      children: timelineItem.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLeft = index % 2 == 0;

        return Stack(
          children: [
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 2,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: lineColor),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
              child: Row(
                children: [
                  Expanded(
                    child: isLeft
                        ? _buildTimelineCard(item, indicatorColor, isDarkMode)
                        : const SizedBox(),
                  ),

                  Expanded(
                    child: isLeft
                        ? const SizedBox()
                        : _buildTimelineCard(item, indicatorColor, isDarkMode),
                  ),
                ],
              ),
            ),

            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 8,
              top: 32,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTimelineCard(
    Map<String, String> item,
    Color indicatorColor,
    bool isDarkMode,
  ) {
    final cardColor = isDarkMode ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDarkMode
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['year']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: indicatorColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item['event']!,
              style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
            ),
            if (item['image'] != null) ...[
              const SizedBox(height: 8),
              Image.asset(item['image']!, height: 100, fit: BoxFit.cover),
            ],
          ],
        ),
      ),
    );
  }
}
