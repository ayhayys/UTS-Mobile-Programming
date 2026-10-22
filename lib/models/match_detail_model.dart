import '../core/json_utils.dart';
import 'match_model.dart';

class LineupPlayer {
  final String name;
  final String jersey;
  final String position;
  final bool starter;
  final int? formationPlace;

  const LineupPlayer({
    required this.name,
    required this.jersey,
    required this.position,
    required this.starter,
    required this.formationPlace,
  });

  factory LineupPlayer.fromJson(Map<String, dynamic> j) {
    final athlete = asMap(j['athlete']);
    final pos = asMap(j['position']).isNotEmpty
        ? asMap(j['position'])
        : asMap(athlete['position']);
    return LineupPlayer(
      name: asString(athlete['displayName']) ??
          asString(athlete['shortName']) ??
          asString(j['displayName']) ??
          '-',
      jersey: asString(j['jersey']) ?? asString(athlete['jersey']) ?? '',
      position: asString(pos['abbreviation']) ?? '',
      starter: j['starter'] == true,
      formationPlace: asInt(j['formationPlace']),
    );
  }

  String get shortName {
    final parts = name.trim().split(' ');
    final last = parts.isEmpty ? name : parts.last;
    return last.length > 10 ? '${last.substring(0, 9)}.' : last;
  }
}

class TeamLineup {
  final String teamId;
  final bool isHome;
  final String? formation;
  final List<LineupPlayer> players;

  const TeamLineup({
    required this.teamId,
    required this.isHome,
    required this.formation,
    required this.players,
  });

  factory TeamLineup.fromJson(Map<String, dynamic> j) {
    return TeamLineup(
      teamId: asString(asMap(j['team'])['id']) ?? '',
      isHome: j['homeAway'] == 'home',
      formation: asString(j['formation']),
      players: asList(j['roster'])
          .map((e) => LineupPlayer.fromJson(asMap(e)))
          .toList(),
    );
  }

  List<LineupPlayer> get starters {
    final list = players.where((p) => p.starter).toList();
    list.sort((a, b) =>
        (a.formationPlace ?? 99).compareTo(b.formationPlace ?? 99));
    return list;
  }

  List<LineupPlayer> get substitutes =>
      players.where((p) => !p.starter).toList();

  List<int>? get formationRows {
    final f = formation;
    if (f == null) return null;
    final rows = f.split('-').map((e) => int.tryParse(e.trim())).toList();
    if (rows.isEmpty || rows.any((e) => e == null || e <= 0)) return null;
    final result = rows.cast<int>();
    final sum = result.fold<int>(0, (a, b) => a + b);
    if (sum != 10 || starters.length != 11) return null;
    return result;
  }
}

enum EventKind { goal, yellow, red, substitution }

class MatchEventItem {
  final String minute;
  final EventKind kind;
  final String text;
  final String teamId;

  const MatchEventItem({
    required this.minute,
    required this.kind,
    required this.text,
    required this.teamId,
  });
}

class MatchDetail {
  final List<TeamLineup> lineups;
  final List<MatchEventItem> events;

  const MatchDetail({
    required this.lineups,
    required this.events,
  });

  TeamLineup? lineupFor({required bool home}) {
    for (final l in lineups) {
      if (l.isHome == home) return l;
    }
    return null;
  }

  factory MatchDetail.fromJson(Map<String, dynamic> json, MatchModel match) {
    final lineups = asList(json['rosters'])
        .map((e) => TeamLineup.fromJson(asMap(e)))
        .toList();

    final events = <MatchEventItem>[];
    for (final raw in asList(json['keyEvents'])) {
      final e = asMap(raw);
      final type = asMap(e['type']);
      final label =
          '${asString(type['type']) ?? ''} ${asString(type['text']) ?? ''}'
              .toLowerCase();
      EventKind? kind;
      if (label.contains('goal') || e['scoringPlay'] == true) {
        kind = EventKind.goal;
      } else if (label.contains('yellow')) {
        kind = EventKind.yellow;
      } else if (label.contains('red')) {
        kind = EventKind.red;
      } else if (label.contains('substitution')) {
        kind = EventKind.substitution;
      }
      if (kind == null) continue;

      final participants = asList(e['participants']);
      String? player;
      if (participants.isNotEmpty) {
        player = asString(asMap(asMap(participants.first)['athlete'])['displayName']);
      }
      final text = kind == EventKind.substitution
          ? (asString(e['shortText']) ?? asString(e['text']) ?? 'Substitution')
          : (player ?? asString(e['shortText']) ?? asString(e['text']) ?? '-');

      events.add(MatchEventItem(
        minute: asString(asMap(e['clock'])['displayValue']) ?? '',
        kind: kind,
        text: text,
        teamId: asString(asMap(e['team'])['id']) ?? '',
      ));
    }

    if (events.isEmpty) {
      for (final g in match.goals) {
        events.add(MatchEventItem(
          minute: g.minute,
          kind: EventKind.goal,
          text: '${g.player}${g.suffix}',
          teamId: g.teamId,
        ));
      }
    }

    return MatchDetail(
      lineups: lineups,
      events: events,
    );
  }
}
