// lib/domain/models/camp.dart
// Pure Dart model for the Camp (Bakuran / Academy).

import '../balance.dart';
import '../rng.dart';
import '../systems/data_loader.dart';
import 'equipment.dart';
import 'focus_tap.dart';
import 'student.dart';
import 'trainer.dart';

class Camp {
  String name;
  int money;
  int fame;
  String rankTier; // 'purok' | 'barangay' | 'bayan' | 'probinsya' | 'rehiyon' | 'pambansa'
  int floors; // 1..5
  List<PlacedEquipment> placements;
  List<Student> students;
  List<Trainer> trainers;
  List<String> unlockedTournaments;
  Map<String, dynamic> flags;

  Camp({
    required this.name,
    this.money = 1000,
    this.fame = 0,
    this.rankTier = 'purok',
    this.floors = 1,
    List<PlacedEquipment>? placements,
    List<Student>? students,
    List<Trainer>? trainers,
    List<String>? unlockedTournaments,
    Map<String, dynamic>? flags,
  })  : placements = placements ?? [],
        students = (students != null && students.isNotEmpty)
            ? students
            : createDefaultStarterStudents(),
        trainers = trainers ?? [],
        unlockedTournaments = unlockedTournaments ?? ['inter_purok', 'school_intrams'],
        flags = flags ?? {};

  static List<Student> createDefaultStarterStudents() {
    return [
      Student(
        id: 'std_01',
        name: 'Bayani',
        nickname: 'Bastonero',
        age: 11,
        gender: 'Lalaki',
        grade: 5,
        gradePercent: 86.0,
        lakas: 16.0,
        bilis: 15.0,
        diskarte: 14.0,
        salag: 12.0,
        fatigue: 0.0,
        morale: 85.0,
        style: ArnisStyle.soloBaston,
        traits: ['Masipag', 'Palaban'],
        currentActivity: ActivityType.sanayLakas,
        look: const StudentLook(bodyTypeId: 'body_a', hairIndex: 0, skinIndex: 0, headbandColorIndex: 0),
      ),
      Student(
        id: 'std_02',
        name: 'Mayumi',
        nickname: 'Kidlat',
        age: 11,
        gender: 'Babae',
        grade: 5,
        gradePercent: 88.0,
        lakas: 13.0,
        bilis: 17.0,
        diskarte: 15.0,
        salag: 11.0,
        fatigue: 0.0,
        morale: 80.0,
        style: ArnisStyle.dobleBaston,
        traits: ['Maliksi', 'Matalino'],
        currentActivity: ActivityType.sanayBilis,
        look: const StudentLook(bodyTypeId: 'body_b', hairIndex: 1, skinIndex: 1, headbandColorIndex: 1),
      ),
      Student(
        id: 'std_03',
        name: 'Danilo',
        nickname: 'Tigas',
        age: 12,
        gender: 'Lalaki',
        grade: 6,
        gradePercent: 81.0,
        lakas: 18.0,
        bilis: 12.0,
        diskarte: 13.0,
        salag: 15.0,
        fatigue: 0.0,
        morale: 75.0,
        style: ArnisStyle.espadaYDaga,
        traits: ['Matibay', 'Masipag'],
        currentActivity: ActivityType.sanaySalag,
        look: const StudentLook(bodyTypeId: 'body_c', hairIndex: 2, skinIndex: 2, headbandColorIndex: 2),
      ),
    ];
  }

  int get maxStudents => 4 + (floors * 4);

  int lastWeeklyTuitionEarned = 0;
  int lastWeeklyPassiveEarned = 0;

  int get monthlyUpkeep => Balance.monthlyBaseUpkeep + (floors * Balance.monthlyUpkeepPerFloor);
  int get monthlyTrainerSalaries => trainers.fold<int>(0, (sum, t) => sum + t.salary);

  /// Expansion cost for next floor (2F: 1800, 3F: 6000, 4F: 15000, 5F: 35000).
  int? get nextFloorCost => Balance.floorCosts[floors + 1];

