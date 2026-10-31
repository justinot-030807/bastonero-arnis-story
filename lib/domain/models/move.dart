// lib/domain/models/move.dart
// Pure Dart model for Arnis moves.

class Move {
  final String id;
  final String name;
  final String style; // 'SoloBaston' | 'DobleBaston' | 'EspadaYDaga' | 'Any'
  final String requiredStat;
  final int requiredValue;
  final double hitBonus;
  final double damageMultiplier;
  final int hits;
  final String description;

  const Move({
    required this.id,
    required this.name,
    required this.style,
    required this.requiredStat,
    required this.requiredValue,
    this.hitBonus = 0.0,
    this.damageMultiplier = 1.0,
    this.hits = 1,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'style': style,
        'requiredStat': requiredStat,
        'requiredValue': requiredValue,
        'hitBonus': hitBonus,
        'damageMultiplier': damageMultiplier,
        'hits': hits,
        'description': description,
      };

  factory Move.fromJson(Map<String, dynamic> json) => Move(
        id: json['id'] as String,
        name: json['name'] as String,
        style: json['style'] as String? ?? 'SoloBaston',
        requiredStat: json['requiredStat'] as String? ?? 'diskarte',
        requiredValue: json['requiredValue'] as int? ?? 10,
        hitBonus: (json['hitBonus'] as num?)?.toDouble() ?? 0.0,
        damageMultiplier: (json['damageMultiplier'] as num?)?.toDouble() ?? 1.0,
        hits: json['hits'] as int? ?? 1,
        description: json['description'] as String? ?? '',
      );
}
