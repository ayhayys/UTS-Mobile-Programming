import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/match_model.dart';
import '../pages/match_detail_page.dart';
import '../utils/date_format_utils.dart';
import 'team_crest.dart';

void _openDetail(BuildContext context, MatchModel match) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => MatchDetailPage(match: match)),
  );
}

BoxDecoration _tileDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    );

class FixtureTile extends StatelessWidget {
  final MatchModel match;
  const FixtureTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.isLive;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: InkWell(
        onTap: () => _openDetail(context, match),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: _tileDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  if (isLive) ...[
                    const _LiveBadge(),
                    const SizedBox(width: 6),
                    Text(match.liveLabel,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.live)),
                  ] else
                    Text(
                      fixtureLabel(match.kickoff),
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      match.venue.isNotEmpty ? match.venue : match.leagueName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        TeamCrest(team: match.home, size: 34),
                        const SizedBox(width: 8),
                        Flexible(child: _TeamName(match.home.shortName)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      isLive ? match.scoreText : 'VS',
                      style: TextStyle(
                        fontSize: isLive ? 16 : 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(child: _TeamName(match.away.shortName, end: true)),
                        const SizedBox(width: 8),
                        TeamCrest(team: match.away, size: 34),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultTile extends StatelessWidget {
  final MatchModel match;
  const ResultTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: InkWell(
        onTap: () => _openDetail(context, match),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: _tileDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.leagueName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                  Text(
                    shortDate(match.kickoff),
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        TeamCrest(team: match.home, size: 34),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _TeamName(
                            match.home.shortName,
                            bold: match.homeScore > match.awayScore,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      match.scoreText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: _TeamName(
                            match.away.shortName,
                            end: true,
                            bold: match.awayScore > match.homeScore,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TeamCrest(team: match.away, size: 34),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('FT',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamName extends StatelessWidget {
  final String name;
  final bool end;
  final bool bold;
  const _TeamName(this.name, {this.end = false, this.bold = true});

  @override
  Widget build(BuildContext context) {
    return Text(
      name.toUpperCase(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: end ? TextAlign.end : TextAlign.start,
      style: TextStyle(
        fontSize: 12.5,
        height: 1.15,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        color: AppColors.ink,
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.live,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
