import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/fighter_model.dart';
import '../models/facility_model.dart';
import '../models/tournament_model.dart';
import '../models/story_event_model.dart';
import '../utils/storage_service.dart';

enum ActionType {
  trainPower,
  trainSpeed,
  trainTechnique,
  trainDefense,
  study,
  rest,
  spar,
}

class GameStateProvider extends ChangeNotifier {
  // Calendar Progression
  int year = 1; // Year 1 = Grade 5 (Elementary, Age 11)
  int month = 6; // June (Month 6) starts the school year in PH
  int week = 1; // 1 to 4 weeks per month

  // Currencies & Reputation
  int pesos = 600;
  int prestige = 0;

  // Gym Facilities (Starts with 4 slots, expandable to 8)
  int maxSlots = 4;
  late List<FacilityModel?> slots;

  // Fighter
  late FighterModel fighter;

  // Tournaments & Story Events
  List<TournamentModel> tournaments = [];
  List<StoryEvent> storyEvents = [];
  StoryEvent? activeDialogueEvent;

  // Recent Action Log for Kairosoft-style ticker notifications
  String recentLog = 'Maligayang pagdating sa Bastonero: Arnis Story!';

  // Month names in English & Filipino context
  static const List<String> monthNames = [
    'January (Bagong Taon)',
    'February (Regional Meet)',
    'March (Graduation Review)',
    'April (Summer Camp)',
    'May (Fiesta / Palaro)',
    'June (Pasukan / School Starts)',
    'July (1st Grading)',
    'August (Mayor\'s Cup)',
    'September (School Intrams)',
    'October (Midterm Exams)',
    'November (Division Meet)',
    'December (Pasko / Holidays)',
  ];

  String get currentMonthName => monthNames[(month - 1) % 12];

  GameStateProvider() {
    _initializeDefaultState();
  }

  void _initializeDefaultState() {
    year = 1;
    month = 6;
    week = 1;
    pesos = 650;
    prestige = 0;
    maxSlots = 4;

    slots = List<FacilityModel?>.filled(8, null);
    // Starter facility in slot 0: Gulong Target
    slots[0] = FacilityModel(
      id: 'starter_gulong',
      type: FacilityType.gulongTarget,
      level: 1,
      slotIndex: 0,
    );
    // Starter facility in slot 1: Mango tree desk
    slots[1] = FacilityModel(
      id: 'starter_desk',
      type: FacilityType.studyDesk,
      level: 1,
      slotIndex: 1,
    );

    fighter = FighterModel(
      name: 'Bayani "Bastonero"',
      gradeLevel: 5,
      age: 11,
      maxHp: 100.0,
      hp: 100.0,
      maxStamina: 100.0,
      stamina: 100.0,
      power: 15.0,
      speed: 14.0,
      technique: 13.0,
      defense: 11.0,
      academics: 86.0, // starts varsity eligible
      style: FighterStyle.soloBaston,
      equippedWeapon: WeaponItem.yantok,
      equippedGears: [GearItem.rubberShoes],
      isPlayer: true,
    );

    tournaments = TournamentModel.generateDefaultTournaments();
    storyEvents = StoryEvent.generateDefaultStoryEvents();

    // Trigger initial coach intro dialog
    checkStoryTriggers('start');
  }

  // Active Synergies evaluated from slot placements
  List<SynergyCombo> get activeSynergies {
    final activeSlots = slots.sublist(0, maxSlots);
    return SynergyCombo.evaluateSynergies(activeSlots);
  }

