enum FacilityType {
  gulongTarget,
  footworkTires,
  sparringRing,
  studyDesk,
  bukoStand,
}

extension FacilityTypeExtension on FacilityType {
  String get displayName {
    switch (this) {
      case FacilityType.gulongTarget:
        return 'Gulong Target (Tire Dummy)';
      case FacilityType.footworkTires:
        return 'Footwork Agility Tires';
      case FacilityType.sparringRing:
        return 'Wooden Sipa / Sparring Ring';
      case FacilityType.studyDesk:
        return 'Desk Under Mango Tree';
      case FacilityType.bukoStand:
        return 'Buko Juice & Sari-Sari Stand';
    }
  }

  String get shortName {
    switch (this) {
      case FacilityType.gulongTarget:
        return 'Gulong Dummy';
      case FacilityType.footworkTires:
        return 'Footwork Tires';
      case FacilityType.sparringRing:
        return 'Sparring Ring';
      case FacilityType.studyDesk:
        return 'Mango Tree Desk';
      case FacilityType.bukoStand:
        return 'Buko Stand';
    }
  }

  String get primaryStatEffect {
    switch (this) {
      case FacilityType.gulongTarget:
        return '+Power (Lakas)';
      case FacilityType.footworkTires:
        return '+Speed (Bilis)';
      case FacilityType.sparringRing:
        return '+Technique & Defense';
      case FacilityType.studyDesk:
        return '+Academics (Grado)';
      case FacilityType.bukoStand:
        return '+Stamina & Peso Income';
    }
  }

  int get baseCost {
    switch (this) {
      case FacilityType.gulongTarget:
        return 300;
      case FacilityType.footworkTires:
        return 450;
      case FacilityType.sparringRing:
        return 750;
      case FacilityType.studyDesk:
        return 250;
      case FacilityType.bukoStand:
        return 600;
    }
  }

  int get baseUpgradeCost {
    switch (this) {
      case FacilityType.gulongTarget:
        return 200;
      case FacilityType.footworkTires:
        return 300;
      case FacilityType.sparringRing:
        return 500;
      case FacilityType.studyDesk:
        return 180;
      case FacilityType.bukoStand:
        return 400;
    }
  }

  String get description {
    switch (this) {
      case FacilityType.gulongTarget:
        return 'Old jeepney tires strapped to coconut tree. Improves baston impact & power.';
      case FacilityType.footworkTires:
        return 'Rubber tires laid in zigzag triangle. Sharpens forward-retreat footwork.';
      case FacilityType.sparringRing:
        return 'Bamboo marked ring for live stick sparring, counter checks, and parrying.';
      case FacilityType.studyDesk:
        return 'Shaded wooden study desk. Keep school grades high to maintain varsity status.';
      case FacilityType.bukoStand:
        return 'Fresh coconut water and snacks. Restores fighter stamina and brings weekly peso sales.';
    }
  }
}

class FacilityModel {
  final String id;
  final FacilityType type;
  int level;
  int slotIndex;

  FacilityModel({
    required this.id,
    required this.type,
    this.level = 1,
    required this.slotIndex,
  });

  int get upgradeCost => type.baseUpgradeCost * level;

  double get powerMultiplier =>
      type == FacilityType.gulongTarget ? 1.0 + (level * 0.15) : 1.0;
  double get speedMultiplier =>
      type == FacilityType.footworkTires ? 1.0 + (level * 0.15) : 1.0;
  double get techniqueMultiplier =>
      type == FacilityType.sparringRing ? 1.0 + (level * 0.12) : 1.0;
  double get defenseMultiplier =>
      type == FacilityType.sparringRing ? 1.0 + (level * 0.10) : 1.0;
  double get academicsMultiplier =>
      type == FacilityType.studyDesk ? 1.0 + (level * 0.20) : 1.0;

  int get weeklyPassivePesos =>
      type == FacilityType.bukoStand ? 60 + (level * 40) : 0;
  double get weeklyStaminaRecoveryBonus =>
      type == FacilityType.bukoStand ? 15.0 + (level * 5.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'level': level,
        'slotIndex': slotIndex,
      };

  factory FacilityModel.fromJson(Map<String, dynamic> json) => FacilityModel(
        id: json['id'] as String,
        type: FacilityType.values[json['type'] as int],
        level: json['level'] as int? ?? 1,
        slotIndex: json['slotIndex'] as int,
      );
}

