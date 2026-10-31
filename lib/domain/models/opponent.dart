// lib/domain/models/opponent.dart
// Pure Dart model for rival camps and fighters.

class Opponent {
  final String id;
  final String name;
  final String nickname;
  final String gymName;
  final String style;
  final int tier;
  final double lakas;
  final double bilis;
  final double diskarte;
  final double salag;

  const Opponent({
    required this.id,
    required this.name,
    required this.nickname,
    required this.gymName,
    required this.style,
    required this.tier,
    required this.lakas,
    required this.bilis,
    required this.diskarte,
    required this.salag,
  });

  double get totalStats => lakas + bilis + diskarte + salag;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'gymName': gymName,
        'style': style,
        'tier': tier,
        'lakas': lakas,
        'bilis': bilis,
        'diskarte': diskarte,
        'salag': salag,
      };

  factory Opponent.fromJson(Map<String, dynamic> json) => Opponent(
        id: json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String? ?? '',
        gymName: json['gymName'] as String? ?? 'Rival Gym',
        style: json['style'] as String? ?? 'SoloBaston',
        tier: json['tier'] as int? ?? 1,
        lakas: (json['lakas'] as num?)?.toDouble() ?? 20.0,
        bilis: (json['bilis'] as num?)?.toDouble() ?? 20.0,
        diskarte: (json['diskarte'] as num?)?.toDouble() ?? 20.0,
        salag: (json['salag'] as num?)?.toDouble() ?? 20.0,
      );
}
