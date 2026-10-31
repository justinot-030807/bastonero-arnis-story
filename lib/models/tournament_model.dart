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

class TournamentModel {
  final String id;
  final String title;
  final TournamentTrack track;
  final TournamentEventType eventType;
  final int scheduledMonth; // 1 - 12 (e.g. 9 for Sept Intrams, 11 for Nov Division)
  final double minGradeRequired; // 80.0 for school track, 0 for street
  final int minGradeLevel; // 5 = Grade 5, etc.
  final int entryFee;
  final int prizeMoney;
  final int prestigeReward;
  final String description;
  final List<TournamentOpponent> rounds;
  bool isCompleted;

  TournamentModel({
    required this.id,
    required this.title,
    required this.track,
    required this.eventType,
    required this.scheduledMonth,
    this.minGradeRequired = 0.0,
    this.minGradeLevel = 5,
    this.entryFee = 0,
    this.prizeMoney = 500,
    this.prestigeReward = 10,
    required this.description,
    required this.rounds,
    this.isCompleted = false,
  });

  bool isEligible(FighterModel fighter, int currentMonth) {
    if (track == TournamentTrack.schoolTrack) {
      if (!fighter.isEligibleForSchoolVarsity) return false;
      if (fighter.gradeLevel < minGradeLevel) return false;
    }
    // Tournaments happen in specific months, or open on demand for street track
    if (track == TournamentTrack.schoolTrack && currentMonth != scheduledMonth) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'track': track.index,
        'eventType': eventType.index,
        'scheduledMonth': scheduledMonth,
        'minGradeRequired': minGradeRequired,
        'minGradeLevel': minGradeLevel,
        'entryFee': entryFee,
        'prizeMoney': prizeMoney,
        'prestigeReward': prestigeReward,
        'description': description,
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'isCompleted': isCompleted,
      };

  factory TournamentModel.fromJson(Map<String, dynamic> json) => TournamentModel(
        id: json['id'] as String,
        title: json['title'] as String,
        track: TournamentTrack.values[json['track'] as int],
        eventType: TournamentEventType.values[json['eventType'] as int],
        scheduledMonth: json['scheduledMonth'] as int,
        minGradeRequired: (json['minGradeRequired'] as num?)?.toDouble() ?? 0.0,
        minGradeLevel: json['minGradeLevel'] as int? ?? 5,
        entryFee: json['entryFee'] as int? ?? 0,
        prizeMoney: json['prizeMoney'] as int? ?? 500,
        prestigeReward: json['prestigeReward'] as int? ?? 10,
        description: json['description'] as String,
        rounds: (json['rounds'] as List<dynamic>)
            .map((e) => TournamentOpponent.fromJson(e as Map<String, dynamic>))
            .toList(),
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  // Standard tournament roster setup
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
            hp: 120,
            power: 20,
            speed: 14,
            technique: 12,
            defense: 13,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.bahi,
            dialogue: 'Bata ka pa! Umuwi ka na bago ka mapilayan!',
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
            hp: 150,
            power: 24,
            speed: 18,
            technique: 19,
            defense: 18,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.bahi,
            dialogue: 'Igalang mo ang matatanda sa court!',
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
            hp: 185,
            power: 30,
            speed: 21,
            technique: 23,
            defense: 22,
            style: FighterStyle.soloBaston,
            weapon: WeaponItem.kamagong,
            dialogue: 'Dito magtatapos ang kwento mo!',
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
            hp: 135,
            power: 21,
            speed: 19,
            technique: 18,
            defense: 16,
            style: FighterStyle.dobleBaston,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Tingnan natin kung karapat-dapat ka sa varsity!',
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
            hp: 175,
            power: 28,
            speed: 24,
            technique: 25,
            defense: 21,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Walang makakaagaw ng ginto sa akin!',
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
            hp: 210,
            power: 34,
            speed: 29,
            technique: 30,
            defense: 27,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.kamagong,
            dialogue: 'My coach was trained by national grandmasters. You have no chance.',
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
            hp: 250,
            power: 42,
            speed: 34,
            technique: 36,
            defense: 33,
            style: FighterStyle.espadaYDaga,
            weapon: WeaponItem.paddedStick,
            dialogue: 'Ito ang Palaro! Ibigay mo ang lahat!',
          ),
        ],
      ),
    ];
  }
}