class SynergyCombo {
  final String title;
  final String description;
  final double powerXpBonus;
  final double speedXpBonus;
  final double techniqueXpBonus;
  final double defenseXpBonus;
  final double academicBonus;
  final double staminaCostReduction;
  final int bonusPassivePesos;

  const SynergyCombo({
    required this.title,
    required this.description,
    this.powerXpBonus = 0.0,
    this.speedXpBonus = 0.0,
    this.techniqueXpBonus = 0.0,
    this.defenseXpBonus = 0.0,
    this.academicBonus = 0.0,
    this.staminaCostReduction = 0.0,
    this.bonusPassivePesos = 0,
  });

  // Calculate active synergies based on facility placements
  static List<SynergyCombo> evaluateSynergies(List<FacilityModel?> slots) {
    final activeCombos = <SynergyCombo>[];
    if (slots.isEmpty) return activeCombos;

    final typesPresent = slots.where((f) => f != null).map((f) => f!.type).toSet();

    // Check adjacent pairs (0-1, 1-2, 2-3, 4-5, 5-6, 6-7, or vertical 0-4, etc.)
    bool hasAdjacent(FacilityType a, FacilityType b) {
      for (int i = 0; i < slots.length; i++) {
        final current = slots[i];
        if (current == null) continue;
        
        // Horizontal neighbor (e.g. 0-1, 1-2, 2-3 in row of 4)
        if (i % 4 < 3 && i + 1 < slots.length) {
          final neighbor = slots[i + 1];
          if (neighbor != null) {
            if ((current.type == a && neighbor.type == b) ||
                (current.type == b && neighbor.type == a)) {
              return true;
            }
          }
        }
        // Vertical neighbor (e.g. 0-4, 1-5, 2-6, 3-7 in 2x4 grid)
        if (i + 4 < slots.length) {
          final neighbor = slots[i + 4];
          if (neighbor != null) {
            if ((current.type == a && neighbor.type == b) ||
                (current.type == b && neighbor.type == a)) {
              return true;
            }
          }
        }
      }
      return false;
    }

    // 1. Gulong Target + Buko Stand = Presko Training Combo
    if (hasAdjacent(FacilityType.gulongTarget, FacilityType.bukoStand)) {
      activeCombos.add(const SynergyCombo(
        title: 'Presko Training Combo',
        description: 'Target striking with fresh coconut refreshment. +25% Power XP & -10% Stamina Cost!',
        powerXpBonus: 0.25,
        staminaCostReduction: 0.10,
      ));
    }

    // 2. Footwork Tires + Gulong Target = Bakbakan Agility Combo
    if (hasAdjacent(FacilityType.footworkTires, FacilityType.gulongTarget)) {
      activeCombos.add(const SynergyCombo(
        title: 'Bakbakan Speed Combo',
        description: 'Fluid footwork into heavy power strikes! +20% Speed XP & +15% Power XP.',
        speedXpBonus: 0.20,
        powerXpBonus: 0.15,
      ));
    }

    // 3. Study Desk + Sparring Ring = Student-Athlete Synergy
    if (hasAdjacent(FacilityType.studyDesk, FacilityType.sparringRing)) {
      activeCombos.add(const SynergyCombo(
        title: 'Student-Athlete Synergy',
        description: 'Disciplined mind and body! +25% Study XP & +15% Technique XP.',
        academicBonus: 0.25,
        techniqueXpBonus: 0.15,
      ));
    }

    // 4. Buko Stand + Footwork Tires = Hydration Rush Combo
    if (hasAdjacent(FacilityType.bukoStand, FacilityType.footworkTires)) {
      activeCombos.add(const SynergyCombo(
        title: 'Hydration Rush Combo',
        description: 'Fast cooldowns and happy patrons! +₱100/week passive income & -15% Stamina Drain.',
        bonusPassivePesos: 100,
        staminaCostReduction: 0.15,
      ));
    }

    // 5. Grand Camp (All 5 types built)
    if (typesPresent.length == 5) {
      activeCombos.add(const SynergyCombo(
        title: 'Grand Bastonero Encampment',
        description: 'The ultimate training sanctuary! +20% XP to all fighter attributes.',
        powerXpBonus: 0.20,
        speedXpBonus: 0.20,
        techniqueXpBonus: 0.20,
        defenseXpBonus: 0.20,
        academicBonus: 0.20,
      ));
    }

    return activeCombos;
  }
}
