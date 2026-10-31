// lib/domain/models/tournament.dart
// Pure Dart model for tournaments (School and Community tracks).

class Tournament {
  final String id;
  final String name;
  final String track; // 'community' | 'school'
  final int tier; // 1..6
  final int rounds;
  final int entryFee;
  final int travelCost;
  final int prizeMoney;
  final int fameReward;
  final int month;
  final int week;
  final int minFame;
  final String minCampRank;
  final String description;

  const Tournament({
    required this.id,
    required this.name,
    required this.track,
    required this.tier,
    required this.rounds,
    required this.entryFee,
    required this.travelCost,
    required this.prizeMoney,
    required this.fameReward,
    required this.month,
    required this.week,
    required this.minFame,
    required this.minCampRank,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'track': track,
        'tier': tier,
        'rounds': rounds,
        'entryFee': entryFee,
        'travelCost': travelCost,
        'prizeMoney': prizeMoney,
        'fameReward': fameReward,
        'month': month,
        'week': week,
        'minFame': minFame,
        'minCampRank': minCampRank,
        'description': description,
      };

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
        id: json['id'] as String,
        name: json['name'] as String,
        track: json['track'] as String? ?? 'community',
        tier: json['tier'] as int? ?? 1,
        rounds: json['rounds'] as int? ?? 2,
        entryFee: json['entryFee'] as int? ?? 0,
        travelCost: json['travelCost'] as int? ?? 0,
        prizeMoney: json['prizeMoney'] as int? ?? 500,
        fameReward: json['fameReward'] as int? ?? 20,
        month: json['month'] as int? ?? 7,
        week: json['week'] as int? ?? 1,
        minFame: json['minFame'] as int? ?? 0,
        minCampRank: json['minCampRank'] as String? ?? 'purok',
        description: json['description'] as String? ?? '',
      );
}
