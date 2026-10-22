import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/match_detail_model.dart';
import '../models/match_model.dart';
import '../services/football_api_service.dart';
import '../utils/date_format_utils.dart';
import '../widgets/async_state_views.dart';
import '../widgets/formation_pitch.dart';
import '../widgets/team_crest.dart';

class MatchDetailPage extends StatefulWidget {
  final MatchModel match;
  const MatchDetailPage({super.key, required this.match});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  late Future<MatchDetail> _future;

  MatchModel get match => widget.match;

  @override
  void initState() {
    super.initState();
    _future = FootballApiService.instance.getMatchDetail(match);
  }

  void _retry() {
    final f =
        FootballApiService.instance.getMatchDetail(match, forceRefresh: true);
    setState(() {
      _future = f;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Text('Match details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 6),
            _ScoreHeader(match: match),
            const SizedBox(height: 16),
            FutureBuilder<MatchDetail>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 220,
                    child: LoadingView(message: 'Loading match details…'),
                  );
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 260,
                    child: ErrorView(
                      message: friendlyError(snapshot.error),
                      onRetry: _retry,
                    ),
                  );
                }
                return _buildDetail(snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(MatchDetail d) {
    final home = d.lineupFor(home: true);
    final away = d.lineupFor(home: false);
    final hasFormation =
        (home?.formationRows != null) || (away?.formationRows != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!match.isUpcoming) ...[
          const _SectionTitle('MATCH EVENTS'),
          _EventsCard(match: match, events: d.events),
          const SizedBox(height: 18),
        ],
        const _SectionTitle('FORMATION'),
        if (hasFormation)
          FormationPitch(
            homeTeam: match.home,
            awayTeam: match.away,
            home: home,
            away: away,
          )
        else
          _InfoCard(
            match.isUpcoming
                ? 'Lineups are usually announced about an hour before kick-off.'
                : 'Formation data is not available for this match.',
          ),
        const SizedBox(height: 18),
        if ((home?.starters.isNotEmpty ?? false) ||
            (away?.starters.isNotEmpty ?? false)) ...[
          const _SectionTitle('STARTING XI'),
          _LineupCard(match: match, home: home, away: away),
        ],
      ],
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final MatchModel match;
  const _ScoreHeader({required this.match});

  @override
  Widget build(BuildContext context) {
    final showScore = !match.isUpcoming;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  match.leagueName,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ),
              Text(
                match.isLive
                    ? match.liveLabel
                    : (match.isFinished ? 'FT' : fixtureLabel(match.kickoff)),
                style: TextStyle(
                  color: match.isLive ? AppColors.lime : Colors.white60,
                  fontWeight: FontWeight.w800,
                  fontSize: match.isUpcoming ? 12 : 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _HeaderTeam(team: match.home)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  showScore ? match.scoreText : 'VS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: showScore ? 40 : 26,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Expanded(child: _HeaderTeam(team: match.away)),
            ],
          ),
          if (match.venue.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stadium_outlined, size: 14, color: Colors.white54),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${match.venue} • ${shortDate(match.kickoff)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderTeam extends StatelessWidget {
  final Team team;
  const _HeaderTeam({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamCrest(team: team, size: 58),
        const SizedBox(height: 6),
        Text(
          team.shortName.toUpperCase(),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13.5,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;
  const _InfoCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.muted)),
    );
  }
}

class _EventsCard extends StatelessWidget {
  final MatchModel match;
  final List<MatchEventItem> events;
  const _EventsCard({required this.match, required this.events});

  IconData _icon(EventKind k) {
    switch (k) {
      case EventKind.goal:
        return Icons.sports_soccer;
      case EventKind.yellow:
      case EventKind.red:
        return Icons.style_rounded;
      case EventKind.substitution:
        return Icons.swap_vert_rounded;
    }
  }

  Color _color(EventKind k) {
    switch (k) {
      case EventKind.goal:
        return AppColors.ink;
      case EventKind.yellow:
        return const Color(0xFFF5B800);
      case EventKind.red:
        return AppColors.live;
      case EventKind.substitution:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const _InfoCard('No match events recorded.');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (final e in events)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      e.minute,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Icon(_icon(e.kind), size: 18, color: _color(e.kind)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    e.teamId == match.home.id
                        ? match.home.abbr
                        : (e.teamId == match.away.id ? match.away.abbr : ''),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LineupCard extends StatelessWidget {
  final MatchModel match;
  final TeamLineup? home;
  final TeamLineup? away;
  const _LineupCard({required this.match, required this.home, required this.away});

  Widget _column(String title, TeamLineup? lineup, CrossAxisAlignment align) {
    final starters = lineup?.starters ?? const <LineupPlayer>[];
    return Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
          const SizedBox(height: 8),
          for (final p in starters)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                align == CrossAxisAlignment.start
                    ? '${p.jersey}  ${p.name}'
                    : '${p.name}  ${p.jersey}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _column(match.home.shortName.toUpperCase(), home, CrossAxisAlignment.start),
          const SizedBox(width: 12),
          _column(match.away.shortName.toUpperCase(), away, CrossAxisAlignment.end),
        ],
      ),
    );
  }
}
