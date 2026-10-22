import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/json_utils.dart';
import '../core/leagues.dart';
import '../models/match_detail_model.dart';
import '../models/match_model.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class FootballApiService {
  FootballApiService._();
  static final FootballApiService instance = FootballApiService._();

  static const String _base =
      'https://site.api.espn.com/apis/site/v2/sports/soccer';
  static const Duration _timeout = Duration(seconds: 15);
  static const Duration _ttl = Duration(minutes: 1);
  static const int _daysBack = 10;
  static const int _daysAhead = 10;
  static const int _maxParallel = 8;

  final http.Client _client = http.Client();

  List<MatchModel>? _cache;
  DateTime? _cacheTime;
  Future<List<MatchModel>>? _inflight;
  final Map<String, MatchDetail> _detailCache = {};

  Future<List<MatchModel>> getMatches({bool forceRefresh = false}) {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < _ttl) {
      return Future.value(_cache!);
    }
    if (!forceRefresh && _inflight != null) return _inflight!;

    final future = _loadAll().then((list) {
      _cache = list;
      _cacheTime = DateTime.now();
      return list;
    }).whenComplete(() {
      _inflight = null;
    });
    _inflight = future;
    return future;
  }

  Future<List<MatchModel>> _loadAll() async {
    final today = dateOnly(DateTime.now());
    final from = today.subtract(const Duration(days: _daysBack));
    final to = today.add(const Duration(days: _daysAhead));

    final byId = <String, MatchModel>{};
    Object? lastError;
    var baseFailed = 0;

    final dayTasks = <Future<List<MatchModel>> Function()>[];
    final baseResults = await Future.wait(kLeagues.map((league) async {
      try {
        final json = await _getScoreboard(league);
        final firstPage = _parseEvents(json, league);
        for (final day in _calendarDays(json, from, to)) {
          dayTasks.add(() async {
            try {
              return _parseEvents(await _getScoreboard(league, day: day), league);
            } catch (_) {
              return <MatchModel>[];
            }
          });
        }
        return firstPage;
      } catch (e) {
        baseFailed++;
        lastError = e;
        return <MatchModel>[];
      }
    }));

    if (baseFailed == kLeagues.length) {
      throw ApiException(
          'Failed to reach the server. Please check your internet connection. '
          '(${_describe(lastError)})');
    }

    for (final list in baseResults) {
      for (final m in list) {
        byId[m.id] = m;
      }
    }

    final dayResults = await _pool<List<MatchModel>>(dayTasks, _maxParallel);
    for (final list in dayResults) {
      for (final m in list) {
        byId[m.id] = m;
      }
    }

    final all = byId.values.toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    return all;
  }

  String _describe(Object? e) {
    if (e == null) return 'unknown error';
    if (e is ApiException) return e.message;
    return e.runtimeType.toString();
  }

  Future<List<T>> _pool<T>(List<Future<T> Function()> tasks, int limit) async {
    final results = List<T?>.filled(tasks.length, null);
    var next = 0;

    Future<void> worker() async {
      while (true) {
        final i = next++;
        if (i >= tasks.length) return;
        results[i] = await tasks[i]();
      }
    }

    await Future.wait(List.generate(limit, (_) => worker()));
    return results.cast<T>();
  }

  Future<Map<String, dynamic>> _getScoreboard(League league, {String? day}) async {
    var uri = Uri.parse('$_base/${league.code}/scoreboard');
    if (day != null) {
      uri = uri.replace(queryParameters: {'dates': day});
    }

    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw ApiException('HTTP ${response.statusCode} (${league.code})');
    }
    return asMap(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  List<String> _calendarDays(
      Map<String, dynamic> json, DateTime from, DateTime to) {
    final leagues = asList(json['leagues']);
    if (leagues.isEmpty) return const [];
    final calendar = asList(asMap(leagues.first)['calendar']);

    final fromKey = _key(from);
    final toKey = _key(to);
    final days = <String>{};
    for (final entry in calendar) {
      final raw = entry is Map ? asString(entry['startDate']) : asString(entry);
      if (raw == null || raw.length < 10) continue;
      final key = raw.substring(0, 10).replaceAll('-', '');
      if (key.length != 8) continue;
      if (key.compareTo(fromKey) >= 0 && key.compareTo(toKey) <= 0) {
        days.add(key);
      }
    }
    return days.toList()..sort();
  }

  String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  List<MatchModel> _parseEvents(Map<String, dynamic> json, League league) {
    final leagues = asList(json['leagues']);
    final leagueMap =
        leagues.isNotEmpty ? asMap(leagues.first) : <String, dynamic>{};
    final logos = asList(leagueMap['logos']);
    final leagueLogo =
        logos.isNotEmpty ? asString(asMap(logos.first)['href']) : null;

    final matches = <MatchModel>[];
    for (final e in asList(json['events'])) {
      try {
        matches.add(MatchModel.fromScoreboardEvent(
          asMap(e),
          leagueCode: league.code,
          leagueName: league.name,
          leagueLogo: leagueLogo,
        ));
      } catch (_) {
      }
    }
    return matches;
  }

  Future<MatchDetail> getMatchDetail(MatchModel match,
      {bool forceRefresh = false}) async {
    final key = '${match.leagueCode}:${match.id}';
    if (!forceRefresh && _detailCache.containsKey(key) && !match.isLive) {
      return _detailCache[key]!;
    }

    final uri = Uri.parse('$_base/${match.leagueCode}/summary')
        .replace(queryParameters: {'event': match.id});

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } catch (_) {
      throw const ApiException(
          'Failed to load match details. Please check your connection.');
    }
    if (response.statusCode != 200) {
      throw ApiException('Server error (HTTP ${response.statusCode})');
    }

    try {
      final json = asMap(jsonDecode(utf8.decode(response.bodyBytes)));
      final detail = MatchDetail.fromJson(json, match);
      _detailCache[key] = detail;
      return detail;
    } catch (_) {
      throw const ApiException('Match data could not be processed.');
    }
  }
}
