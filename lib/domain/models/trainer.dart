// lib/domain/models/trainer.dart
// Pure Dart trainer model (Guro).

class Trainer {
  final String id;
  final String name;
  final String specialty; // 'lakas' | 'bilis' | 'diskarte' | 'salag' | 'aral' | 'moves'
  final int skill; // 1..5
  final int salary; // monthly
  final String? teachesMoveId;

  const Trainer({
    required this.id,
    required this.name,
    required this.specialty,
    this.skill = 1,
    this.salary = 600,
    this.teachesMoveId,
  });

  double get trainingMultiplier => 1.0 + (skill * 0.04);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'skill': skill,
        'salary': salary,
        'teachesMoveId': teachesMoveId,
      };

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        id: json['id'] as String,
        name: json['name'] as String,
        specialty: json['specialty'] as String,
        skill: json['skill'] as int? ?? 1,
        salary: json['salary'] as int? ?? 600,
        teachesMoveId: json['teachesMoveId'] as String?,
      );
}
