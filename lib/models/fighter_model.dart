enum FighterStyle {
  soloBaston,
  dobleBaston,
  espadaYDaga,
}

extension FighterStyleExtension on FighterStyle {
  String get displayName {
    switch (this) {
      case FighterStyle.soloBaston:
        return 'Solo Baston';
      case FighterStyle.dobleBaston:
        return 'Doble Baston (Sinawali)';
      case FighterStyle.espadaYDaga:
        return 'Espada y Daga';
    }
  }

  String get signatureMove {
    switch (this) {
      case FighterStyle.soloBaston:
        return 'Abaniko Tres Puntas';
      case FighterStyle.dobleBaston:
        return 'Heaven Six Flurry';
      case FighterStyle.espadaYDaga:
        return 'Sabong Disarm';
    }
  }

  String get description {
    switch (this) {
      case FighterStyle.soloBaston:
        return 'Balanced reach, crisp parrying, and lethal precision strikes.';
      case FighterStyle.dobleBaston:
        return 'Relentless twin-stick weaving patterns and high combo frequency.';
      case FighterStyle.espadaYDaga:
        return 'Close-quarter blade & stick fencing with lethal disarm counters.';
    }
  }
}

class WeaponItem {
  final String id;
  final String name;
  final int powerBonus;
  final int speedBonus;
  final int techniqueBonus;
  final int price;
  final bool isPadded;
  final String description;

  const WeaponItem({
    required this.id,
    required this.name,
    this.powerBonus = 0,
    this.speedBonus = 0,
    this.techniqueBonus = 0,
    this.price = 0,
    this.isPadded = false,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'powerBonus': powerBonus,
        'speedBonus': speedBonus,
        'techniqueBonus': techniqueBonus,
        'price': price,
        'isPadded': isPadded,
        'description': description,
      };

  factory WeaponItem.fromJson(Map<String, dynamic> json) => WeaponItem(
        id: json['id'] as String,
        name: json['name'] as String,
        powerBonus: json['powerBonus'] as int? ?? 0,
        speedBonus: json['speedBonus'] as int? ?? 0,
        techniqueBonus: json['techniqueBonus'] as int? ?? 0,
        price: json['price'] as int? ?? 0,
        isPadded: json['isPadded'] as bool? ?? false,
        description: json['description'] as String? ?? '',
      );

  static const WeaponItem paddedStick = WeaponItem(
    id: 'padded_stick',
    name: 'Standard Padded Stick',
    powerBonus: 4,
    speedBonus: 2,
    techniqueBonus: 3,
    price: 350,
    isPadded: true,
    description: 'DepEd/Palaro sanctioned safe competition batuta.',
  );

  static const WeaponItem yantok = WeaponItem(
    id: 'yantok',
    name: 'Yantok / Rattan Baston',
    powerBonus: 8,
    speedBonus: 6,
    techniqueBonus: 4,
    price: 500,
    isPadded: false,
    description: 'Classic fire-hardened bamboo/rattan baston. Light and snappy.',
  );

  static const WeaponItem bahi = WeaponItem(
    id: 'bahi',
    name: 'Bahi Wild Palm Baston',
    powerBonus: 16,
    speedBonus: 2,
    techniqueBonus: 6,
    price: 1500,
    isPadded: false,
    description: 'Heavy, dense wood from wild palm tree. Bone-crushing impact.',
  );

  static const WeaponItem kamagong = WeaponItem(
    id: 'kamagong',
    name: 'Ironwood Kamagong',
    powerBonus: 28,
    speedBonus: -2,
    techniqueBonus: 10,
    price: 3800,
    isPadded: false,
    description: 'Philippine ironwood. Heavy as stone, unstoppable strikes.',
  );

  static const List<WeaponItem> defaultShopWeapons = [
    paddedStick,
    yantok,
    bahi,
    kamagong,
  ];
}

class GearItem {
  final String id;
  final String name;
  final int defenseBonus;
  final int staminaBonus;
  final int speedBonus;
  final int price;
  final String description;

