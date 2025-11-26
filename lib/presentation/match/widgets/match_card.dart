import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/match_viewer.dart';

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final Color color;
  const MatchCard({super.key, required this.match, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MatchViewerPage.route(match.id));
        context.read().add(MatchFetchAllMatches());
      },
      child: Container(
        margin: EdgeInsets.all(16).copyWith(bottom: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  match.matchDay ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            Text(
              formatDateByddMMYYYYnHHmm(match.matchDate),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Image.network(match.homeTeam!.imageUrl, width: 100),
                    SizedBox(height: 10),
                    Text(
                      match.homeTeamScore.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Text(
                  'VS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Column(
                  children: [
                    Image.network(match.awayTeam!.imageUrl, width: 100),
                    SizedBox(height: 10),
                    Text(
                      match.awayTeamScore.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
