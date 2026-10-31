// lib/domain/balance.dart
// PURE DART - NO FLAME IMPORTS.
// ALL tunable gameplay numbers, formulas, thresholds, and economic constants live here.

class Balance {
  // --- DISPLAY & RESOLUTION ---
  static const double virtualWidth = 240.0;
  static const double targetAspectRatio = 9.0 / 16.0;

  // --- CALENDAR & TIME ---
  static const int monthsPerYear = 12;
  static const int weeksPerMonth = 4;
  static const int weeksPerYear = monthsPerYear * weeksPerMonth; // 48
  static const int startYear = 1;
  static const int startMonth = 6; // June (start of school year)
  static const int startWeek = 1;
  static const double standardWeekSeconds = 15.0; // 1x speed

  // --- STARTING STATE ---
  static const int startingMoney = 1000;
  static const int startingFame = 0;
  static const int startingStudentCount = 3;
  static const int maxStudentsBase = 4;
  static const int maxStudentsPerFloor = 4;
  static const int maxStudentsHardCap = 24;

  // --- STAT CAPS PER CAMP RANK TIER ---
  static const Map<String, double> statCapsByTier = {
    'purok': 60.0,
    'barangay': 120.0,
    'bayan': 220.0,
    'probinsya': 350.0,
    'rehiyon': 520.0,
    'pambansa': 800.0,
  };

  // --- FAME THRESHOLDS FOR CAMP RANK ---
  static const Map<String, int> fameThresholds = {
    'purok': 0,
    'barangay': 150,
    'bayan': 600,
    'probinsya': 2500,
    'rehiyon': 9000,
    'pambansa': 30000,
  };

  // --- FLOOR EXPANSION COSTS ---
  static const Map<int, int> floorCosts = {
    2: 1800,
    3: 6000,
    4: 15000,
    5: 35000,
  };

  // --- ECONOMY ---
  static const int baseTuitionMin = 40;
  static const int baseTuitionMax = 80;
  static const int monthlyBaseUpkeep = 100;
  static const int monthlyUpkeepPerFloor = 80;
  static const int sariSariWeeklyPassiveIncome = 60;
  static const int bailoutLoanAmount = 2000;
  static const int bailoutRepaymentWeeks = 8;

  // --- TRAINING & FATIGUE ---
  static const double baseTrainingPrimaryGain = 1.5;
  static const double baseTrainingSecondaryGain = 0.3;
  static const double baseStudyGradeGain = 1.5;
  static const double baseSparStatGain = 1.0;

  static const double fatigueTrainCost = 12.0;
  static const double fatigueSparCost = 15.0;
  static const double fatigueStudyCost = 5.0;
  static const double fatigueRestRecovery = 30.0;
  static const double moraleRestRecovery = 5.0;

  static const double highFatigueThreshold = 70.0;
  static const double extremeFatigueThreshold = 80.0;
  static const double highFatigueGainPenalty = 0.70;
  static const double baseInjuryChanceNormal = 0.01;
  static const double baseInjuryChanceExhausted = 0.10;

  // Focus Tap Skill Bonuses
  static const double focusTapNormalBonus = 0.25; // +25%
  static const double focusTapPerfectBonus = 0.40; // +40%

  // --- COMBAT & MATCH ENGINE ---
  static const double combatTickSeconds = 0.5;
  static const int standardRounds = 3;
  static const int elementaryRounds = 2;
  static const double roundDurationSeconds = 60.0;

  static const double hpBaseOffset = 75.0;
  static const double hpStatMultiplier = 0.30;

  static const double actionThreshold = 100.0;
  static const double actionSpeedDivisor = 10.0;

  static const double minHitChance = 0.15;
  static const double maxHitChance = 0.90;

  static const double blockDamageReduction = 0.25; // takes 25% damage when blocked
  static const double criticalMultiplier = 1.50;
  static const double finisherDamageMultiplier = 2.0;

  // Style Weapon Multipliers
  static const double weaponSoloBastonMult = 1.0;
  static const double weaponDobleBastonMult = 0.8; // strikes twice
  static const double weaponEspadaYDagaMult = 0.9;
  static const double espadaExtraBlockChance = 0.15;

  // Coach Gigil Meter
  static const double gigilPassivePerSecond = 1.0;
  static const double gigilPerHitTaken = 5.0;
  static const double costBira = 35.0;
  static const double costSalag = 30.0;
  static const double costDiskarte = 45.0;

  static const double biraPowerBuff = 0.30;
  static const double salagDefenseBuff = 0.50;
  static const double buffDurationSeconds = 8.0;
  static const double diskarteStunDurationSeconds = 3.0;

  // Academic Eligibility
  static const double varsityEligibilityGrade = 75.0;
  static const double intramsEligibilityGrade = 80.0;

  // --- TOURNAMENT STAT TARGETS PER TIER (SECTION 10 SPEC) ---
  static const Map<int, double> opponentStatTargetByTier = {
    1: 85.0,    // 70–100
    2: 130.0,
    3: 240.0,
    4: 420.0,
    5: 700.0,
    6: 1100.0,
  };
  static const double tournamentFinalsOpponentBonus = 0.10; // +10% in championship final
}
