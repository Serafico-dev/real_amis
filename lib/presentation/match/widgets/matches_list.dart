import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/widgets/match_card.dart';

class MatchesList extends StatelessWidget {
  final List<MatchEntity> matches;

  const MatchesList({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('matches_list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchCard(
          match: match,
          color: index.isEven ? AppColors.tertiary : AppColors.primary,
        );
      },
    );
  }
}
