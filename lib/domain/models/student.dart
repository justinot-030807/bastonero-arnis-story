// lib/domain/models/student.dart
// Pure Dart model for student arnisadors - no Flame imports.

import '../balance.dart';
import '../rng.dart';
import 'focus_tap.dart';

enum ArnisStyle {
  soloBaston,
  dobleBaston,
  espadaYDaga,
}

extension ArnisStyleExt on ArnisStyle {
  String get displayName {
    switch (this) {
      case ArnisStyle.soloBaston:
        return 'Solo Baston';
      case ArnisStyle.dobleBaston:
        return 'Doble Baston';
      case ArnisStyle.espadaYDaga:
        return 'Espada y Daga';
    }
  }

  String get shortName {
    switch (this) {
      case ArnisStyle.soloBaston:
        return 'Solo';
      case ArnisStyle.dobleBaston:
        return 'Doble';
      case ArnisStyle.espadaYDaga:
        return 'Espada';
    }
  }
}

enum StudentStatus {
  aktibo,
  injured,
  graduated,
  quit,
}

enum ActivityType {
  none,
  sanayLakas,
  sanayBilis,
  sanayDiskarte,
  sanaySalag,
  sanayAnyo,
  aral,
  hinga,
  spar,
}

extension ActivityTypeExt on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.sanayLakas:
        return 'Sanay: Lakas';
      case ActivityType.sanayBilis:
        return 'Sanay: Bilis';
      case ActivityType.sanayDiskarte:
        return 'Sanay: Diskarte';
      case ActivityType.sanaySalag:
        return 'Sanay: Salag';
      case ActivityType.sanayAnyo:
        return 'Sanay: Anyo';
      case ActivityType.aral:
        return 'Aral (Grado)';
      case ActivityType.hinga:
        return 'Hinga (Pahinga)';
      case ActivityType.spar:
        return 'Sparring';
      case ActivityType.none:
        return 'Wala';
    }
  }

  String get shortName {
    switch (this) {
      case ActivityType.sanayLakas:
        return 'Lakas';
      case ActivityType.sanayBilis:
        return 'Bilis';
      case ActivityType.sanayDiskarte:
        return 'Diskarte';
      case ActivityType.sanaySalag:
        return 'Salag';
      case ActivityType.sanayAnyo:
        return 'Anyo';
      case ActivityType.aral:
        return 'Aral';
      case ActivityType.hinga:
        return 'Hinga';
      case ActivityType.spar:
        return 'Spar';
      case ActivityType.none:
        return 'Wala';
    }
  }
}

class WeeklyActivityResult {
  final String studentId;
  final String studentName;
  final ActivityType activity;
  final double lakasGain;
  final double bilisGain;
  final double diskarteGain;
  final double salagGain;
  final double gradeDelta;
  final double fatigueDelta;
  final double moraleDelta;
  final bool becameInjured;
  final bool recoveredFromInjury;
  final String? learnedMove;
  final FocusTapResult? focusTap;

  const WeeklyActivityResult({
    required this.studentId,
    required this.studentName,
    required this.activity,
    this.lakasGain = 0.0,
    this.bilisGain = 0.0,
    this.diskarteGain = 0.0,
    this.salagGain = 0.0,
    this.gradeDelta = 0.0,
    this.fatigueDelta = 0.0,
    this.moraleDelta = 0.0,
    this.becameInjured = false,
    this.recoveredFromInjury = false,
    this.learnedMove,
    this.focusTap,
  });

  bool get hasStatGains => lakasGain > 0 || bilisGain > 0 || diskarteGain > 0 || salagGain > 0;
}

class StudentLook {
  final String bodyTypeId;
  final int skinIndex;
  final int hairIndex;
  final int hairColorIndex;
  final int outfitColorIndex;
  final int headbandColorIndex;

