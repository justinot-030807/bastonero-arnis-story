// lib/domain/systems/save_system.dart
// Pure Dart save system managing 3 JSON slots and data migration.

import '../models/camp.dart';
import '../models/equipment.dart';
import '../models/student.dart';
import '../../utils/storage_service.dart';

class SaveSystem {
  static const int currentSaveVersion = 3;

  /// Saves the full game state to [slotIndex] (1..3).
  static Future<bool> save(int slotIndex, {
    required int year,
    required int month,
    required int week,
    required Camp camp,
  }) async {
    final data = {
      'version': currentSaveVersion,
      'year': year,
      'month': month,
      'week': week,
      'camp': camp.toJson(),
    };
    return await StorageService.saveGameToSlot(slotIndex, data);
  }

  /// Loads and migrates game data from [slotIndex].
  static Future<Map<String, dynamic>?> load(int slotIndex) async {
    final rawData = await StorageService.loadGameFromSlot(slotIndex);
    if (rawData == null) return null;

    final version = rawData['version'] as int? ?? 2;
    if (version < 3) {
      return migrateV2ToV3(rawData);
    }
    return rawData;
  }

  /// Migrates legacy v2.0 save data to v3.0 format seamlessly.
  static Map<String, dynamic> migrateV2ToV3(Map<String, dynamic> v2) {
    final year = v2['year'] as int? ?? 1;
    final month = v2['month'] as int? ?? 6;
    final week = v2['week'] as int? ?? 1;
    final pesos = v2['pesos'] as int? ?? 1000;
    final prestige = v2['prestige'] as int? ?? 0;

    final fighterMap = v2['fighter'] as Map<String, dynamic>? ?? {};
    final fighterName = fighterMap['name'] as String? ?? 'Bayani';
    final nickname = fighterMap['nickname'] as String? ?? 'Bastonero';
    final gymName = fighterMap['gymName'] as String? ?? 'Bakuran Arnis Camp';

    // Convert legacy primary fighter into first student
    final student1 = Student(
      id: 'student_1',
      name: fighterName,
      nickname: nickname,
      age: fighterMap['age'] as int? ?? 11,
      gender: fighterMap['gender'] as String? ?? 'Lalaki',
      grade: fighterMap['gradeLevel'] as int? ?? 5,
      gradePercent: (fighterMap['academics'] as num?)?.toDouble() ?? 85.0,
      lakas: (fighterMap['power'] as num?)?.toDouble() ?? 15.0,
      bilis: (fighterMap['speed'] as num?)?.toDouble() ?? 14.0,
      diskarte: (fighterMap['technique'] as num?)?.toDouble() ?? 13.0,
      salag: (fighterMap['defense'] as num?)?.toDouble() ?? 11.0,
      fatigue: 0.0,
      morale: 85.0,
      style: ArnisStyle.soloBaston,
      look: StudentLook(
        skinIndex: fighterMap['skinIndex'] as int? ?? 0,
        hairIndex: fighterMap['hairIndex'] as int? ?? 0,
        headbandColorIndex: fighterMap['headbandColorIndex'] as int? ?? 0,
      ),
    );

    // Initial starter roster of 3 students if migrating from solo fighter
    final student2 = Student(
      id: 'student_2',
      name: 'Danilo',
      nickname: 'Tigre',
      age: 12,
      gender: 'Lalaki',
      grade: 6,
      gradePercent: 82.0,
      lakas: 16.0,
      bilis: 13.0,
      diskarte: 12.0,
      salag: 14.0,
      look: const StudentLook(skinIndex: 1, headbandColorIndex: 1),
    );

    final student3 = Student(
      id: 'student_3',
      name: 'Ligaya',
      nickname: 'Kidlat',
      age: 11,
      gender: 'Babae',
      grade: 5,
      gradePercent: 89.0,
      lakas: 12.0,
      bilis: 17.0,
      diskarte: 15.0,
      salag: 10.0,
      style: ArnisStyle.dobleBaston,
      look: const StudentLook(skinIndex: 2, headbandColorIndex: 2),
    );

    // Convert legacy starter facilities
    final placements = [
      PlacedEquipment(instanceId: 'starter_rack', equipmentId: 'rack_yantok', floor: 1, tileX: 1),
      PlacedEquipment(instanceId: 'starter_sako', equipmentId: 'sako_buhangin', floor: 1, tileX: 4),
      PlacedEquipment(instanceId: 'starter_banig', equipmentId: 'banig_mat', floor: 1, tileX: 7),
    ];

    final camp = Camp(
      name: gymName,
      money: pesos,
      fame: prestige,
      rankTier: 'purok',
      floors: 1,
      placements: placements,
      students: [student1, student2, student3],
    );

    return {
      'version': 3,
      'year': year,
      'month': month,
      'week': week,
      'camp': camp.toJson(),
    };
  }
}