  bool canExpandFloor() => floors < 5 && nextFloorCost != null && money >= nextFloorCost!;

  bool expandFloor() {
    if (!canExpandFloor()) return false;
    money -= nextFloorCost!;
    floors += 1;
    return true;
  }

  Equipment? getEquipmentMeta(String id) {
    for (final eq in DataLoader.equipmentCatalog) {
      if (eq.id == id) return eq;
    }
    return null;
  }

  bool canPlaceEquipment({
    required String equipmentId,
    required int floor,
    required int tileX,
    String? ignoreInstanceId,
  }) {
    if (floor < 1 || floor > floors) return false;
    final meta = getEquipmentMeta(equipmentId);
    final width = meta?.width ?? 2;
    if (tileX < 0 || tileX + width > 14) return false;

    for (final p in placements) {
      if (ignoreInstanceId != null && p.instanceId == ignoreInstanceId) continue;
      if (p.floor != floor) continue;
      final pMeta = getEquipmentMeta(p.equipmentId);
      final pWidth = pMeta?.width ?? 2;
      final pStart = p.tileX;
      final pEnd = p.tileX + pWidth;

      final myStart = tileX;
      final myEnd = tileX + width;

      if (myStart < pEnd && myEnd > pStart) {
        return false; // Overlap detected
      }
    }
    return true;
  }

  PlacedEquipment? placeEquipment({
    required String equipmentId,
    required int floor,
    required int tileX,
  }) {
    final meta = getEquipmentMeta(equipmentId);
    final cost = meta?.cost ?? 200;
    if (money < cost) return null;
    if (!canPlaceEquipment(equipmentId: equipmentId, floor: floor, tileX: tileX)) return null;

    money -= cost;
    final placed = PlacedEquipment(
      instanceId: 'eq_${DateTime.now().microsecondsSinceEpoch}_${placements.length}',
      equipmentId: equipmentId,
      floor: floor,
      tileX: tileX,
    );
    placements.add(placed);
    return placed;
  }

  bool moveEquipment({
    required String instanceId,
    required int newFloor,
    required int newTileX,
  }) {
    final index = placements.indexWhere((p) => p.instanceId == instanceId);
    if (index == -1) return false;
    final target = placements[index];
    if (!canPlaceEquipment(
      equipmentId: target.equipmentId,
      floor: newFloor,
      tileX: newTileX,
      ignoreInstanceId: instanceId,
    )) {
      return false;
    }

    target.floor = newFloor;
    target.tileX = newTileX;
    return true;
  }

  int sellEquipment(String instanceId) {
    final index = placements.indexWhere((p) => p.instanceId == instanceId);
    if (index == -1) return 0;
    final target = placements[index];
    final meta = getEquipmentMeta(target.equipmentId);
    final refund = ((meta?.cost ?? 200) * 0.5).round();
    money += refund;
    placements.removeAt(index);
    return refund;
  }

