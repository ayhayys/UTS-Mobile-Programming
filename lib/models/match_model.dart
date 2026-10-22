import '../core/json_utils.dart';

enum MatchStatus { upcoming, live, finished }

class Team {
  final String id;
  final String name;
  final String shortName;
  final String abbr;
  final String logo;

  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.abbr,
    required this.logo,
  });

  factory Team.fromJson(Map<String, dynamic> j) {
    String logo = asString(j['logo']) ?? '';
    if (logo.isEmpty) {
      final logos = asList(j['logos']);
      if (logos.isNotEmpty) {
        logo = asString(asMap(logos.first)['href']) ?? '';
      }
    }
    return Team(
      id: asString(j['id']) ?? '',
      name: asString(j['displayName']) ?? asString(j['name']) ?? '-',
      shortName: asString(j['shortDisplayName']) ??
          asString(j['displayName']) ??
          '-',
      abbr: asString(j['abbreviation']) ?? '',
      logo: logo,
    );
  }
}

class GoalEvent {
  final String minute;
  final String player;
  final String teamId;
  final bool isOwnGoal;
  final bool isPenalty;

  const GoalEvent({
    required this.minute,
    required this.player,
    required this.teamId,
    this.isOwnGoal = false,
    this.isPenalty = false,
  });

  String get suffix => isOwnGoal ? ' (OG)' : (isPenalty ? ' (P)' : '');
}

class MatchModel {
  final String id;
  final String leagueCode;
  final String leagueName;
  final String? leagueLogo;
  final DateTime kickoff;
  final MatchStatus status;
  final String statusDetail;
  final String clock;
  final Team home;
  final Team away;
  final int homeScore;
  final int awayScore;
  final String venue;
  final List<GoalEvent> goals;

  const MatchModel({
    required this.id,
    required this.leagueCode,
    required this.leagueName,
    required this.leagueLogo,
    required this.kickoff,
    required this.status,
    required this.statusDetail,
    required this.clock,
    required this.home,
    required this.away,
    required this.homeScore,
    required this.awayScore,
    required this.venue,
    required this.goals,
  });

  bool get isLive => status == MatchStatus.live;
  bool get isFinished => status == MatchStatus.finished;
  bool get isUpcoming => status == MatchStatus.upcoming;

  String get scoreText => '$homeScore - $awayScore';

  String get liveLabel {
    if (statusDetail.toUpperCase() == 'HT') return 'HT';
    return clock.isEmpty ? 'LIVE' : clock;
  }

  String get webUrl => 'https://www.espn.com/soccer/match/_/gameId/$id';

  factory MatchModel.fromScoreboardEvent(
    Map<String, dynamic> event, {
    required String leagueCode,
    required String leagueName,
    String? leagueLogo,
  }) {
    final competitions = asList(event['competitions']);
    final comp =
        competitions.isNotEmpty ? asMap(competitions.first) : <String, dynamic>{};

    final competitors = asList(comp['competitors']).map(asMap).toList();
    if (competitors.length < 2) {
      throw const FormatException('Data pertandingan tidak lengkap');
    }
    final homeC = competitors.firstWhere(
      (c) => c['homeAway'] == 'home',
      orElse: () => competitors.first,
    );
    final awayC = competitors.firstWhere(
      (c) => c['homeAway'] == 'away',
      orElse: () => competitors.last,
    );

    final statusMap = asMap(comp['status'] ?? event['status']);
    final type = asMap(statusMap['type']);
    final state = asString(type['state']) ?? 'pre';
    final typeName = (asString(type['name']) ?? '').toUpperCase();

    MatchStatus status;
    if (typeName.contains('POSTPONED') ||
        typeName.contains('CANCELED') ||
        typeName.contains('CANCELLED')) {
      status = MatchStatus.upcoming;
    } else if (state == 'in') {
      status = MatchStatus.live;
    } else if (state == 'post') {
      status = MatchStatus.finished;
    } else {
      status = MatchStatus.upcoming;
    }

    final goals = asList(comp['details'])
        .map(asMap)
        .where((d) => d['scoringPlay'] == true)
        .map((d) {
      final athletes = asList(d['athletesInvolved']);
      final a = athletes.isNotEmpty ? asMap(athletes.first) : <String, dynamic>{};
      return GoalEvent(
        minute: asString(asMap(d['clock'])['displayValue']) ?? '',
        player: asString(a['shortName']) ?? asString(a['displayName']) ?? 'Goal',
        teamId: asString(asMap(d['team'])['id']) ?? '',
        isOwnGoal: d['ownGoal'] == true,
        isPenalty: d['penaltyKick'] == true,
      );
    }).toList();

    final venueMap = asMap(comp['venue']);
    final kickoff = DateTime.tryParse(
          asString(comp['date']) ?? asString(event['date']) ?? '',
        )?.toLocal() ??
        DateTime.now();

    return MatchModel(
      id: asString(event['id']) ?? '',
      leagueCode: leagueCode,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      kickoff: kickoff,
      status: status,
      statusDetail: asString(type['shortDetail']) ??
          asString(type['description']) ??
          '',
      clock: asString(statusMap['displayClock']) ?? '',
      home: Team.fromJson(asMap(homeC['team'])),
      away: Team.fromJson(asMap(awayC['team'])),
      homeScore: asInt(homeC['score']) ?? 0,
      awayScore: asInt(awayC['score']) ?? 0,
      venue: asString(venueMap['fullName']) ??
          asString(venueMap['displayName']) ??
          asString(asMap(event['venue'])['displayName']) ??
          '',
      goals: goals,
    );
  }
}