  const StudentLook({
    this.bodyTypeId = 'body_a',
    this.skinIndex = 0,
    this.hairIndex = 0,
    this.hairColorIndex = 0,
    this.outfitColorIndex = 0,
    this.headbandColorIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'bodyTypeId': bodyTypeId,
        'skinIndex': skinIndex,
        'hairIndex': hairIndex,
        'hairColorIndex': hairColorIndex,
        'outfitColorIndex': outfitColorIndex,
        'headbandColorIndex': headbandColorIndex,
      };

  factory StudentLook.fromJson(Map<String, dynamic> json) => StudentLook(
        bodyTypeId: json['bodyTypeId'] as String? ?? 'body_a',
        skinIndex: json['skinIndex'] as int? ?? 0,
        hairIndex: json['hairIndex'] as int? ?? 0,
        hairColorIndex: json['hairColorIndex'] as int? ?? 0,
        outfitColorIndex: json['outfitColorIndex'] as int? ?? 0,
        headbandColorIndex: json['headbandColorIndex'] as int? ?? 0,
      );
}

class Student {
  final String id;
  String name;
  String nickname;
  int age;
  String gender; // 'Lalaki' | 'Babae'
  int grade; // 1..12 or 0 = out of school / adult
  double gradePercent; // 0..100
  double lakas;
  double bilis;
  double diskarte;
  double salag;
  double fatigue; // 0..100 (Pagod)
  double morale; // 0..100 (Gana)
  ArnisStyle style;
  List<String> moves; // max 4
  List<String> traits; // up to 2
  int tuition; // weekly fee in Pesos
  double potential; // 0.6..1.4 growth multiplier
  StudentLook look;
  StudentStatus status;
  int injuryWeeks;
  int wins;
  int losses;
  List<String> titles;
  ActivityType currentActivity;

  Student({
    required this.id,
    required this.name,
    this.nickname = '',
    this.age = 11,
    this.gender = 'Lalaki',
    this.grade = 5,
    this.gradePercent = 85.0,
    this.lakas = 15.0,
    this.bilis = 14.0,
    this.diskarte = 13.0,
    this.salag = 11.0,
    this.fatigue = 0.0,
    this.morale = 80.0,
    this.style = ArnisStyle.soloBaston,
    List<String>? moves,
    List<String>? traits,
    this.tuition = 50,
    this.potential = 1.0,
    this.look = const StudentLook(),
    this.status = StudentStatus.aktibo,
    this.injuryWeeks = 0,
    this.wins = 0,
    this.losses = 0,
    List<String>? titles,
    this.currentActivity = ActivityType.none,
  })  : moves = moves ?? ['abaniko'],
        traits = traits ?? ['Masipag'],
        titles = titles ?? [];

  double get totalStats => lakas + bilis + diskarte + salag;

  double get maxHp => Balance.hpBaseOffset + (totalStats * Balance.hpStatMultiplier);

  bool get isEligibleForSchoolVarsity => gradePercent >= Balance.varsityEligibilityGrade;
  bool get isVarsityEligible => gradePercent >= Balance.varsityEligibilityGrade;
  bool get isIntramsEligible => gradePercent >= Balance.intramsEligibilityGrade;
  bool get isAcademicWarning => gradePercent < Balance.intramsEligibilityGrade;
  bool get isFailing => gradePercent < Balance.varsityEligibilityGrade;

  String get gradeDescription {
    if (grade == 0) return 'Bukas / Adult';
    if (grade <= 6) return 'Grade $grade (Elementarya)';
    return 'Grade $grade (Sekondarya)';
  }

