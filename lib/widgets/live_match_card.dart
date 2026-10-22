import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/match_model.dart';
import '../pages/match_detail_page.dart';
import 'team_crest.dart';

class LiveCarousel extends StatefulWidget {
  final List<MatchModel> matches;
  const LiveCarousel({super.key, required this.matches});

  @override
  State<LiveCarousel> createState() => _LiveCarouselState();
}

class _LiveCarouselState extends State<LiveCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.matches.length;
    return Column(
      children: [
        SizedBox(
          height: 226,
          child: PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LiveMatchCard(match: widget.matches[i]),
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count > 6 ? 6 : count, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class LiveMatchCard extends StatelessWidget {
  final MatchModel match;
  const LiveMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final homeGoals =
        match.goals.where((g) => g.teamId == match.home.id).take(3).toList();
    final awayGoals =
        match.goals.where((g) => g.teamId == match.away.id).take(3).toList();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MatchDetailPage(match: match)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _LeagueIcon(url: match.leagueLogo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.leagueName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ),
                Text(
                  match.isLive ? match.liveLabel : 'FT',
                  style: TextStyle(
                    color: match.isLive ? AppColors.lime : Colors.white54,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _TeamBlock(team: match.home)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    match.scoreText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(child: _TeamBlock(team: match.away)),
              ],
            ),
            SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final g in homeGoals)
                          _ScorerText('${g.player}${g.suffix} ${g.minute}'),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.sports_soccer, size: 15, color: Colors.white54),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final g in awayGoals)
                          _ScorerText('${g.minute} ${g.player}${g.suffix}',
                              alignEnd: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeagueIcon extends StatelessWidget {
  final String? url;
  const _LeagueIcon({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return const Icon(Icons.emoji_events_outlined, size: 18, color: AppColors.lime);
    }
    return SizedBox(
      width: 20,
      height: 20,
      child: Image.network(
        url!,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.emoji_events_outlined, size: 18, color: AppColors.lime),
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  final Team team;
  const _TeamBlock({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TeamCrest(team: team, size: 54),
        const SizedBox(height: 6),
        Text(
          team.shortName.toUpperCase(),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _ScorerText extends StatelessWidget {
  final String text;
  final bool alignEnd;
  const _ScorerText(this.text, {this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.35),
    );
  }
}
