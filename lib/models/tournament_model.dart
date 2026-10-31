import 'fighter_model.dart';

enum TournamentTrack {
  schoolTrack,
  streetTrack,
}

enum TournamentEventType {
  fullContactLaban,
  anyo,
}

extension TournamentTrackExtension on TournamentTrack {
  String get displayName {
    switch (this) {
      case TournamentTrack.schoolTrack:
        return 'School Varsity Track';
      case TournamentTrack.streetTrack:
        return 'Street & Community Track';
    }
  }
}

extension TournamentEventTypeExtension on TournamentEventType {
  String get displayName {
    switch (this) {
      case TournamentEventType.fullContactLaban:
        return 'Full-Contact Laban';
      case TournamentEventType.anyo:
        return 'Anyo (Forms & Rhythm)';
    }
  }
}

class TournamentOpponent {
  final String name;
  final String title;
  final String gymName;
  final String officialRecord;
  final double hp;
  final double power;
  final double speed;
  final double technique;
  final double defense;
  final FighterStyle style;
  final WeaponItem weapon;
  final String dialogue;

  const TournamentOpponent({
    required this.name,
    required this.title,
    this.gymName = 'Purok Baston Club',
    this.officialRecord = '5-1-0',
    required this.hp,
    required this.power,
    required this.speed,
    required this.technique,
    required this.defense,
    required this.style,
    required this.weapon,
    this.dialogue = 'Handa na ba ang baston mo?',
  });

  FighterModel toFighterModel() {
    return FighterModel(
      name: name,
      maxHp: hp,
      hp: hp,
      power: power,
      speed: speed,
      technique: technique,
      defense: defense,
      style: style,
      equippedWeapon: weapon,
      isPlayer: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'gymName': gymName,
        'officialRecord': officialRecord,
        'hp': hp,
        'power': power,
        'speed': speed,
        'technique': technique,
        'defense': defense,
        'style': style.index,
        'weapon': weapon.toJson(),
        'dialogue': dialogue,
      };

  factory TournamentOpponent.fromJson(Map<String, dynamic> json) =>
      TournamentOpponent(
        name: json['name'] as String,
        title: json['title'] as String,
        gymName: json['gymName'] as String? ?? 'Purok Baston Club',
        officialRecord: json['officialRecord'] as String? ?? '5-1-0',
        hp: (json['hp'] as num).toDouble(),
        power: (json['power'] as num).toDouble(),
        speed: (json['speed'] as num).toDouble(),
        technique: (json['technique'] as num).toDouble(),
        defense: (json['defense'] as num).toDouble(),
        style: FighterStyle.values[json['style'] as int],
        weapon: WeaponItem.fromJson(json['weapon'] as Map<String, dynamic>),
        dialogue: json['dialogue'] as String? ?? '',
      );
}

class BracketMatch {
  final int matchId;
  final String stageName; // 'Semi-Finals A', 'Semi-Finals B', 'Championship Final'
  String fighter1Name;
  String fighter2Name;
  TournamentOpponent? fighter1Data;
  TournamentOpponent? fighter2Data;
  String? winnerName;
  bool isPlayerMatch;
  bool isCompleted;