  List<WeeklyActivityResult> processWeek({
    required int month,
    Map<String, FocusTapResult>? focusTaps,
    GameRng? rng,
  }) {
    final gameRng = rng ?? GameRng(DateTime.now().microsecondsSinceEpoch);
    final isSummer = (month == 4 || month == 5);
    final statCap = Balance.statCapsByTier[rankTier] ?? 60.0;

    lastWeeklyTuitionEarned = 0;
    lastWeeklyPassiveEarned = 0;

    // Check passive camp bonuses from placed equipment
    bool hasDuyan = false;
    bool hasBentilador = false;
    bool hasSariSari = false;
    double lakasBonus = 0.0;
    double bilisBonus = 0.0;
    double diskarteBonus = 0.0;
    double salagBonus = 0.0;
    double aralBonus = 0.0;

    for (final p in placements) {
      final id = p.equipmentId;
      if (id == 'duyan') hasDuyan = true;
      if (id == 'bentilador') hasBentilador = true;
      if (id == 'sari_sari_store') {
        hasSariSari = true;
        money += Balance.sariSariWeeklyPassiveIncome; // +P60/week
        lastWeeklyPassiveEarned += Balance.sariSariWeeklyPassiveIncome;
      }
      if (id == 'sako_buhangin') lakasBonus += 0.10;
      if (id == 'gulong_tire' || id == 'tire_dummy') lakasBonus += 0.15;
      if (id == 'pad_target') bilisBonus += 0.10;
      if (id == 'poste_kawayan') diskarteBonus += 0.10;
      if (id == 'salamin') salagBonus += 0.10;
      if (id == 'mesa_aklat') aralBonus += 0.10;
    }

    final results = <WeeklyActivityResult>[];

    for (final s in students) {
      // Collect tuition if active
      if (s.status == StudentStatus.aktibo) {
        money += s.tuition;
        lastWeeklyTuitionEarned += s.tuition;
      }

      // Determine equipment bonus matching student's current activity
      double eqBonus = 0.0;
      switch (s.currentActivity) {
        case ActivityType.sanayLakas:
          eqBonus = lakasBonus;
          break;
        case ActivityType.sanayBilis:
          eqBonus = bilisBonus;
          break;
        case ActivityType.sanayDiskarte:
          eqBonus = diskarteBonus;
          break;
        case ActivityType.sanaySalag:
        case ActivityType.sanayAnyo:
          eqBonus = salagBonus;
          break;
        case ActivityType.aral:
          eqBonus = aralBonus;
          break;
        default:
          break;
      }

      // Calculate matching trainer bonus
      double trainerBonus = 0.0;
      for (final t in trainers) {
        if (t.specialty == 'all' ||
            (s.currentActivity == ActivityType.sanayLakas && t.specialty == 'lakas') ||
            (s.currentActivity == ActivityType.sanayBilis && t.specialty == 'bilis') ||
            (s.currentActivity == ActivityType.sanayDiskarte && t.specialty == 'diskarte') ||
            (s.currentActivity == ActivityType.sanaySalag && t.specialty == 'salag') ||
            (s.currentActivity == ActivityType.aral && t.specialty == 'aral')) {
          trainerBonus += (t.skill * 0.04);
        }
      }

      final res = s.processWeeklyActivity(
        statCap: statCap,
        equipmentBonus: eqBonus,
        trainerBonus: trainerBonus,
        hasDuyan: hasDuyan,
        hasBentilador: hasBentilador,
        hasSariSari: hasSariSari,
        isSummerBreak: isSummer,
        focusTap: focusTaps?[s.id],
        rng: gameRng,
      );
      results.add(res);
    }

    return results;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'money': money,
        'fame': fame,
        'rankTier': rankTier,
        'floors': floors,
        'placements': placements.map((p) => p.toJson()).toList(),
        'students': students.map((s) => s.toJson()).toList(),
        'trainers': trainers.map((t) => t.toJson()).toList(),
        'unlockedTournaments': unlockedTournaments,
        'flags': flags,
      };

  factory Camp.fromJson(Map<String, dynamic> json) => Camp(
        name: json['name'] as String? ?? 'Bakuran Arnis Camp',
        money: json['money'] as int? ?? 1000,
        fame: json['fame'] as int? ?? 0,
        rankTier: json['rankTier'] as String? ?? 'purok',
        floors: json['floors'] as int? ?? 1,
        placements: (json['placements'] as List<dynamic>?)
            ?.map((e) => PlacedEquipment.fromJson(e as Map<String, dynamic>))
            .toList(),
        students: (json['students'] as List<dynamic>?)
            ?.map((e) => Student.fromJson(e as Map<String, dynamic>))
            .toList(),
        trainers: (json['trainers'] as List<dynamic>?)
            ?.map((e) => Trainer.fromJson(e as Map<String, dynamic>))
            .toList(),
        unlockedTournaments: (json['unlockedTournaments'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        flags: json['flags'] as Map<String, dynamic>? ?? {},
      );
}
