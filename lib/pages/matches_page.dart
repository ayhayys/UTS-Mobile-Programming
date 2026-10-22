import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/json_utils.dart';
import '../core/leagues.dart';
import '../models/match_model.dart';
import '../services/football_api_service.dart';
import '../utils/date_format_utils.dart';
import '../widgets/async_state_views.dart';
import '../widgets/fixture_tile.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final FootballApiService _api = FootballApiService.instance;
  late Future<List<MatchModel>> _future;
  int _tab = 0;
  String? _leagueCode;

  @override
  void initState() {
    super.initState();
    _future = _api.getMatches();
  }

  void _reload() {
    final f = _api.getMatches(forceRefresh: true);
    setState(() {
      _future = f;
    });
  }

  Future<void> _refresh() async {
    final f = _api.getMatches(forceRefresh: true);
    setState(() {
      _future = f;
    });
    try {
      await f;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 8, 4),
            child: Row(
              children: [
                const Text(
                  'Matches',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          _buildSegmented(),
          const SizedBox(height: 10),
          _buildLeagueChips(),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<MatchModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: friendlyError(snapshot.error),
                    onRetry: _reload,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.ink,
                  onRefresh: _refresh,
                  child: _buildList(snapshot.data ?? const []),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmented() {
    Widget seg(String label, int index) {
      final active = _tab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: active ? AppColors.lime : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [seg('Upcoming', 0), seg('Results', 1)]),
    );
  }

  Widget _buildLeagueChips() {
    Widget chip(String label, String? code) {
      final active = _leagueCode == code;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => setState(() => _leagueCode = code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.ink : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? AppColors.ink : AppColors.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.lime : AppColors.ink,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          chip('All', null),
          for (final l in kLeagues) chip(l.shortName, l.code),
        ],
      ),
    );
  }

  Widget _buildList(List<MatchModel> all) {
    final filtered =
        all.where((m) => _leagueCode == null || m.leagueCode == _leagueCode);

    final List<MatchModel> items;
    if (_tab == 0) {
      items = filtered.where((m) => m.isUpcoming || m.isLive).toList()
        ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    } else {
      items = filtered.where((m) => m.isFinished).toList()
        ..sort((a, b) => b.kickoff.compareTo(a.kickoff));
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          EmptyView(
            message: _tab == 0
                ? 'No upcoming matches for this filter.'
                : 'No finished matches for this filter.',
          ),
        ],
      );
    }

    final groups = <DateTime, List<MatchModel>>{};
    for (final m in items) {
      groups.putIfAbsent(dateOnly(m.kickoff), () => []).add(m);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              dayHeader(entry.key).toUpperCase(),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: AppColors.muted,
              ),
            ),
          ),
          for (final m in entry.value)
            _tab == 0 ? FixtureTile(match: m) : ResultTile(match: m),
        ],
      ],
    );
  }
}
