// test/domain_test.dart
// Unit tests for pure Dart domain logic, balance formulas, RNG determinism, and save migration.

import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/domain/balance.dart';
import 'package:bastonero_arnis_story/domain/rng.dart';
import 'package:bastonero_arnis_story/domain/models/student.dart';
import 'package:bastonero_arnis_story/domain/models/trainer.dart';
import 'package:bastonero_arnis_story/domain/models/equipment.dart';
import 'package:bastonero_arnis_story/domain/systems/save_system.dart';

void main() {
  group('Balance Constants & Formulas', () {
    test('Virtual resolution adheres to 240px width', () {
      expect(Balance.virtualWidth, 240.0);
      expect(Balance.startingMoney, 1000);
      expect(Balance.varsityEligibilityGrade, 75.0);
      expect(Balance.intramsEligibilityGrade, 80.0);
    });

    test('Rank fame thresholds increase monotonically', () {
      expect(Balance.fameThresholds['purok'], 0);
      expect(Balance.fameThresholds['barangay'], 150);
      expect(Balance.fameThresholds['bayan'], 600);
      expect(Balance.fameThresholds['probinsya'], 2500);
      expect(Balance.fameThresholds['rehiyon'], 9000);
      expect(Balance.fameThresholds['pambansa'], 30000);
    });
  });

  group('GameRng Determinism', () {
    test('Identical seeds produce identical sequence', () {
      final rng1 = GameRng(12345);
      final rng2 = GameRng(12345);

      final seq1 = List.generate(20, (_) => rng1.nextInt(100));
      final seq2 = List.generate(20, (_) => rng2.nextInt(100));

      expect(seq1, equals(seq2));
    });

    test('rangeDouble and nextDouble respect bounds', () {
      final rng = GameRng(999);
      for (int i = 0; i < 50; i++) {
        final d = rng.nextDouble();
        expect(d, greaterThanOrEqualTo(0.0));
        expect(d, lessThan(1.0));

        final r = rng.rangeDouble(10.0, 25.0);
        expect(r, greaterThanOrEqualTo(10.0));
        expect(r, lessThanOrEqualTo(25.0));
      }
    });
  });

  group('Student Model & Eligibility', () {
    test('Student calculates totalStats and school varsity eligibility', () {
      final s = Student(
        id: 'std_01',
        name: 'Bayani "Bastonero"',
        lakas: 25.0,
        bilis: 25.0,
        diskarte: 20.0,
        salag: 15.0,
        gradePercent: 82.0,
      );

      expect(s.totalStats, 85.0);
      expect(s.isEligibleForSchoolVarsity, isTrue);

      s.gradePercent = 70.0;
      expect(s.isEligibleForSchoolVarsity, isFalse);
    });

    test('Student serialization roundtrip', () {
      final original = Student(
        id: 'std_test',
        name: 'Juan dela Cruz',
        nickname: 'Agila',
        lakas: 30.0,
        bilis: 28.0,
        diskarte: 22.0,
        salag: 18.0,
        gradePercent: 85.0,
        style: ArnisStyle.dobleBaston,
        look: const StudentLook(bodyTypeId: 'body_b', hairIndex: 2, skinIndex: 1),
      );

      final json = original.toJson();
      final restored = Student.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.nickname, original.nickname);
      expect(restored.lakas, original.lakas);
      expect(restored.style, original.style);
      expect(restored.look.hairIndex, original.look.hairIndex);
    });
  });

  group('Trainer & Equipment Models', () {
    test('Trainer salary and trainingMultiplier scale with skill', () {
      final t1 = Trainer(id: 't1', name: 'Guro A', specialty: 'lakas', skill: 1, salary: 600);
      final t3 = Trainer(id: 't3', name: 'Guro C', specialty: 'bilis', skill: 3, salary: 1400);

      expect(t1.salary, 600);
      expect(t3.salary, 1400);
      expect(t3.trainingMultiplier, greaterThan(t1.trainingMultiplier));
    });

    test('PlacedEquipment serialization roundtrip', () {
      final eq = PlacedEquipment(
        instanceId: 'pe_01',
        equipmentId: 'tire_dummy',
        floor: 1,
        tileX: 3,
      );

      final json = eq.toJson();
      final restored = PlacedEquipment.fromJson(json);

      expect(restored.instanceId, eq.instanceId);
      expect(restored.equipmentId, eq.equipmentId);
      expect(restored.floor, eq.floor);
      expect(restored.tileX, eq.tileX);
    });
  });

  group('SaveSystem & v2-to-v3 Migration', () {
    test('Migrates legacy v2.0 save data into valid v3.0 format', () {
      final legacyV2Json = {
        'year': 1,
        'month': 7,
        'week': 2,
        'pesos': 1450,
        'prestige': 85,
        'fighter': {
          'name': 'Bayani',
          'nickname': 'Bastonero',
          'power': 28.0,
          'speed': 26.0,
          'technique': 22.0,
          'defense': 16.0,
          'academics': 84.5,
          'selectedStyle': 'Solo Baston',
        },
      };

      final migrated = SaveSystem.migrateV2ToV3(legacyV2Json);

      expect(migrated['version'], 3);
      expect(migrated['year'], 1);
      expect(migrated['month'], 7);
      expect(migrated['week'], 2);

      final campData = migrated['camp'] as Map<String, dynamic>;
      expect(campData['money'], 1450);
      expect(campData['fame'], 85);

      final studentsList = campData['students'] as List<dynamic>;
      expect(studentsList.length, 3);
      expect(studentsList.first['name'], 'Bayani');
      expect(studentsList.first['lakas'], 28.0);
      expect(studentsList.first['bilis'], 26.0);
      expect(studentsList.first['gradePercent'], 84.5);
    });
  });
}
