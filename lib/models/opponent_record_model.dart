import 'fighter_model.dart';

class OpponentRecord {
  final String id;
  final String name;
  final String title;
  final String gymName;
  final FighterStyle style;
  int matchesFought;
  int wins; // Bayani's wins against this opponent
  int losses; // Bayani's losses against this opponent
  int highestDamageDealt;
  String lastResult; // 'PANALO', 'TALO', 'WALA PA'
  String lastEncounter; // e.g. 'Year 1, Month 9 Wk 2'

  OpponentRecord({
    required this.id,
    required this.name,
    required this.title,
    required this.gymName,
    required this.style,
    this.matchesFought = 0,
    this.wins = 0,
    this.losses = 0,
    this.highestDamageDealt = 0,
    this.lastResult = 'WALA PA',
    this.lastEncounter = 'Hindi pa nakaharap',
  });

  double get winRate => matchesFought == 0 ? 0.0 : (wins / matchesFought) * 100.0;

  String get recordString => '$wins W - $losses L';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'gymName': gymName,
        'style': style.index,
        'matchesFought': matchesFought,
        'wins': wins,
        'losses': losses,
        'highestDamageDealt': highestDamageDealt,
        'lastResult': lastResult,
        'lastEncounter': lastEncounter,
      };

  factory OpponentRecord.fromJson(Map<String, dynamic> json) => OpponentRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        title: json['title'] as String? ?? 'Arnisador',
        gymName: json['gymName'] as String? ?? 'Local Gym',
        style: FighterStyle.values[json['style'] as int? ?? 0],
        matchesFought: json['matchesFought'] as int? ?? 0,
        wins: json['wins'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        highestDamageDealt: json['highestDamageDealt'] as int? ?? 0,
        lastResult: json['lastResult'] as String? ?? 'WALA PA',
        lastEncounter: json['lastEncounter'] as String? ?? 'Hindi pa nakaharap',
      );
}