  WeeklyActivityResult processWeeklyActivity({
    required double statCap,
    double equipmentBonus = 0.0,
    double trainerBonus = 0.0,
    bool hasDuyan = false,
    bool hasBentilador = false,
    bool hasSariSari = false,
    bool isSummerBreak = false,
    FocusTapResult? focusTap,
    GameRng? rng,
  }) {
    final gameRng = rng ?? GameRng(DateTime.now().microsecondsSinceEpoch);

    // If student is currently injured:
    if (status == StudentStatus.injured) {
      final recoveryRate = (currentActivity == ActivityType.hinga ? 2 : 1);
      injuryWeeks -= recoveryRate;
      if (injuryWeeks <= 0) {
        injuryWeeks = 0;
        status = StudentStatus.aktibo;
        return WeeklyActivityResult(
          studentId: id,
          studentName: name,
          activity: currentActivity,
          recoveredFromInjury: true,
          fatigueDelta: -10.0,
        );
      }
      return WeeklyActivityResult(
        studentId: id,
        studentName: name,
        activity: currentActivity,
      );
    }

    double dLakas = 0.0;
    double dBilis = 0.0;
    double dDiskarte = 0.0;
    double dSalag = 0.0;
    double dGrade = 0.0;
    double dFatigue = 0.0;
    double dMorale = 0.0;
    bool newInjury = false;

    // Trait modifiers
    double traitMult = 0.0;
    if (traits.contains('Masipag')) traitMult += 0.10;
    if (traits.contains('Tamad')) traitMult -= 0.10;

    // Focus tap modifier
    final focusBonus = focusTap?.rating.bonusMultiplier ?? 0.0;

    // Fatigue penalty multiplier (>70 fatigue gives -30% gains)
    final fatiguePenalty = fatigue > Balance.highFatigueThreshold ? Balance.highFatigueGainPenalty : 1.0;

    // Random variance 0.85 .. 1.15
    final variance = gameRng.rangeDouble(0.85, 1.15);

    // Composite growth multiplier
    final totalMult = (0.6 + 0.4 * (morale / 100.0)) *
        (1.0 + equipmentBonus + trainerBonus + traitMult) *
        potential *
        variance *
        fatiguePenalty *
        (1.0 + focusBonus);

    switch (currentActivity) {
      case ActivityType.sanayLakas:
        dLakas = Balance.baseTrainingPrimaryGain * totalMult;
        dBilis = Balance.baseTrainingSecondaryGain * totalMult;
        dFatigue = Balance.fatigueTrainCost;
        break;

      case ActivityType.sanayBilis:
        final bilisTrait = traits.contains('Maliksi') ? 0.05 : 0.0;
        dBilis = Balance.baseTrainingPrimaryGain * (totalMult + bilisTrait);
        dDiskarte = Balance.baseTrainingSecondaryGain * totalMult;
        dFatigue = Balance.fatigueTrainCost;
        break;

      case ActivityType.sanayDiskarte:
        dDiskarte = Balance.baseTrainingPrimaryGain * totalMult;
        dSalag = Balance.baseTrainingSecondaryGain * totalMult;
        dFatigue = Balance.fatigueTrainCost;
        break;

      case ActivityType.sanaySalag:
        dSalag = Balance.baseTrainingPrimaryGain * totalMult;
        dLakas = Balance.baseTrainingSecondaryGain * totalMult;
        dFatigue = Balance.fatigueTrainCost;
        break;

      case ActivityType.sanayAnyo:
        dLakas = 0.5 * totalMult;
        dBilis = 0.5 * totalMult;
        dDiskarte = 0.5 * totalMult;
        dSalag = 0.5 * totalMult;
        dFatigue = Balance.fatigueTrainCost;
        break;

      case ActivityType.aral:
        if (!isSummerBreak && grade > 0) {
          final matalinoTrait = traits.contains('Matalino') ? 0.15 : 0.0;
          dGrade = Balance.baseStudyGradeGain * (1.0 + equipmentBonus + trainerBonus + matalinoTrait);
          dFatigue = Balance.fatigueStudyCost;
        }
        break;

      case ActivityType.hinga:
        final duyanBonus = hasDuyan ? 10.0 : 0.0;
        dFatigue = -(Balance.fatigueRestRecovery + duyanBonus);
        dMorale = Balance.moraleRestRecovery + (traits.contains('Tamad') ? 5.0 : 0.0);
        break;

      case ActivityType.spar:
        final statRoll = gameRng.nextInt(4);
        final sparGain = Balance.baseSparStatGain * totalMult;
        if (statRoll == 0) dLakas = sparGain;
        if (statRoll == 1) dBilis = sparGain;
        if (statRoll == 2) dDiskarte = sparGain;
        if (statRoll == 3) dSalag = sparGain;
        dFatigue = Balance.fatigueSparCost;
        break;

      case ActivityType.none:
        dFatigue = -10.0;
        break;
    }

    // Academic grade decay if not studying during school months
    if (currentActivity != ActivityType.aral && !isSummerBreak && grade > 0) {
      dGrade = -gameRng.rangeDouble(0.3, 0.5);
    }

    // Passive floor bonuses
    if (hasBentilador) dMorale += 2.0;
    if (hasSariSari) dMorale += 3.0;

    // Apply stat changes (respecting stat cap per camp rank)
    lakas = (lakas + dLakas).clamp(0.0, statCap);
    bilis = (bilis + dBilis).clamp(0.0, statCap);
    diskarte = (diskarte + dDiskarte).clamp(0.0, statCap);
    salag = (salag + dSalag).clamp(0.0, statCap);
    if (dGrade != 0.0) {
      gradePercent = (gradePercent + dGrade).clamp(0.0, 100.0);
    }

    // Apply fatigue & morale
    fatigue = (fatigue + dFatigue).clamp(0.0, 100.0);
    morale = (morale + dMorale).clamp(0.0, 100.0);

    // Injury check (only on training/spar)
    if (currentActivity == ActivityType.sanayLakas ||
        currentActivity == ActivityType.sanayBilis ||
        currentActivity == ActivityType.sanayDiskarte ||
        currentActivity == ActivityType.sanaySalag ||
        currentActivity == ActivityType.sanayAnyo ||
        currentActivity == ActivityType.spar) {
      final baseChance = fatigue > Balance.extremeFatigueThreshold
          ? Balance.baseInjuryChanceExhausted
          : Balance.baseInjuryChanceNormal;
      final injuryChance = baseChance * (traits.contains('Matibay') ? 0.8 : 1.0);
      if (gameRng.nextDouble() < injuryChance) {
        newInjury = true;
        status = StudentStatus.injured;
        injuryWeeks = gameRng.rangeInt(2, 4);
      }
    }

    return WeeklyActivityResult(
      studentId: id,
      studentName: name,
      activity: currentActivity,
      lakasGain: dLakas,
      bilisGain: dBilis,
      diskarteGain: dDiskarte,
      salagGain: dSalag,
      gradeDelta: dGrade,
      fatigueDelta: dFatigue,
      moraleDelta: dMorale,
      becameInjured: newInjury,
      focusTap: focusTap,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'age': age,
        'gender': gender,
        'grade': grade,
        'gradePercent': gradePercent,
        'lakas': lakas,
        'bilis': bilis,
        'diskarte': diskarte,
        'salag': salag,
        'fatigue': fatigue,
        'morale': morale,
        'style': style.name,
        'moves': moves,
        'traits': traits,
        'tuition': tuition,
        'potential': potential,
        'look': look.toJson(),
        'status': status.name,
        'injuryWeeks': injuryWeeks,
        'wins': wins,
        'losses': losses,
        'titles': titles,
        'currentActivity': currentActivity.name,
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String? ?? '',
        age: json['age'] as int? ?? 11,
        gender: json['gender'] as String? ?? 'Lalaki',
        grade: json['grade'] as int? ?? 5,
        gradePercent: (json['gradePercent'] as num?)?.toDouble() ?? 85.0,
        lakas: (json['lakas'] as num?)?.toDouble() ?? 15.0,
        bilis: (json['bilis'] as num?)?.toDouble() ?? 14.0,
        diskarte: (json['diskarte'] as num?)?.toDouble() ?? 13.0,
        salag: (json['salag'] as num?)?.toDouble() ?? 11.0,
        fatigue: (json['fatigue'] as num?)?.toDouble() ?? 0.0,
        morale: (json['morale'] as num?)?.toDouble() ?? 80.0,
        style: ArnisStyle.values.firstWhere(
          (e) => e.name == json['style'],
          orElse: () => ArnisStyle.soloBaston,
        ),
        moves: (json['moves'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        traits: (json['traits'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        tuition: json['tuition'] as int? ?? 50,
        potential: (json['potential'] as num?)?.toDouble() ?? 1.0,
        look: json['look'] != null ? StudentLook.fromJson(json['look'] as Map<String, dynamic>) : const StudentLook(),
        status: StudentStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => StudentStatus.aktibo,
        ),
        injuryWeeks: json['injuryWeeks'] as int? ?? 0,
        wins: json['wins'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        titles: (json['titles'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        currentActivity: ActivityType.values.firstWhere(
          (e) => e.name == json['currentActivity'],
          orElse: () => ActivityType.none,
        ),
      );
}