  // Multiplier Aggregation
  double get totalPowerMultiplier {
    double mult = 1.0;
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) mult += (f.powerMultiplier - 1.0);
    }
    for (final s in activeSynergies) {
      mult += s.powerXpBonus;
    }
    return mult;
  }

  double get totalSpeedMultiplier {
    double mult = 1.0;
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) mult += (f.speedMultiplier - 1.0);
    }
    for (final s in activeSynergies) {
      mult += s.speedXpBonus;
    }
    return mult;
  }

  double get totalTechniqueMultiplier {
    double mult = 1.0;
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) mult += (f.techniqueMultiplier - 1.0);
    }
    for (final s in activeSynergies) {
      mult += s.techniqueXpBonus;
    }
    return mult;
  }

  double get totalDefenseMultiplier {
    double mult = 1.0;
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) mult += (f.defenseMultiplier - 1.0);
    }
    for (final s in activeSynergies) {
      mult += s.defenseXpBonus;
    }
    return mult;
  }

  double get totalAcademicsMultiplier {
    double mult = 1.0;
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) mult += (f.academicsMultiplier - 1.0);
    }
    for (final s in activeSynergies) {
      mult += s.academicBonus;
    }
    return mult;
  }

  double get totalStaminaCostReduction {
    double red = 0.0;
    for (final s in activeSynergies) {
      red += s.staminaCostReduction;
    }
    return red.clamp(0.0, 0.50);
  }

  int get totalPassiveWeeklyPesos {
    int income = 0;
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) income += f.weeklyPassivePesos;
    }
    for (final s in activeSynergies) {
      income += s.bonusPassivePesos;
    }
    return income;
  }

  double get totalPassiveWeeklyStaminaRecovery {
    double rec = 10.0; // base natural weekly recovery
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) rec += f.weeklyStaminaRecoveryBonus;
    }
    return rec;
  }

  // WEEK ADVANCEMENT & CALENDAR LOGIC
  void advanceOneWeek({String actionSummary = ''}) {
    week += 1;
    if (week > 4) {
      week = 1;
      month += 1;

      // Handle Year Progression (Month 13 wraps to Month 1)
      if (month > 12) {
        month = 1;
        year += 1;
        _handleYearEndEvaluation();
      }
    }

    // Passive Income from Buko Stands & Synergies
    final weeklyIncome = totalPassiveWeeklyPesos;
    if (weeklyIncome > 0) {
      pesos += weeklyIncome;
    }

    // Passive Stamina Recovery
    fighter.stamina = (fighter.stamina + totalPassiveWeeklyStaminaRecovery)
        .clamp(0.0, fighter.maxStamina);

    // Natural Academic Decay if no studying occurred
    fighter.academics = (fighter.academics - 0.4).clamp(65.0, 100.0);

    // Check if grade drops below varsity requirement
    if (fighter.academics < 80.0) {
      checkStoryTriggers('grade_warning');
    }

    // Check month-based story events
    checkStoryTriggers('month_$month');

    if (actionSummary.isNotEmpty) {
      recentLog = actionSummary;
    }

    notifyListeners();
    saveGame();
  }

  void _handleYearEndEvaluation() {
    fighter.age += 1;
    if (fighter.isPassingSchool) {
      fighter.gradeLevel += 1;
      recentLog = 'Promoted to ${fighter.gradeLevelDescription}! Grado: ${fighter.academics.toStringAsFixed(1)}';
      pesos += 500; // DepEd student allowance bonus
    } else {
      recentLog = 'Retained! Failed the school year with Grado: ${fighter.academics.toStringAsFixed(1)}';
    }
  }

  // TRAINING ACTIONS
  bool performTraining(ActionType type) {
    double baseStaminaCost = 20.0;
    final reducedCost = baseStaminaCost * (1.0 - totalStaminaCostReduction);

    if (fighter.stamina < reducedCost) {
      recentLog = 'Sobra ang pagod! Mag-pahinga (Rest) muna upang manumbalik ang lakas.';
      notifyListeners();
      return false;
    }

    fighter.stamina = (fighter.stamina - reducedCost).clamp(0.0, fighter.maxStamina);
    final rnd = Random();

    switch (type) {
      case ActionType.trainPower:
        final gain = (1.5 + rnd.nextDouble() * 1.5) * totalPowerMultiplier;
        fighter.power += gain;
        fighter.maxHp += 2.0;
        fighter.hp = fighter.maxHp;
        advanceOneWeek(
          actionSummary: 'Nagpalakas sa Gulong Dummy! +${gain.toStringAsFixed(1)} Power (Lakas)!',
        );
        break;

      case ActionType.trainSpeed:
        final gain = (1.5 + rnd.nextDouble() * 1.5) * totalSpeedMultiplier;
        fighter.speed += gain;
        advanceOneWeek(
          actionSummary: 'Tumalon sa Footwork Tires! +${gain.toStringAsFixed(1)} Speed (Bilis)!',
        );
        break;

      case ActionType.trainTechnique:
        final gain = (1.4 + rnd.nextDouble() * 1.4) * totalTechniqueMultiplier;
        fighter.technique += gain;
        // Also boost mastery of active style
        final currentMastery = fighter.styleMasteries[fighter.style] ?? 1;
        if (currentMastery < 10 && rnd.nextDouble() > 0.6) {
          fighter.styleMasteries[fighter.style] = currentMastery + 1;
          recentLog = 'Tumalon ang Mastery ng ${fighter.style.displayName} sa Lvl ${currentMastery + 1}!';
        }
        advanceOneWeek(
          actionSummary: 'Bumantay ng Anyo at Sinawali! +${gain.toStringAsFixed(1)} Technique!',
        );
        break;

      case ActionType.trainDefense:
        final gain = (1.3 + rnd.nextDouble() * 1.3) * totalDefenseMultiplier;
        fighter.defense += gain;
        fighter.maxHp += 1.5;
        fighter.hp = fighter.maxHp;
        advanceOneWeek(
          actionSummary: 'Nagsanay ng Salag at Blocking! +${gain.toStringAsFixed(1)} Defense!',
        );
        break;

      case ActionType.study:
        fighter.stamina = (fighter.stamina - 10.0).clamp(0.0, fighter.maxStamina);
        final gradeBoost = (2.5 + rnd.nextDouble() * 2.5) * totalAcademicsMultiplier;
        fighter.academics = (fighter.academics + gradeBoost).clamp(65.0, 100.0);
        advanceOneWeek(
          actionSummary: 'Nag-aral sa ilalim ng Mangga! +${gradeBoost.toStringAsFixed(1)} Grado (${fighter.academics.toStringAsFixed(1)})!',
        );
        break;

      case ActionType.rest:
        fighter.stamina = fighter.maxStamina;
        fighter.hp = fighter.maxHp;
        pesos += 50; // sideline chores
        advanceOneWeek(
          actionSummary: 'Uminom ng buko at nagpahinga! 100% Stamina & HP naibalik!',
        );
        break;

      case ActionType.spar:
        final gain = 0.8 + rnd.nextDouble() * 0.8;
        fighter.power += gain * totalPowerMultiplier;
        fighter.speed += gain * totalSpeedMultiplier;
        fighter.technique += gain * totalTechniqueMultiplier;
        fighter.defense += gain * totalDefenseMultiplier;
        advanceOneWeek(
          actionSummary: 'Nag-sparring sa Ring! Lahat ng stats tumaas ng +${gain.toStringAsFixed(1)}!',
        );
        break;
    }

    return true;
  }

  // GYM FACILITY BUILDING & EXPANSION
  bool buildFacility(int slotIndex, FacilityType type) {
    if (slotIndex < 0 || slotIndex >= maxSlots) return false;
    if (pesos < type.baseCost) {
      recentLog = 'Kulang ang Pesos! Kailangan ng ₱${type.baseCost}.';
      notifyListeners();
      return false;
    }

    pesos -= type.baseCost;
    slots[slotIndex] = FacilityModel(
      id: 'fac_${DateTime.now().millisecondsSinceEpoch}_$slotIndex',
      type: type,
      level: 1,
      slotIndex: slotIndex,
    );

    recentLog = 'Itinayo ang ${type.displayName} sa Slot ${slotIndex + 1}!';
    notifyListeners();
    saveGame();
    return true;
  }

  bool upgradeFacility(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= maxSlots) return false;
    final facility = slots[slotIndex];
    if (facility == null) return false;

    if (pesos < facility.upgradeCost) {
      recentLog = 'Kulang ang Pesos para i-upgrade ang ${facility.type.displayName}!';
      notifyListeners();
      return false;
    }

    pesos -= facility.upgradeCost;
    facility.level += 1;
    recentLog = 'Na-upgrade ang ${facility.type.displayName} sa Level ${facility.level}!';
    notifyListeners();
    saveGame();
    return true;
  }

  bool demolishFacility(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= maxSlots) return false;
    final facility = slots[slotIndex];
    if (facility == null) return false;

    final refund = (facility.type.baseCost * 0.4).round();
    pesos += refund;
    slots[slotIndex] = null;
    recentLog = 'Binuwag ang ${facility.type.displayName}. Nabawi ang ₱$refund.';
    notifyListeners();
    saveGame();
    return true;
  }

  bool expandGymSlots() {
    if (maxSlots >= 8) return false;
    const cost = 1800;
    if (pesos < cost) {
      recentLog = 'Kulang ang Pesos para lumawak ang bakuran! Kailangan ng ₱$cost.';
      notifyListeners();
      return false;
    }

    pesos -= cost;
    maxSlots = 8;
    recentLog = 'Lumawak ang gym bakuran! Mayroon ka nang 8 slots!';
    notifyListeners();
    saveGame();
    return true;
  }

  // EQUIPMENT MANAGEMENT
  bool buyWeapon(WeaponItem weapon) {
    if (pesos < weapon.price) {
      recentLog = 'Kulang ang Pesos para sa ${weapon.name}!';
      notifyListeners();
      return false;
    }
    pesos -= weapon.price;
    fighter.equippedWeapon = weapon;
    recentLog = 'Binili at isinuot ang ${weapon.name}!';
    notifyListeners();
    saveGame();
    return true;
  }

  bool buyGear(GearItem gear) {
    if (pesos < gear.price) {
      recentLog = 'Kulang ang Pesos para sa ${gear.name}!';
      notifyListeners();
      return false;
    }
    pesos -= gear.price;
    // Replace gear with same id or add
    fighter.equippedGears.removeWhere((g) => g.id == gear.id);
    fighter.equippedGears.add(gear);
    recentLog = 'Binili at isinuot ang ${gear.name}!';
    notifyListeners();
    saveGame();
    return true;
  }

  void switchStyle(FighterStyle newStyle) {
    fighter.style = newStyle;
    recentLog = 'Pinalitan ang istilo: ${newStyle.displayName}!';
    notifyListeners();
    saveGame();
  }

  // TOURNAMENT COMPLETION & REWARDS
  void completeTournament(TournamentModel tournament, bool won) {
    if (won) {
      pesos += tournament.prizeMoney;
      prestige += tournament.prestigeReward;
      tournament.isCompleted = true;

      // Small permanent stat growth from winning laban
      fighter.power += 1.0;
      fighter.speed += 1.0;
      fighter.technique += 1.5;
      fighter.defense += 1.0;

      recentLog = 'Kampeon sa ${tournament.title}! Nanalo ng ₱${tournament.prizeMoney} & +${tournament.prestigeReward} Prestige!';

      if (tournament.id == 'division_meet') {
        checkStoryTriggers('division_won');
      }
    } else {
      pesos += (tournament.prizeMoney * 0.15).round();
      recentLog = 'Natalo sa ${tournament.title}. Huwag sumuko, magsanay muli!';
    }

    advanceOneWeek();
  }

  // STORY EVENT TRIGGER SYSTEM
  void checkStoryTriggers(String condition) {
    for (final event in storyEvents) {
      if (!event.isTriggered && event.triggerCondition == condition) {
        activeDialogueEvent = event;
        notifyListeners();
        break;
      }
    }
  }

  void dismissActiveDialogue() {
    if (activeDialogueEvent != null) {
      final event = activeDialogueEvent!;
      event.isTriggered = true;
      if (event.rewardPesos > 0) pesos += event.rewardPesos;
      if (event.rewardAcademics > 0) fighter.academics = (fighter.academics + event.rewardAcademics).clamp(65.0, 100.0);
      if (event.rewardPower > 0) fighter.power += event.rewardPower;
      if (event.rewardTechnique > 0) fighter.technique += event.rewardTechnique;

      activeDialogueEvent = null;
      notifyListeners();
      saveGame();
    }
  }

  // SAVE & LOAD VIA STORAGE SERVICE
  Future<void> saveGame() async {
    final data = {
      'year': year,
      'month': month,
      'week': week,
      'pesos': pesos,
      'prestige': prestige,
      'maxSlots': maxSlots,
      'fighter': fighter.toJson(),
      'slots': slots.map((s) => s?.toJson()).toList(),
      'tournaments': tournaments.map((t) => t.toJson()).toList(),
      'storyEvents': storyEvents.map((e) => e.toJson()).toList(),
    };
    await StorageService.saveGame(data);
  }

  Future<bool> loadSavedGame() async {
    final data = await StorageService.loadGame();
    if (data == null) return false;

    try {
      year = data['year'] as int? ?? 1;
      month = data['month'] as int? ?? 6;
      week = data['week'] as int? ?? 1;
      pesos = data['pesos'] as int? ?? 650;
      prestige = data['prestige'] as int? ?? 0;
      maxSlots = data['maxSlots'] as int? ?? 4;

      if (data['fighter'] != null) {
        fighter = FighterModel.fromJson(data['fighter'] as Map<String, dynamic>);
      }

      final rawSlots = data['slots'] as List<dynamic>?;
      slots = List<FacilityModel?>.filled(8, null);
      if (rawSlots != null) {
        for (int i = 0; i < rawSlots.length && i < 8; i++) {
          final slotData = rawSlots[i];
          if (slotData != null) {
            slots[i] = FacilityModel.fromJson(slotData as Map<String, dynamic>);
          }
        }
      }

      final rawTournaments = data['tournaments'] as List<dynamic>?;
      if (rawTournaments != null) {
        tournaments = rawTournaments
            .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final rawStories = data['storyEvents'] as List<dynamic>?;
      if (rawStories != null) {
        storyEvents = rawStories
            .map((e) => StoryEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      recentLog = 'Game loaded successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
