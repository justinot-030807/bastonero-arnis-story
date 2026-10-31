import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/fighter_model.dart';
import '../models/facility_model.dart';
import '../models/tournament_model.dart';
import '../models/story_event_model.dart';
import '../models/inventory_model.dart';
import '../models/opponent_record_model.dart';
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
  // Save Slot & Flow
  int activeSlotIndex = 1;
  bool isInTitleScreen = true;

  // Calendar Progression
  int year = 1; // Year 1 = Grade 5 (Elementary, Age 11)
  int month = 6; // June (Month 6) starts the school year in PH
  int week = 1; // 1 to 4 weeks per month

  // Currencies & Reputation
  int pesos = 650;
  int prestige = 0;

  // Gym Facilities (Starts with 2 cutaway slots, expandable to 4 and 6)
  int maxSlots = 2;
  late List<FacilityModel?> slots;

  // Fighter
  late FighterModel fighter;

  // Inventory & Nutritional Buffs
  List<InventoryItem> inventory = [];
  List<ActiveBuff> activeBuffs = [];

  // Audio / Settings
  double bgmVolume = 0.8;
  double sfxVolume = 1.0;

  // Tournaments & Story Events
  List<TournamentModel> tournaments = [];
  List<StoryEvent> storyEvents = [];
  StoryEvent? activeDialogueEvent;

  // Opponent Head-to-Head Dossier Records
  Map<String, OpponentRecord> opponentRecords = {};

  // Recent Action Log for Kairosoft-style ticker notifications (Zero Emojis!)
  String recentLog = 'Maligayang pagdating sa Bastonero: Arnis Story!';

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
    maxSlots = 2; // Cutaway begins with 2 slots, expands to 4 then 6

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
      academics: 86.0,
      style: FighterStyle.soloBaston,
      equippedWeapon: WeaponItem.yantok,
      equippedGears: [GearItem.rubberShoes],
      isPlayer: true,
    );

    tournaments = TournamentModel.generateDefaultTournaments();
    storyEvents = StoryEvent.generateDefaultStoryEvents();
    inventory = InventoryItem.createDefaultCatalog();
    activeBuffs = [];

    // Pre-load default opponent dossier records
    opponentRecords = {
      'Berto Batuta': OpponentRecord(
        id: 'Berto Batuta',
        name: 'Berto Batuta',
        title: 'Purok Heavy Hitter',
        gymName: 'Ilaya Bakbakan Gym',
        style: FighterStyle.soloBaston,
        matchesFought: 1,
        wins: 0,
        losses: 1,
        highestDamageDealt: 14,
        lastResult: 'TALO',
        lastEncounter: 'Elementary Grade 4',
      ),
      'Kanor "Sipol"': OpponentRecord(
        id: 'Kanor "Sipol"',
        name: 'Kanor "Sipol"',
        title: 'Tricycle Driver Arnisador',
        gymName: 'Toda Purok Club',
        style: FighterStyle.soloBaston,
        matchesFought: 0,
        wins: 0,
        losses: 0,
        highestDamageDealt: 0,
        lastResult: 'WALA PA',
        lastEncounter: 'Hindi pa nakaharap',
      ),
      'Dodong Eskrima': OpponentRecord(
        id: 'Dodong Eskrima',
        name: 'Dodong Eskrima',
        title: 'Barangay San Isidro Rep',
        gymName: 'San Isidro Bastoneros',
        style: FighterStyle.dobleBaston,
        matchesFought: 0,
        wins: 0,
        losses: 0,
        highestDamageDealt: 0,
        lastResult: 'WALA PA',
        lastEncounter: 'Hindi pa nakaharap',
      ),
      'Lorenzo Dela Cruz': OpponentRecord(
        id: 'Lorenzo Dela Cruz',
        name: 'Lorenzo Dela Cruz',
        title: 'Private Academy Prodigy',
        gymName: 'Dela Cruz Martial Guild',
        style: FighterStyle.espadaYDaga,
        matchesFought: 0,
        wins: 0,
        losses: 0,
        highestDamageDealt: 0,
        lastResult: 'WALA PA',
        lastEncounter: 'Hindi pa nakaharap',
      ),
    };

    checkStoryTriggers('start');
  }

  void enterGame() {
    isInTitleScreen = false;
    notifyListeners();
  }

  void returnToTitle() {
    isInTitleScreen = true;
    notifyListeners();
  }

  void startNewGame({
    int slot = 1,
    String? fighterName,
    String? fighterNickname,
    String? gymName,
    String? coachName,
    String? coachTitle,
    String? coachPerk,
    String? gender,
    int? skinIndex,
    int? headbandColorIndex,
    int? hairIndex,
    FighterStyle? startingStyle,
  }) {
    activeSlotIndex = slot;
    StorageService.setActiveSlotIndex(slot);
    _initializeDefaultState();

    if (fighterName != null && fighterName.trim().isNotEmpty) {
      fighter.name = fighterName.trim();
    }
    if (fighterNickname != null && fighterNickname.trim().isNotEmpty) {
      fighter.nickname = fighterNickname.trim();
    }
    if (gymName != null && gymName.trim().isNotEmpty) {
      fighter.gymName = gymName.trim();
    }
    if (coachName != null) fighter.coachName = coachName;
    if (coachTitle != null) fighter.coachTitle = coachTitle;
    if (coachPerk != null) fighter.coachPerk = coachPerk;
    if (gender != null) fighter.gender = gender;
    if (skinIndex != null) fighter.skinIndex = skinIndex;
    if (headbandColorIndex != null) fighter.headbandColorIndex = headbandColorIndex;
    if (hairIndex != null) fighter.hairIndex = hairIndex;
    if (startingStyle != null) {
      fighter.style = startingStyle;
      fighter.styleMasteries[startingStyle] = 2; // Starter mastery boost
    }

    _triggerPrologueStoryEvent();

    isInTitleScreen = false;
    notifyListeners();
    saveGame();
  }

  void _triggerPrologueStoryEvent() {
    activeDialogueEvent = StoryEvent(
      id: 'story_prologue',
      title: 'Panimula: Pangarap ng Bastonero',
      speaker: fighter.coachName,
      speakerRole: fighter.coachTitle,
      dialogues: [
        'Maligayang pagdating sa ${fighter.gymName}! Simple man ang ating bakuran at gawa lamang sa yantok at gulong ang ating mga gamit, dito sumisibol ang tunay na mandirigma.',
        'Coach, pangarap ko pong maging Kampeon at dalhin ang karangalan ng ating barangay!',
        'Maganda ang iyong apoy, ${fighter.name}! Ngunit tandaan: sa sports na ito, balance ang kailangan. Bawal ang bagsak sa klase—dapat Grado >= 80 para makasali sa School Varsity Intrams.',
        'Magsanay tayo sa gulong dummy, magbasa sa lilim ng mangga, at magsipag! Handa na ba ang iyong baston?',
      ],
      triggerCondition: 'start',
      rewardPesos: 150,
      rewardPower: 1.0,
      rewardTechnique: 1.0,
    );
  }

  // Active Synergies evaluated from slot placements
  List<SynergyCombo> get activeSynergies {
    final activeSlots = slots.sublist(0, maxSlots);
    return SynergyCombo.evaluateSynergies(activeSlots);
  }

  // Multiplier Aggregation including Nutritional Buffs
  double get totalPowerMultiplier {
    double mult = 1.0;
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f != null) mult += (f.powerMultiplier - 1.0);
    }
    for (final s in activeSynergies) {
      mult += s.powerXpBonus;
    }
    for (final b in activeBuffs) {
      mult += b.powerMultiplier;
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
    for (final b in activeBuffs) {
      mult += b.speedMultiplier;
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
    for (final b in activeBuffs) {
      mult += b.techniqueMultiplier;
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
    for (final b in activeBuffs) {
      mult += b.defenseMultiplier;
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
    for (final b in activeBuffs) {
      mult += b.academicBonus;
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
    double rec = 10.0;
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

      if (month > 12) {
        month = 1;
        year += 1;
        _handleYearEndEvaluation();
      }
    }

    // Passive Income & Recovery
    final weeklyIncome = totalPassiveWeeklyPesos;
    if (weeklyIncome > 0) {
      pesos += weeklyIncome;
    }

    fighter.stamina = (fighter.stamina + totalPassiveWeeklyStaminaRecovery)
        .clamp(0.0, fighter.maxStamina);

    fighter.academics = (fighter.academics - 0.4).clamp(65.0, 100.0);

    // Update Nutritional Buffs (countdown 1 week)
    for (final buff in activeBuffs) {
      buff.remainingWeeks -= 1;
    }
    activeBuffs.removeWhere((b) => b.remainingWeeks <= 0);

    // Facility harvests
    _handleFacilityHarvests();

    if (fighter.academics < 80.0) {
      checkStoryTriggers('grade_warning');
    }

    checkStoryTriggers('month_$month');

    if (actionSummary.isNotEmpty) {
      recentLog = actionSummary;
    }

    notifyListeners();
    saveGame();
  }

  void _handleFacilityHarvests() {
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f == null) continue;
      // Buko Stand harvests Buko Juice every 2 weeks
      if (f.type == FacilityType.bukoStand && week % 2 == 0) {
        final item = inventory.firstWhere((it) => it.id == 'buko_juice', orElse: () => inventory.first);
        item.quantity += 1;
        recentLog = '[ANI] Naka-ani ng 1 Sariwang Buko Juice mula sa Stand!';
      }
      // Mango tree desk harvests ripe mangoes in summer months (April/May)
      if (f.type == FacilityType.studyDesk && (month == 4 || month == 5) && week == 1) {
        final item = inventory.firstWhere((it) => it.id == 'mangga', orElse: () => inventory.first);
        item.quantity += 1;
        recentLog = '[ANI] Nahulog ang hinog na Mangga mula sa puno!';
      }
    }
  }

  void _handleYearEndEvaluation() {
    fighter.age += 1;
    if (fighter.isPassingSchool) {
      fighter.gradeLevel += 1;
      recentLog = '[PASA] Umabante sa ${fighter.gradeLevelDescription}! Grado: ${fighter.academics.toStringAsFixed(1)}';
      pesos += 500;
    } else {
      recentLog = '[REMEDIAL] Bagsak ang school year! Grado: ${fighter.academics.toStringAsFixed(1)}';
    }
  }

  // INVENTORY & NUTRITION CONSUMPTION
  bool consumeFoodItem(InventoryItem item) {
    if (item.quantity <= 0) return false;
    item.quantity -= 1;

    if (item.staminaRestore > 0) {
      fighter.stamina = (fighter.stamina + item.staminaRestore).clamp(0.0, fighter.maxStamina);
    }
    if (item.hpRestore > 0) {
      fighter.hp = (fighter.hp + item.hpRestore).clamp(0.0, fighter.maxHp);
    }
    if (item.academicGain > 0) {
      fighter.academics = (fighter.academics + item.academicGain).clamp(65.0, 100.0);
    }

    if (item.grantedBuff != null) {
      // Replace existing or add new
      activeBuffs.removeWhere((b) => b.id == item.grantedBuff!.id);
      activeBuffs.add(ActiveBuff(
        id: item.grantedBuff!.id,
        name: item.grantedBuff!.name,
        itemRef: item.grantedBuff!.itemRef,
        remainingWeeks: item.grantedBuff!.remainingWeeks,
        powerMultiplier: item.grantedBuff!.powerMultiplier,
        speedMultiplier: item.grantedBuff!.speedMultiplier,
        techniqueMultiplier: item.grantedBuff!.techniqueMultiplier,
        defenseMultiplier: item.grantedBuff!.defenseMultiplier,
        academicBonus: item.grantedBuff!.academicBonus,
      ));
    }

    recentLog = '[NUTRISYON] Kinain ang ${item.name}! Buff aktibo.';
    notifyListeners();
    saveGame();
    return true;
  }

  bool buyFoodItem(InventoryItem item, int amount) {
    final totalCost = item.price * amount;
    if (pesos < totalCost) {
      recentLog = '[TIANGGE] Kulang ang pera pambili ng ${item.name}!';
      notifyListeners();
      return false;
    }

    pesos -= totalCost;
    item.quantity += amount;
    recentLog = '[TIANGGE] Binili ang $amount x ${item.name} (P$totalCost).';
    notifyListeners();
    saveGame();
    return true;
  }

  // TRAINING ACTIONS
  bool performTraining(ActionType type) {
    double baseStaminaCost = 20.0;
    final reducedCost = baseStaminaCost * (1.0 - totalStaminaCostReduction);

    if (fighter.stamina < reducedCost) {
      recentLog = '[PAGOD] Magpahinga muna! Kulang sa hangin.';
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
          actionSummary: '[LAKAS] Hataw sa Gulong Dummy! +${gain.toStringAsFixed(1)} Lakas!',
        );
        break;

      case ActionType.trainSpeed:
        final gain = (1.5 + rnd.nextDouble() * 1.5) * totalSpeedMultiplier;
        fighter.speed += gain;
        advanceOneWeek(
          actionSummary: '[BILIS] Tumalon sa Footwork Tires! +${gain.toStringAsFixed(1)} Bilis!',
        );
        break;

      case ActionType.trainTechnique:
        final gain = (1.4 + rnd.nextDouble() * 1.4) * totalTechniqueMultiplier;
        fighter.technique += gain;
        final currentMastery = fighter.styleMasteries[fighter.style] ?? 1;
        if (currentMastery < 10 && rnd.nextDouble() > 0.6) {
          fighter.styleMasteries[fighter.style] = currentMastery + 1;
          recentLog = '[MASTERY] ${fighter.style.displayName} tumaas sa Lvl ${currentMastery + 1}!';
        }
        advanceOneWeek(
          actionSummary: '[DISKARTE] Sinawali at Anyo! +${gain.toStringAsFixed(1)} Diskarte!',
        );
        break;

      case ActionType.trainDefense:
        final gain = (1.3 + rnd.nextDouble() * 1.3) * totalDefenseMultiplier;
        fighter.defense += gain;
        fighter.maxHp += 1.5;
        fighter.hp = fighter.maxHp;
        advanceOneWeek(
          actionSummary: '[SALAG] Pagsasanay ng Salag! +${gain.toStringAsFixed(1)} Depensa!',
        );
        break;

      case ActionType.study:
        fighter.stamina = (fighter.stamina - 10.0).clamp(0.0, fighter.maxStamina);
        final gradeBoost = (2.5 + rnd.nextDouble() * 2.5) * totalAcademicsMultiplier;
        fighter.academics = (fighter.academics + gradeBoost).clamp(65.0, 100.0);
        advanceOneWeek(
          actionSummary: '[ARAL] Nagbasa sa ilalim ng Mangga! +${gradeBoost.toStringAsFixed(1)} Grado (${fighter.academics.toStringAsFixed(1)})!',
        );
        break;

      case ActionType.rest:
        fighter.stamina = fighter.maxStamina;
        fighter.hp = fighter.maxHp;
        pesos += 50;
        advanceOneWeek(
          actionSummary: '[HINGA] Uminom ng Buko at nagpahinga! 100% Hangin & Tibay naibalik!',
        );
        break;

      case ActionType.spar:
        final gain = 0.8 + rnd.nextDouble() * 0.8;
        fighter.power += gain * totalPowerMultiplier;
        fighter.speed += gain * totalSpeedMultiplier;
        fighter.technique += gain * totalTechniqueMultiplier;
        fighter.defense += gain * totalDefenseMultiplier;
        advanceOneWeek(
          actionSummary: '[SPARRING] Bakbakan sa Ring! Lahat ng stats tumaas ng +${gain.toStringAsFixed(1)}!',
        );
        break;
    }

    return true;
  }

  // GYM FACILITY BUILDING & EXPANSION
  bool buildFacility(int slotIndex, FacilityType type) {
    if (slotIndex < 0 || slotIndex >= maxSlots) return false;
    if (pesos < type.baseCost) {
      recentLog = '[PERA] Kulang ang Pesos! Kailangan ng P${type.baseCost}.';
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

    recentLog = '[TAYO] Itinayo ang ${type.displayName} sa Slot ${slotIndex + 1}!';
    notifyListeners();
    saveGame();
    return true;
  }

  bool upgradeFacility(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= maxSlots) return false;
    final facility = slots[slotIndex];
    if (facility == null) return false;

    if (pesos < facility.upgradeCost) {
      recentLog = '[PERA] Kulang ang Pesos pambili ng upgrade!';
      notifyListeners();
      return false;
    }

    pesos -= facility.upgradeCost;
    facility.level += 1;
    recentLog = '[UPGRADE] ${facility.type.displayName} umabante sa Lvl ${facility.level}!';
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
    recentLog = '[BUWAG] Binuwag ang ${facility.type.displayName}. Nabawi ang P$refund.';
    notifyListeners();
    saveGame();
    return true;
  }

  bool expandGymSlots() {
    if (maxSlots >= 6) return false;
    const cost = 1800;
    if (pesos < cost) {
      recentLog = '[PERA] Kailangan ng P$cost para lumawak ang bakuran at itayo ang 2nd floor!';
      notifyListeners();
      return false;
    }

    pesos -= cost;
    maxSlots = (maxSlots + 2).clamp(2, 6);
    recentLog = '[PAGLAKI] Lumawak ang training camp! Mayroon ka nang $maxSlots physical slots!';
    notifyListeners();
    saveGame();
    return true;
  }

  // EQUIPMENT MANAGEMENT
  bool buyWeapon(WeaponItem weapon) {
    if (pesos < weapon.price) {
      recentLog = '[PERA] Kulang ang Pesos para sa ${weapon.name}!';
      notifyListeners();
      return false;
    }
    pesos -= weapon.price;
    fighter.equippedWeapon = weapon;
    recentLog = '[SANDATA] Isinuot ang ${weapon.name}!';
    notifyListeners();
    saveGame();
    return true;
  }

  bool buyGear(GearItem gear) {
    if (pesos < gear.price) {
      recentLog = '[PERA] Kulang ang Pesos para sa ${gear.name}!';
      notifyListeners();
      return false;
    }
    pesos -= gear.price;
    fighter.equippedGears.removeWhere((g) => g.id == gear.id);
    fighter.equippedGears.add(gear);
    recentLog = '[GEAR] Isinuot ang ${gear.name}!';
    notifyListeners();
    saveGame();
    return true;
  }

  void switchStyle(FighterStyle newStyle) {
    fighter.style = newStyle;
    recentLog = '[ISTILO] Pinalitan ang istilo: ${newStyle.displayName}!';
    notifyListeners();
    saveGame();
  }

  // TOURNAMENT COMPLETION & REWARDS
  void completeTournament(TournamentModel tournament, bool won) {
    if (won) {
      pesos += tournament.prizeMoney;
      prestige += tournament.prestigeReward;
      tournament.isCompleted = true;

      fighter.power += 1.0;
      fighter.speed += 1.0;
      fighter.technique += 1.5;
      fighter.defense += 1.0;

      recentLog = '[KAMPEON] Panalo sa ${tournament.title}! Nanalo ng P${tournament.prizeMoney} & +${tournament.prestigeReward} Prestige!';

      if (tournament.id == 'division_meet') {
        checkStoryTriggers('division_won');
      }
    } else {
      pesos += (tournament.prizeMoney * 0.15).round();
      recentLog = '[TALO] Natalo sa ${tournament.title}. Magsanay muli!';
    }

    advanceOneWeek();
  }

  // OPPONENT DOSSIER & HEAD-TO-HEAD MATCH RECORDING
  void recordOpponentMatch({
    required TournamentOpponent opponent,
    required bool won,
    required int maxDamage,
  }) {
    final key = opponent.name;
    final record = opponentRecords.putIfAbsent(
      key,
      () => OpponentRecord(
        id: key,
        name: opponent.name,
        title: opponent.title,
        gymName: opponent.gymName,
        style: opponent.style,
      ),
    );

    record.matchesFought += 1;
    if (won) {
      record.wins += 1;
      record.lastResult = 'PANALO';
    } else {
      record.losses += 1;
      record.lastResult = 'TALO';
    }
    if (maxDamage > record.highestDamageDealt) {
      record.highestDamageDealt = maxDamage;
    }
    record.lastEncounter = 'Yr $year, Mn $month Wk $week';
    notifyListeners();
    saveGame();
  }

  // ADVANCE TOURNAMENT BRACKET
  void handleBracketMatchResult({
    required TournamentModel tournament,
    required TournamentOpponent currentOpponent,
    required bool won,
    required int maxDamage,
  }) {
    recordOpponentMatch(
      opponent: currentOpponent,
      won: won,
      maxDamage: maxDamage,
    );

    final bracket = tournament.bracket;
    if (bracket == null) {
      completeTournament(tournament, won);
      return;
    }

    final activeMatch = bracket.activePlayerMatch;
    if (activeMatch == null) {
      completeTournament(tournament, won);
      return;
    }

    if (!won) {
      activeMatch.winnerName = activeMatch.fighter2Name;
      activeMatch.isCompleted = true;
      bracket.isFinished = true;
      completeTournament(tournament, false);
      return;
    }

    // Player Won!
    activeMatch.winnerName = fighter.name;
    activeMatch.isCompleted = true;

    if (activeMatch.matchId == 1) {
      // Simulate Semifinals B (Match 2)
      final match2 = bracket.matches.firstWhere((m) => m.matchId == 2);
      if (!match2.isCompleted) {
        final f1 = match2.fighter1Data;
        final f2 = match2.fighter2Data;
        final rnd = Random();
        final f1Power = (f1?.power ?? 20) + rnd.nextDouble() * 5;
        final f2Power = (f2?.power ?? 20) + rnd.nextDouble() * 5;
        final winner = f1Power >= f2Power ? f1 : f2;
        match2.winnerName = winner?.name ?? match2.fighter1Name;
        match2.isCompleted = true;
      }

      // Populate Championship Final (Match 3)
      final finals = bracket.matches.firstWhere((m) => m.matchId == 3);
      finals.fighter1Name = fighter.name;
      finals.fighter2Name = match2.winnerName!;
      finals.fighter2Data = match2.fighter1Name == match2.winnerName
          ? match2.fighter1Data
          : match2.fighter2Data;
      finals.isPlayerMatch = true;
      bracket.currentRoundIndex = 1;

      recentLog = '[ABANTE] Pasok sa Championship Finals ng ${tournament.title}! Makakatapat si ${finals.fighter2Name}!';
      notifyListeners();
      saveGame();
    } else if (activeMatch.matchId == 3) {
      // Won the Championship Final!
      bracket.isFinished = true;
      completeTournament(tournament, true);
    }
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
      'inventory': inventory.map((it) => it.toJson()).toList(),
      'activeBuffs': activeBuffs.map((b) => b.toJson()).toList(),
      'opponentRecords': opponentRecords.map((k, v) => MapEntry(k, v.toJson())),
      'bgmVolume': bgmVolume,
      'sfxVolume': sfxVolume,
    };
    await StorageService.saveGameToSlot(activeSlotIndex, data);
  }

  Future<bool> loadSavedGame({int slot = 1}) async {
    activeSlotIndex = slot;
    StorageService.setActiveSlotIndex(slot);
    final data = await StorageService.loadGameFromSlot(slot);
    if (data == null) return false;

    try {
      year = data['year'] as int? ?? 1;
      month = data['month'] as int? ?? 6;
      week = data['week'] as int? ?? 1;
      pesos = data['pesos'] as int? ?? 650;
      prestige = data['prestige'] as int? ?? 0;
      maxSlots = (data['maxSlots'] as int? ?? 2).clamp(2, 6);

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

      final rawInventory = data['inventory'] as List<dynamic>?;
      if (rawInventory != null) {
        inventory = rawInventory
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        inventory = InventoryItem.createDefaultCatalog();
      }

      final rawBuffs = data['activeBuffs'] as List<dynamic>?;
      if (rawBuffs != null) {
        activeBuffs = rawBuffs
            .map((e) => ActiveBuff.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        activeBuffs = [];
      }

      final rawRecords = data['opponentRecords'] as Map<String, dynamic>?;
      if (rawRecords != null) {
        opponentRecords = rawRecords.map(
          (k, v) => MapEntry(k, OpponentRecord.fromJson(v as Map<String, dynamic>)),
        );
      }

      bgmVolume = (data['bgmVolume'] as num?)?.toDouble() ?? 0.8;
      sfxVolume = (data['sfxVolume'] as num?)?.toDouble() ?? 1.0;

      recentLog = '[LOAD] Na-load ang Slot $slot!';
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