  const GearItem({
    required this.id,
    required this.name,
    this.defenseBonus = 0,
    this.staminaBonus = 0,
    this.speedBonus = 0,
    this.price = 0,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defenseBonus': defenseBonus,
        'staminaBonus': staminaBonus,
        'speedBonus': speedBonus,
        'price': price,
        'description': description,
      };

  factory GearItem.fromJson(Map<String, dynamic> json) => GearItem(
        id: json['id'] as String,
        name: json['name'] as String,
        defenseBonus: json['defenseBonus'] as int? ?? 0,
        staminaBonus: json['staminaBonus'] as int? ?? 0,
        speedBonus: json['speedBonus'] as int? ?? 0,
        price: json['price'] as int? ?? 0,
        description: json['description'] as String? ?? '',
      );

  static const GearItem rubberShoes = GearItem(
    id: 'rubber_shoes',
    name: 'Barangay Rubber Shoes',
    defenseBonus: 2,
    staminaBonus: 10,
    speedBonus: 5,
    price: 450,
    description: 'Reliable grip on dusty concrete and mud rings.',
  );

  static const GearItem headgear = GearItem(
    id: 'headgear',
    name: 'WEKAF Grid Headgear',
    defenseBonus: 12,
    staminaBonus: 0,
    speedBonus: -1,
    price: 1200,
    description: 'Full face metal grid protecting from direct head slashes.',
  );

  static const GearItem bodyArmor = GearItem(
    id: 'body_armor',
    name: 'Padded Red/Blue Body Vest',
    defenseBonus: 20,
    staminaBonus: -5,
    speedBonus: -2,
    price: 2200,
    description: 'Standard protective chestplate for full-contact laban.',
  );

  static const List<GearItem> defaultShopGears = [
    rubberShoes,
    headgear,
    bodyArmor,
  ];
}

class FighterModel {
  String name;
  String nickname;
  String gymName;
  String coachName;
  String coachTitle;
  String coachPerk;
  String gender;
  int skinIndex;
  int headbandColorIndex;
  int hairIndex;
  int gradeLevel; // 5 = Grade 5 (Elementary, Age 11) up to 16 = College 4th Year
  int age;
  double maxHp;
  double hp;
  double maxStamina;
  double stamina;
  double power; // Lakas
  double speed; // Bilis
  double technique; // Diskarte
  double defense; // Salag
  double academics; // Grado (65.0 to 100.0)
  FighterStyle style;
  Map<FighterStyle, int> styleMasteries; // 1 to 10
  WeaponItem equippedWeapon;
  List<GearItem> equippedGears;
  bool isPlayer;

  FighterModel({
    required this.name,
    this.nickname = 'Bastonero',
    this.gymName = 'Bakuran Arnis Camp',
    this.coachName = 'Coach Kanor',
    this.coachTitle = 'Beterano ng Purok',
    this.coachPerk = 'Hangin Recovery +20%',
    this.gender = 'Lalaki',
    this.skinIndex = 0,
    this.headbandColorIndex = 0,
    this.hairIndex = 0,
    this.gradeLevel = 5,
    this.age = 11,
    this.maxHp = 100.0,
    double? hp,
    this.maxStamina = 100.0,
    double? stamina,
    this.power = 15.0,
    this.speed = 14.0,
    this.technique = 12.0,
    this.defense = 10.0,
    this.academics = 85.0,
    this.style = FighterStyle.soloBaston,
    Map<FighterStyle, int>? styleMasteries,
    WeaponItem? equippedWeapon,
    List<GearItem>? equippedGears,
    this.isPlayer = true,
  })  : hp = hp ?? maxHp,
        stamina = stamina ?? maxStamina,
        styleMasteries = styleMasteries ??
            {
              FighterStyle.soloBaston: 1,
              FighterStyle.dobleBaston: 1,
              FighterStyle.espadaYDaga: 1,
            },
        equippedWeapon = equippedWeapon ?? WeaponItem.yantok,
        equippedGears = equippedGears ?? [];

  // Academic standing checks
  bool get isPassingSchool => academics >= 75.0;
  bool get isEligibleForSchoolVarsity => academics >= 80.0;

  String get academicHonorStatus {
    if (academics >= 95.0) return 'With Highest Honors';
    if (academics >= 90.0) return 'With High Honors';
    if (academics >= 85.0) return 'Honor Student';
    if (academics >= 80.0) return 'Varsity Eligible';
    if (academics >= 75.0) return 'Passing (Varsity Suspended)';
    return 'Remedial Warning (Failing)';
  }