  BracketMatch({
    required this.matchId,
    required this.stageName,
    required this.fighter1Name,
    required this.fighter2Name,
    this.fighter1Data,
    this.fighter2Data,
    this.winnerName,
    this.isPlayerMatch = false,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'stageName': stageName,
        'fighter1Name': fighter1Name,
        'fighter2Name': fighter2Name,
        'fighter1Data': fighter1Data?.toJson(),
        'fighter2Data': fighter2Data?.toJson(),
        'winnerName': winnerName,
        'isPlayerMatch': isPlayerMatch,
        'isCompleted': isCompleted,
      };

  factory BracketMatch.fromJson(Map<String, dynamic> json) => BracketMatch(
        matchId: json['matchId'] as int,
        stageName: json['stageName'] as String,
        fighter1Name: json['fighter1Name'] as String,
        fighter2Name: json['fighter2Name'] as String,
        fighter1Data: json['fighter1Data'] != null
            ? TournamentOpponent.fromJson(json['fighter1Data'] as Map<String, dynamic>)
            : null,
        fighter2Data: json['fighter2Data'] != null
            ? TournamentOpponent.fromJson(json['fighter2Data'] as Map<String, dynamic>)
            : null,
        winnerName: json['winnerName'] as String?,
        isPlayerMatch: json['isPlayerMatch'] as bool? ?? false,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class TournamentBracket {
  final List<BracketMatch> matches;
  int currentRoundIndex; // 0 = Semis, 1 = Finals
  bool isFinished;

  TournamentBracket({
    required this.matches,
    this.currentRoundIndex = 0,
    this.isFinished = false,
  });

  BracketMatch? get activePlayerMatch {
    for (final m in matches) {
      if (m.isPlayerMatch && !m.isCompleted) {
        return m;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'matches': matches.map((m) => m.toJson()).toList(),
        'currentRoundIndex': currentRoundIndex,
        'isFinished': isFinished,
      };

  factory TournamentBracket.fromJson(Map<String, dynamic> json) => TournamentBracket(
        matches: (json['matches'] as List<dynamic>?)
                ?.map((e) => BracketMatch.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        currentRoundIndex: json['currentRoundIndex'] as int? ?? 0,
        isFinished: json['isFinished'] as bool? ?? false,
      );
}

class TournamentModel {
  final String id;
  final String title;
  final TournamentTrack track;
  final TournamentEventType eventType;
  final int scheduledMonth; // 1 - 12
  final int scheduledWeek; // 1 - 4
  final int tier;
  final int travelCost;
  final int scholarshipPoints;
  final double minGradeRequired; // 80.0 for school track
  final int minGradeLevel; // 5 = Grade 5, etc.
  final int entryFee;
  final int prizeMoney;
  final int prestigeReward;
  final String description;
  final List<TournamentOpponent> rounds;
  bool isCompleted;
  TournamentBracket? bracket;

  TournamentModel({
    required this.id,
    required this.title,
    required this.track,
    required this.eventType,
    required this.scheduledMonth,
    this.scheduledWeek = 2,
    this.tier = 1,
    this.travelCost = 0,
    this.scholarshipPoints = 0,
    this.minGradeRequired = 0.0,
    this.minGradeLevel = 5,
    this.entryFee = 0,
    this.prizeMoney = 500,
    this.prestigeReward = 10,
    required this.description,
    required this.rounds,
    this.isCompleted = false,
    this.bracket,
  }) {
    bracket ??= createDefaultBracket();
  }

  TournamentBracket createDefaultBracket() {
    // 4-Contender Single-Elimination Bracket:
    // Semifinal A (Player vs Contender 1)
    // Semifinal B (Contender 2 vs Contender 3)
    // Championship Final (Winner Semifinal A vs Winner Semifinal B)
    final opp1 = rounds.isNotEmpty ? rounds[0] : _fallbackOpponent(1);
    final opp2 = rounds.length > 1 ? rounds[1] : _fallbackOpponent(2);
    final opp3 = rounds.length > 2 ? rounds[2] : _fallbackOpponent(3);

    return TournamentBracket(
      matches: [
        BracketMatch(
          matchId: 1,
          stageName: 'Semi-Finals A',
          fighter1Name: 'Bayani "Bastonero"',
          fighter2Name: opp1.name,
          fighter2Data: opp1,
          isPlayerMatch: true,
        ),
        BracketMatch(
          matchId: 2,
          stageName: 'Semi-Finals B',
          fighter1Name: opp2.name,
          fighter2Name: opp3.name,
          fighter1Data: opp2,
          fighter2Data: opp3,
          isPlayerMatch: false,
        ),
        BracketMatch(
          matchId: 3,
          stageName: 'Championship Final',
          fighter1Name: 'Winner Semis A',
          fighter2Name: 'Winner Semis B',
          isPlayerMatch: true,
        ),
      ],
    );
  }

  TournamentOpponent _fallbackOpponent(int idx) {
    return TournamentOpponent(
      name: 'Purok Fighter #$idx',
      title: 'Wildcard Challenger',
      gymName: 'Barangay Gym',
      officialRecord: '3-2-0',
      hp: 110.0 + (idx * 15),
      power: 16.0 + (idx * 2),
      speed: 15.0 + (idx * 2),
      technique: 14.0 + (idx * 2),
      defense: 12.0 + (idx * 2),
      style: FighterStyle.values[idx % 3],
      weapon: WeaponItem.yantok,
    );
  }

  bool isEligible(FighterModel fighter, int currentMonth) {
    if (track == TournamentTrack.schoolTrack) {
      if (!fighter.isEligibleForSchoolVarsity) return false;
      if (fighter.gradeLevel < minGradeLevel) return false;
      if (currentMonth != scheduledMonth) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'track': track.index,
        'eventType': eventType.index,
        'scheduledMonth': scheduledMonth,
        'scheduledWeek': scheduledWeek,
        'tier': tier,
        'travelCost': travelCost,
        'scholarshipPoints': scholarshipPoints,
        'minGradeRequired': minGradeRequired,
        'minGradeLevel': minGradeLevel,
        'entryFee': entryFee,
        'prizeMoney': prizeMoney,
        'prestigeReward': prestigeReward,
        'description': description,
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'isCompleted': isCompleted,
        'bracket': bracket?.toJson(),
      };

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    final roundsList = (json['rounds'] as List<dynamic>?)
            ?.map((e) => TournamentOpponent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final bracketJson = json['bracket'] as Map<String, dynamic>?;

    final tourney = TournamentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      track: TournamentTrack.values[json['track'] as int],
      eventType: TournamentEventType.values[json['eventType'] as int],
      scheduledMonth: json['scheduledMonth'] as int,
      scheduledWeek: json['scheduledWeek'] as int? ?? 2,
      tier: json['tier'] as int? ?? 1,
      travelCost: json['travelCost'] as int? ?? 0,
      scholarshipPoints: json['scholarshipPoints'] as int? ?? 0,
      minGradeRequired: (json['minGradeRequired'] as num?)?.toDouble() ?? 0.0,
      minGradeLevel: json['minGradeLevel'] as int? ?? 5,
      entryFee: json['entryFee'] as int? ?? 0,
      prizeMoney: json['prizeMoney'] as int? ?? 500,
      prestigeReward: json['prestigeReward'] as int? ?? 10,
      description: json['description'] as String,
      rounds: roundsList,
      isCompleted: json['isCompleted'] as bool? ?? false,
      bracket: bracketJson != null ? TournamentBracket.fromJson(bracketJson) : null,
    );

    return tourney;
  }

  // Standard tournament roster setup with 3-4 distinct fighters for bracket progression
  static List<TournamentModel> generateDefaultTournaments() {
    return [
      // Street Track
      TournamentModel(
        id: 'purok_bakbakan',
        title: 'Inter-Purok Bakbakan',
        track: TournamentTrack.streetTrack,
        eventType: TournamentEventType.fullContactLaban,
        scheduledMonth: 1, // available anytime
        minGradeRequired: 0,
        entryFee: 50,
        prizeMoney: 400,
        prestigeReward: 5,
        description: 'Under the mango trees behind the chapel. Fast cash and tough local rivals.',
        rounds: [
          const TournamentOpponent(
            name: 'Kanor "Sipol"',
            title: 'Tricycle Driver Arnisador',
            gymName: 'Toda Purok Club',
            officialRecord: '4-3-0',
            hp: 90,
            power: 14,
            speed: 13,
            technique: 10,
            defense: 10,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.yantok,
            dialogue: 'O, pambili lang ito ng gas!',
          ),
          const TournamentOpponent(
            name: 'Berto Batuta',
            title: 'Purok Heavy Hitter',
            gymName: 'Ilaya Bakbakan Gym',
            officialRecord: '10-2-1',
            hp: 120,
            power: 20,
            speed: 14,
            technique: 12,
            defense: 13,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.bahi,
            dialogue: 'Bata ka pa! Umuwi ka na bago ka mapilayan!',
          ),
          const TournamentOpponent(
            name: 'Dodong Eskrima',
            title: 'Street Contender',
            gymName: 'San Isidro Kali',
            officialRecord: '7-4-0',
            hp: 105,
            power: 17,
            speed: 16,
            technique: 13,
            defense: 11,
            style: FighterStyle.dobleBaston,
            weapon: WeaponItem.yantok,
            dialogue: 'Mabilis ang mga kamay ko sa kalsada!',
          ),
        ],
      ),
      TournamentModel(
        id: 'fiesta_cup',
        title: 'Inter-Barangay Fiesta Cup',
        track: TournamentTrack.streetTrack,
        eventType: TournamentEventType.fullContactLaban,
        scheduledMonth: 5, // May Fiesta
        minGradeRequired: 0,
        entryFee: 150,
        prizeMoney: 1200,
        prestigeReward: 15,
        description: 'Barangay court packed with cheering crowd and brass band playing in the background.',
        rounds: [
          const TournamentOpponent(
            name: 'Dodong Eskrima',
            title: 'Barangay San Isidro Rep',
            gymName: 'San Isidro Bastoneros',
            officialRecord: '8-3-1',
            hp: 125,
            power: 19,
            speed: 17,
            technique: 15,
            defense: 14,
            style: FighterStyle.dobleBaston,
            weapon: WeaponItem.yantok,
            dialogue: 'Sinawali ang tatapos sa laban na ito!',
          ),
          const TournamentOpponent(
            name: 'Master Nonoy',
            title: 'Fiesta Defending Champ',
            gymName: 'Barangay Central Hall',
            officialRecord: '15-1-0',
            hp: 150,
            power: 24,
            speed: 18,
            technique: 19,
            defense: 18,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.bahi,
            dialogue: 'Igalang mo ang matatanda sa court!',
          ),
          const TournamentOpponent(
            name: 'Gardo "Kidlat"',
            title: 'Township Speedster',
            gymName: 'Poblacion Speed Kali',
            officialRecord: '9-2-0',
            hp: 135,
            power: 20,
            speed: 21,
            technique: 17,
            defense: 15,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.yantok,
            dialogue: 'Kidlat kung humataw ang baston ko!',
          ),
        ],
      ),
      TournamentModel(
        id: 'mayors_cup',
        title: 'Municipal Mayor\'s Cup',
        track: TournamentTrack.streetTrack,
        eventType: TournamentEventType.fullContactLaban,
        scheduledMonth: 8,
        minGradeRequired: 0,
        entryFee: 300,
        prizeMoney: 2800,
        prestigeReward: 30,
        description: 'High-stakes town championship. Scouts and masters are watching from the bleachers.',
        rounds: [
          const TournamentOpponent(
            name: 'Gardo "Kidlat"',
            title: 'Township Speedster',
            gymName: 'Poblacion Speed Kali',
            officialRecord: '11-3-0',
            hp: 155,
            power: 22,
            speed: 25,
            technique: 21,
            defense: 16,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.bahi,
            dialogue: 'Hindi mo maabutan ang dulo ng baston ko!',
          ),
          const TournamentOpponent(
            name: 'Berto "Bakal" Batuta',
            title: 'Barangay Champion Rival',
            gymName: 'Ilaya Bakbakan Gym',
            officialRecord: '18-4-2',
            hp: 185,
            power: 30,
            speed: 21,
            technique: 23,
            defense: 22,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.kamagong,
            dialogue: 'Dito magtatapos ang kwento mo!',
          ),
          const TournamentOpponent(
            name: 'Macky "Matador"',
            title: 'Township Contender',
            gymName: 'Matador Blade Club',
            officialRecord: '14-2-0',
            hp: 165,
            power: 25,
            speed: 23,
            technique: 22,
            defense: 19,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.bahi,
            dialogue: 'Handa ka na bang sumuko?',
          ),
        ],
      ),

      // School Varsity Track (Grades >= 80 required!)
      TournamentModel(
        id: 'school_intrams',
        title: 'School Intramurals Championship',
        track: TournamentTrack.schoolTrack,
        eventType: TournamentEventType.fullContactLaban,
        scheduledMonth: 9, // September
        minGradeRequired: 80.0,
        entryFee: 0,
        prizeMoney: 600,
        prestigeReward: 20,
        description: 'Annual school sports meet. Win to be selected for the District/Division delegation.',
        rounds: [
          const TournamentOpponent(
            name: 'Red House Rival',
            title: 'Grade 6 Senior Fighter',
            gymName: 'Red Dragons Squad',
            officialRecord: '6-2-0',
            hp: 110,
            power: 16,
            speed: 15,
            technique: 14,
            defense: 12,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Para sa karangalan ng Red Dragons!',
          ),
          const TournamentOpponent(
            name: 'Aldo Ramos',
            title: 'Varsity Team Captain',
            gymName: 'Blue Tigers Varsity',
            officialRecord: '12-1-0',
            hp: 135,
            power: 21,
            speed: 19,
            technique: 18,
            defense: 16,
            style: FighterStyle.dobleBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Tingnan natin kung karapat-dapat ka sa varsity!',
          ),
          const TournamentOpponent(
            name: 'Caloocan District Ace',
            title: 'Visiting Junior Fighter',
            gymName: 'District Academy',
            officialRecord: '8-2-0',
            hp: 120,
            power: 18,
            speed: 17,
            technique: 16,
            defense: 14,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Magandang laban ito para sa intrams!',
          ),
        ],
      ),
      TournamentModel(
        id: 'division_meet',
        title: 'District & Division Meet',
        track: TournamentTrack.schoolTrack,
        eventType: TournamentEventType.fullContactLaban,
        scheduledMonth: 11, // November
        minGradeRequired: 80.0,
        entryFee: 0,
        prizeMoney: 1500,
        prestigeReward: 40,
        description: 'Principal Santos is watching closely! Win gold to save our school Arnis club funding.',
        rounds: [
          const TournamentOpponent(
            name: 'Caloocan District Ace',
            title: 'Division Finalist',
            gymName: 'District 1 Athletics',
            officialRecord: '11-2-1',
            hp: 150,
            power: 23,
            speed: 22,
            technique: 21,
            defense: 18,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Handa na ang pambato ng District 1!',
          ),
          const TournamentOpponent(
            name: 'Macky "Matador"',
            title: 'Defending Division Gold Medalist',
            gymName: 'North Division High',
            officialRecord: '16-1-0',
            hp: 175,
            power: 28,
            speed: 24,
            technique: 25,
            defense: 21,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Walang makakaagaw ng ginto sa akin!',
          ),
          const TournamentOpponent(
            name: 'Pampanga Blade',
            title: 'Central Luzon Guest',
            gymName: 'Pampanga Arnis Guild',
            officialRecord: '14-3-0',
            hp: 160,
            power: 25,
            speed: 24,
            technique: 23,
            defense: 20,
            style: FighterStyle.dobleBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Pagsisikapan naming makuha ang ginto!',
          ),
        ],
      ),
      TournamentModel(
        id: 'regional_meet',
        title: 'Regional Athletic Meet (CLRAA / NCR)',
        track: TournamentTrack.schoolTrack,
        eventType: TournamentEventType.fullContactLaban,
        scheduledMonth: 2, // February
        minGradeRequired: 80.0,
        entryFee: 0,
        prizeMoney: 3000,
        prestigeReward: 70,
        description: 'Top athletes from all provinces competing for qualifying slots in Palarong Pambansa.',
        rounds: [
          const TournamentOpponent(
            name: 'Pampanga Blade',
            title: 'Central Luzon Champion',
            gymName: 'Pampanga Warriors',
            officialRecord: '18-2-0',
            hp: 180,
            power: 29,
            speed: 27,
            technique: 26,
            defense: 24,
            style: FighterStyle.dobleBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Mabilis ang stick ng Kapampangan!',
          ),
          const TournamentOpponent(
            name: 'Lorenzo Dela Cruz',
            title: 'Private Academy Prodigy',
            gymName: 'Dela Cruz Martial Guild',
            officialRecord: '22-0-0',
            hp: 210,
            power: 34,
            speed: 29,
            technique: 30,
            defense: 27,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.kamagong,
            dialogue: 'My coach was trained by national grandmasters. You have no chance.',
          ),
          const TournamentOpponent(
            name: 'Western Visayas Kali Master',
            title: 'Iloilo Delegation',
            gymName: 'Panay Kali Club',
            officialRecord: '19-3-0',
            hp: 195,
            power: 31,
            speed: 28,
            technique: 28,
            defense: 25,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Ipakita ang tunay na liksi!',
          ),
        ],
      ),
      TournamentModel(
        id: 'palarong_pambansa',
        title: 'Palarong Pambansa (National Games)',
        track: TournamentTrack.schoolTrack,
        eventType: TournamentEventType.fullContactLaban,
        scheduledMonth: 5, // May
        minGradeRequired: 80.0,
        entryFee: 0,
        prizeMoney: 8000,
        prestigeReward: 150,
        description: 'The pinnacle of school athletic achievement in the Philippines. Broadcasted nationwide!',
        rounds: [
          const TournamentOpponent(
            name: 'Western Visayas Kali Master',
            title: 'Iloilo Kali Phenom',
            gymName: 'Iloilo Kali Academy',
            officialRecord: '24-2-0',
            hp: 220,
            power: 36,
            speed: 32,
            technique: 33,
            defense: 29,
            style: FighterStyle.dobleBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Tultol ang hambal sang Visayas!',
          ),
          const TournamentOpponent(
            name: 'Davao Golden Baston',
            title: 'Mindanao Undefeated Titan',
            gymName: 'Mindanao Martial Citadel',
            officialRecord: '28-0-0',
            hp: 250,
            power: 42,
            speed: 34,
            technique: 36,
            defense: 33,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Ito ang Palaro! Ibigay mo ang lahat!',
          ),
          const TournamentOpponent(
            name: 'Lorenzo Dela Cruz',
            title: 'Defending National MVP',
            gymName: 'Dela Cruz Martial Guild',
            officialRecord: '26-1-0',
            hp: 235,
            power: 38,
            speed: 33,
            technique: 34,
            defense: 30,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.kamagong,
            dialogue: 'Muling maghaharap ang ating mga baston!',
          ),
        ],
      ),
    ];
  }
}
