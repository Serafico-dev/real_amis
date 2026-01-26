import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:real_amis/presentation/team/pages/edit_team.dart';

class TeamCard extends StatelessWidget {
  final TeamEntity team;
  final Color color;
  final bool isAdmin;
  const TeamCard({
    super.key,
    required this.team,
    required this.color,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return GestureDetector(
      onTap: isAdmin
          ? () async {
              await Navigator.push(context, EditTeamPage.route(team));
              if (context.mounted) {
                context.read<TeamBloc>().add(TeamFetchAllTeams());
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.all(8).copyWith(bottom: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: team.imageUrl,
              cacheKey: team.id,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (_, _) => SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, _, _) => Icon(
                Icons.broken_image,
                size: 64,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              team.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