  String get gradeLevelDescription {
    if (gradeLevel <= 6) {
      return 'Grade $gradeLevel (Elementary)';
    } else if (gradeLevel <= 10) {
      return 'Grade $gradeLevel (Junior High)';
    } else if (gradeLevel <= 12) {
      return 'Grade $gradeLevel (Senior High)';
    } else {
      final collegeYear = gradeLevel - 12;
      return 'College Year $collegeYear (Collegiate League)';
    }
  }

  // Effective combat stats with weapon & gear modifiers
  double get effectivePower {
    double total = power + equippedWeapon.powerBonus;
    return total < 5.0 ? 5.0 : total;
  }

  double get effectiveSpeed {
    double total = speed + equippedWeapon.speedBonus;
    for (final gear in equippedGears) {
      total += gear.speedBonus;
    }
    return total < 5.0 ? 5.0 : total;
  }

  double get effectiveTechnique {
    double total = technique + equippedWeapon.techniqueBonus;
    final masteryBonus = (styleMasteries[style] ?? 1) * 1.5;
    return total + masteryBonus;
  }

  double get effectiveDefense {
    double total = defense;
    for (final gear in equippedGears) {
      total += gear.defenseBonus;
    }
    return total < 5.0 ? 5.0 : total;
  }

  // Clones
  FighterModel copyWith({
    String? name,
    String? nickname,
    String? gymName,
    String? coachName,
    String? coachTitle,
    String? coachPerk,
    String? gender,
    int? skinIndex,
    int? headbandColorIndex,
    int? hairIndex,
    int? gradeLevel,
    int? age,
    double? maxHp,
    double? hp,
    double? maxStamina,
    double? stamina,
    double? power,
    double? speed,
    double? technique,
    double? defense,
    double? academics,
    FighterStyle? style,
    Map<FighterStyle, int>? styleMasteries,
    WeaponItem? equippedWeapon,
    List<GearItem>? equippedGears,
    bool? isPlayer,
  }) {
    return FighterModel(
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      gymName: gymName ?? this.gymName,
      coachName: coachName ?? this.coachName,
      coachTitle: coachTitle ?? this.coachTitle,
      coachPerk: coachPerk ?? this.coachPerk,
      gender: gender ?? this.gender,
      skinIndex: skinIndex ?? this.skinIndex,
      headbandColorIndex: headbandColorIndex ?? this.headbandColorIndex,
      hairIndex: hairIndex ?? this.hairIndex,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      age: age ?? this.age,
      maxHp: maxHp ?? this.maxHp,
      hp: hp ?? this.hp,
      maxStamina: maxStamina ?? this.maxStamina,
      stamina: stamina ?? this.stamina,
      power: power ?? this.power,
      speed: speed ?? this.speed,
      technique: technique ?? this.technique,
      defense: defense ?? this.defense,
      academics: academics ?? this.academics,
      style: style ?? this.style,
      styleMasteries: styleMasteries != null
          ? Map.from(styleMasteries)
          : Map.from(this.styleMasteries),
      equippedWeapon: equippedWeapon ?? this.equippedWeapon,
      equippedGears: equippedGears != null
          ? List.from(equippedGears)
          : List.from(this.equippedGears),
      isPlayer: isPlayer ?? this.isPlayer,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'nickname': nickname,
        'gymName': gymName,
        'coachName': coachName,
        'coachTitle': coachTitle,
        'coachPerk': coachPerk,
        'gender': gender,
        'skinIndex': skinIndex,
        'headbandColorIndex': headbandColorIndex,
        'hairIndex': hairIndex,
        'gradeLevel': gradeLevel,
        'age': age,
        'maxHp': maxHp,
        'hp': hp,
        'maxStamina': maxStamina,
        'stamina': stamina,
        'power': power,
        'speed': speed,
        'technique': technique,
        'defense': defense,
        'academics': academics,
        'style': style.index,
        'styleMasteries': styleMasteries.map((k, v) => MapEntry(k.index.toString(), v)),
        'equippedWeapon': equippedWeapon.toJson(),
        'equippedGears': equippedGears.map((g) => g.toJson()).toList(),
        'isPlayer': isPlayer,
      };

  factory FighterModel.fromJson(Map<String, dynamic> json) {
    final styleMap = (json['styleMasteries'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(FighterStyle.values[int.parse(k)], v as int),
        ) ??
        {
          FighterStyle.soloBaston: 1,
          FighterStyle.dobleBaston: 1,
          FighterStyle.espadaYDaga: 1,
        };

    final weaponJson = json['equippedWeapon'] as Map<String, dynamic>?;
    final gearsJson = json['equippedGears'] as List<dynamic>?;

    return FighterModel(
      name: json['name'] as String? ?? 'Arnisador',
      nickname: json['nickname'] as String? ?? 'Bastonero',
      gymName: json['gymName'] as String? ?? 'Bakuran Arnis Camp',
      coachName: json['coachName'] as String? ?? 'Coach Kanor',
      coachTitle: json['coachTitle'] as String? ?? 'Beterano ng Purok',
      coachPerk: json['coachPerk'] as String? ?? 'Hangin Recovery +20%',
      gender: json['gender'] as String? ?? 'Lalaki',
      skinIndex: json['skinIndex'] as int? ?? 0,
      headbandColorIndex: json['headbandColorIndex'] as int? ?? 0,
      hairIndex: json['hairIndex'] as int? ?? 0,
      gradeLevel: json['gradeLevel'] as int? ?? 5,
      age: json['age'] as int? ?? 11,
      maxHp: (json['maxHp'] as num?)?.toDouble() ?? 100.0,
      hp: (json['hp'] as num?)?.toDouble() ?? 100.0,
      maxStamina: (json['maxStamina'] as num?)?.toDouble() ?? 100.0,
      stamina: (json['stamina'] as num?)?.toDouble() ?? 100.0,
      power: (json['power'] as num?)?.toDouble() ?? 15.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 14.0,
      technique: (json['technique'] as num?)?.toDouble() ?? 12.0,
      defense: (json['defense'] as num?)?.toDouble() ?? 10.0,
      academics: (json['academics'] as num?)?.toDouble() ?? 85.0,
      style: FighterStyle.values[json['style'] as int? ?? 0],
      styleMasteries: styleMap,
      equippedWeapon: weaponJson != null
          ? WeaponItem.fromJson(weaponJson)
          : WeaponItem.yantok,
      equippedGears: gearsJson != null
          ? gearsJson.map((e) => GearItem.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      isPlayer: json['isPlayer'] as bool? ?? true,
    );
  }

  // Pre-configured Rivals and Opponents
  static FighterModel createBertoRival({int level = 1}) {
    return FighterModel(
      name: 'Berto Batuta (Purok Bully)',
      gradeLevel: 5,
      age: 12,
      maxHp: 110.0 + (level * 15),
      maxStamina: 90.0 + (level * 10),
      power: 18.0 + (level * 3),
      speed: 13.0 + (level * 2),
      technique: 11.0 + (level * 2),
      defense: 12.0 + (level * 2.5),
      academics: 70.0,
      style: FighterStyle.soloBaston,
      equippedWeapon: WeaponItem.bahi,
      isPlayer: false,
    );
  }

  static FighterModel createDivisionOpponent({required String name, double powerOffset = 0}) {
    return FighterModel(
      name: name,
      gradeLevel: 6,
      age: 12,
      maxHp: 130.0,
      maxStamina: 100.0,
      power: 22.0 + powerOffset,
      speed: 18.0 + powerOffset,
      technique: 17.0 + powerOffset,
      defense: 15.0 + powerOffset,
      academics: 84.0,
      style: FighterStyle.dobleBaston,
      equippedWeapon: WeaponItem.paddedStick,
      isPlayer: false,
    );
  }

  static FighterModel createLorenzoRival() {
    return FighterModel(
      name: 'Lorenzo Dela Cruz (Private Academy Ace)',
      gradeLevel: 6,
      age: 12,
      maxHp: 160.0,
      maxStamina: 130.0,
      power: 32.0,
      speed: 25.0,
      technique: 28.0,
      defense: 24.0,
      academics: 94.0,
      style: FighterStyle.espadaYDaga,
      equippedWeapon: WeaponItem.kamagong,
      equippedGears: [GearItem.headgear, GearItem.bodyArmor],
      isPlayer: false,
    );
  }
}
