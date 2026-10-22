class League {
  final String code;
  final String name;
  final String shortName;

  const League(this.code, this.name, this.shortName);
}

const List<League> kLeagues = [
  League('eng.1', 'Premier League', 'EPL'),
  League('esp.1', 'La Liga', 'La Liga'),
  League('ita.1', 'Serie A', 'Serie A'),
  League('ger.1', 'Bundesliga', 'Bundesliga'),
  League('fra.1', 'Ligue 1', 'Ligue 1'),
  League('uefa.champions', 'Champions League', 'UCL'),
  League('idn.1', 'Liga 1 Indonesia', 'Liga 1'),
];
