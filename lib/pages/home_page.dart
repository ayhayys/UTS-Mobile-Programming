import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/json_utils.dart';
import '../models/match_model.dart';
import '../services/football_api_service.dart';
import '../widgets/async_state_views.dart';
import '../widgets/date_selector.dart';
import '../widgets/fixture_tile.dart';
import '../widgets/live_match_card.dart';
import '../widgets/section_header.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onViewAll;
  const HomePage({super.key, required this.onViewAll});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FootballApiService _api = FootballApiService.instance;
  late Future<List<MatchModel>> _future;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = dateOnly(DateTime.now());
    _future = _api.getMatches();
  }

  void _retry() {
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

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
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
                    onRetry: _retry,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.ink,
                  onRefresh: _refresh,
                  child: _buildContent(snapshot.data ?? const []),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 6),
      child: Row(
        children: [
          const Text(
            'MATCHDAY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _comingSoon('Search'),
            icon: const Icon(Icons.search_rounded, size: 28),
            color: AppColors.ink,
          ),
          IconButton(
            onPressed: () => _comingSoon('Notifications'),
            icon: const Badge(
              smallSize: 8,
              backgroundColor: AppColors.lime,
              child: Icon(Icons.notifications_none_rounded, size: 28),
            ),
            color: AppColors.ink,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<MatchModel> all) {
    final now = DateTime.now();
    final today = dateOnly(now);

    final live = all.where((m) => m.isLive).toList();
    final recent = all
        .where((m) => m.isFinished && now.difference(m.kickoff).inHours < 72)
        .toList()
      ..sort((a, b) => b.kickoff.compareTo(a.kickoff));
    final hero = live.isNotEmpty ? live : recent.take(5).toList();

    final upcoming = all.where((m) => m.isUpcoming).toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    final isToday = _selected == today;
    final fixtures = isToday
        ? upcoming.take(8).toList()
        : upcoming.where((m) => dateOnly(m.kickoff) == _selected).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        SectionHeader(
          title: live.isNotEmpty ? 'LIVE NOW' : 'LATEST RESULTS',
          showDot: true,
          dotColor: live.isNotEmpty ? AppColors.lime : AppColors.muted,
          onViewAll: widget.onViewAll,
        ),
        if (hero.isEmpty)
          const EmptyView(message: 'No live matches right now.')
        else
          LiveCarousel(matches: hero),
        const SizedBox(height: 18),
        DateSelector(
          selected: _selected,
          onSelected: (d) => setState(() => _selected = d),
        ),
        SectionHeader(
          title: isToday ? 'UPCOMING FIXTURES' : 'FIXTURES',
          onViewAll: widget.onViewAll,
        ),
        if (fixtures.isEmpty)
          const EmptyView(message: 'No fixtures on this day.')
        else
          for (final m in fixtures) FixtureTile(match: m),
      ],
    );
  }
}
