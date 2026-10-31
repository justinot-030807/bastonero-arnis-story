// lib/domain/models/alumni.dart
// Pure Dart models for Alumni and Legacy (Pamana) system.

enum AlumniRole {
  trainer,
  sponsor,
  hallOfFame,
}

class Alumnus {
  final String id;
  final String studentId;
  final String name;
  final String nickname;
  final int graduatedYear;
  final int graduatedMonth;
  final List<String> titles;
  final int wins;
  final int losses;
  final double lakas;
  final double bilis;
  final double diskarte;
  final double salag;
  AlumniRole role;
  final int monthlySponsorship;
  final String trainerSpecialty;
  final int trainerSkill;

  Alumnus({
    required this.id,
    required this.studentId,
    required this.name,
    this.nickname = '',
    required this.graduatedYear,
    required this.graduatedMonth,
    List<String>? titles,
    this.wins = 0,
    this.losses = 0,
    required this.lakas,
    required this.bilis,
    required this.diskarte,
    required this.salag,
    this.role = AlumniRole.hallOfFame,
    this.monthlySponsorship = 0,
    this.trainerSpecialty = 'lakas',
    this.trainerSkill = 1,
  }) : titles = titles ?? [];

  double get totalStats => lakas + bilis + diskarte + salag;

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'name': name,
        'nickname': nickname,
        'graduatedYear': graduatedYear,
        'graduatedMonth': graduatedMonth,
        'titles': titles,
        'wins': wins,
        'losses': losses,
        'lakas': lakas,
        'bilis': bilis,
        'diskarte': diskarte,
        'salag': salag,
        'role': role.name,
        'monthlySponsorship': monthlySponsorship,
        'trainerSpecialty': trainerSpecialty,
        'trainerSkill': trainerSkill,
      };

  factory Alumnus.fromJson(Map<String, dynamic> json) => Alumnus(
        id: json['id'] as String,
        studentId: json['studentId'] as String? ?? json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String? ?? '',
        graduatedYear: json['graduatedYear'] as int? ?? 1,
        graduatedMonth: json['graduatedMonth'] as int? ?? 3,
        titles: (json['titles'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        wins: json['wins'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        lakas: (json['lakas'] as num?)?.toDouble() ?? 20.0,
        bilis: (json['bilis'] as num?)?.toDouble() ?? 20.0,
        diskarte: (json['diskarte'] as num?)?.toDouble() ?? 20.0,
        salag: (json['salag'] as num?)?.toDouble() ?? 20.0,
        role: AlumniRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => AlumniRole.hallOfFame,
        ),
        monthlySponsorship: json['monthlySponsorship'] as int? ?? 0,
        trainerSpecialty: json['trainerSpecialty'] as String? ?? 'lakas',
        trainerSkill: json['trainerSkill'] as int? ?? 1,
      );
}
