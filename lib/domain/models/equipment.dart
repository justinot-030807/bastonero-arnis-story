// lib/domain/models/equipment.dart
// Pure Dart model for camp equipment and items.

class Equipment {
  final String id;
  final String name;
  final int cost;
  final int width; // width in tiles (14 tiles per floor)
  final String category;
  final String statBonus; // 'lakas' | 'bilis' | 'diskarte' | 'salag' | 'grado' | 'morale' | 'fatigue' | 'all' | 'none'
  final double bonusPercent;
  final String description;

  const Equipment({
    required this.id,
    required this.name,
    required this.cost,
    required this.width,
    required this.category,
    required this.statBonus,
    required this.bonusPercent,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cost': cost,
        'width': width,
        'category': category,
        'statBonus': statBonus,
        'bonusPercent': bonusPercent,
        'description': description,
      };

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: json['id'] as String,
        name: json['name'] as String,
        cost: json['cost'] as int? ?? 100,
        width: json['width'] as int? ?? 1,
        category: json['category'] as String? ?? 'training',
        statBonus: json['statBonus'] as String? ?? 'none',
        bonusPercent: (json['bonusPercent'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String? ?? '',
      );
}

class PlacedEquipment {
  final String instanceId;
  final String equipmentId;
  int floor; // 1 = ground yard/1F, 2 = 2F, etc.
  int tileX; // 0..13

  PlacedEquipment({
    required this.instanceId,
    required this.equipmentId,
    required this.floor,
    required this.tileX,
  });

  Map<String, dynamic> toJson() => {
        'instanceId': instanceId,
        'equipmentId': equipmentId,
        'floor': floor,
        'tileX': tileX,
      };

  factory PlacedEquipment.fromJson(Map<String, dynamic> json) => PlacedEquipment(
        instanceId: json['instanceId'] as String,
        equipmentId: json['equipmentId'] as String,
        floor: json['floor'] as int? ?? 1,
        tileX: json['tileX'] as int? ?? 0,
      );
}
