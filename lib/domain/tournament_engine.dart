// lib/domain/tournament_engine.dart
// PURE DART - NO FLUTTER OR FLAME IMPORTS.
// Headless single-elimination tournament, bracketing, and opponent generator.

import 'dart:math';
import 'balance.dart';
import 'match_engine.dart';
import 'models/student.dart';
import 'rng.dart';

enum TournamentTrack {
  community,
  school,
}

extension TournamentTrackName on TournamentTrack {
  String get displayName {
    switch (this) {
      case TournamentTrack.community:
        return 'Komunidad (Community Track)';
      case TournamentTrack.school:
        return 'Paaralan (School Track)';
    }
  }
}

enum TournamentDivision {
  elementarya,
  sekondarya,
  bukas,
}

extension TournamentDivisionName on TournamentDivision {
  String get displayName {
    switch (this) {
      case TournamentDivision.elementarya:
        return 'Elementarya (Grades 1-6)';
      case TournamentDivision.sekondarya:
        return 'Sekondarya (Grades 7-12)';
      case TournamentDivision.bukas:
        return 'Bukas (Open / Adult)';
    }
  }
}

class TournamentContender {
  final String id;
  final String name;
  final String gymName;
  final double lakas;
  final double bilis;
  final double diskarte;
  final double salag;
  final ArnisStyle style;
  final bool isPlayer;
  final String? studentId;
  final String dialogue;

  const TournamentContender({
    required this.id,
    required this.name,
    this.gymName = 'Purok Baston Club',
    required this.lakas,
    required this.bilis,
    required this.diskarte,
    required this.salag,
    this.style = ArnisStyle.soloBaston,
    this.isPlayer = false,
    this.studentId,
    this.dialogue = 'Handa na ang aking baston!',
  });

  double get totalStats => lakas + bilis + diskarte + salag;

  Combatant toCombatant() {
    return Combatant.create(
      id: id,
      name: name,
      lakas: lakas,
      bilis: bilis,
      diskarte: diskarte,
      salag: salag,
      style: style,
    );
  }

  factory TournamentContender.fromStudent(Student s) {
    return TournamentContender(
      id: s.id,
      name: '${s.name} "${s.nickname}"',
      gymName: 'Bakuran Arnis Camp',
      lakas: s.lakas,
      bilis: s.bilis,
      diskarte: s.diskarte,
      salag: s.salag,
      style: s.style,
      isPlayer: true,
      studentId: s.id,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gymName': gymName,
        'lakas': lakas,
        'bilis': bilis,
        'diskarte': diskarte,
        'salag': salag,
        'style': style.index,
        'isPlayer': isPlayer,
        'studentId': studentId,
        'dialogue': dialogue,
      };

  factory TournamentContender.fromJson(Map<String, dynamic> json) =>
      TournamentContender(
        id: json['id'] as String,
        name: json['name'] as String,
        gymName: json['gymName'] as String? ?? 'Purok Baston Club',
        lakas: (json['lakas'] as num).toDouble(),
        bilis: (json['bilis'] as num).toDouble(),
        diskarte: (json['diskarte'] as num).toDouble(),
        salag: (json['salag'] as num).toDouble(),
        style: ArnisStyle.values[json['style'] as int? ?? 0],
        isPlayer: json['isPlayer'] as bool? ?? false,
        studentId: json['studentId'] as String?,
        dialogue: json['dialogue'] as String? ?? '',
      );
}

class TournamentMatch {
  final int matchId;
  final int roundIndex;
  final String stageName;
  TournamentContender? contender1;
  TournamentContender? contender2;
  TournamentContender? winner;
  bool isCompleted;

  TournamentMatch({
    required this.matchId,
    required this.roundIndex,
    required this.stageName,
    this.contender1,
    this.contender2,
    this.winner,
    this.isCompleted = false,
  });

  bool get isPlayerMatch =>
      (contender1?.isPlayer ?? false) || (contender2?.isPlayer ?? false);

  TournamentContender? get opponentOfPlayer {
    if (contender1?.isPlayer ?? false) return contender2;
    if (contender2?.isPlayer ?? false) return contender1;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'roundIndex': roundIndex,
        'stageName': stageName,
        'contender1': contender1?.toJson(),
        'contender2': contender2?.toJson(),
        'winner': winner?.toJson(),
        'isCompleted': isCompleted,
      };

  factory TournamentMatch.fromJson(Map<String, dynamic> json) =>
      TournamentMatch(
        matchId: json['matchId'] as int,
        roundIndex: json['roundIndex'] as int,
        stageName: json['stageName'] as String,
        contender1: json['contender1'] != null
            ? TournamentContender.fromJson(json['contender1'] as Map<String, dynamic>)
            : null,
        contender2: json['contender2'] != null
            ? TournamentContender.fromJson(json['contender2'] as Map<String, dynamic>)
            : null,
        winner: json['winner'] != null
            ? TournamentContender.fromJson(json['winner'] as Map<String, dynamic>)
            : null,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class TournamentInfo {
  final String id;
  final String name;
  final TournamentTrack track;
  final int tier;
  final TournamentDivision division;
  final int rounds; // 2, 3, 4, or 5
  final int entryFee;
  final int travelCost;
  final int prizeMoney;
  final int scholarshipPoints;
  final int fameReward;
  final int scheduledMonth;
  final int scheduledWeek;
  final int minFame;
  final String minCampRank;
  final String description;

  const TournamentInfo({
    required this.id,
    required this.name,
    required this.track,
    required this.tier,
    this.division = TournamentDivision.bukas,
    required this.rounds,
    required this.entryFee,
    this.travelCost = 0,
    required this.prizeMoney,
    this.scholarshipPoints = 0,
    required this.fameReward,
    required this.scheduledMonth,
    required this.scheduledWeek,
    required this.minFame,
    required this.minCampRank,
    required this.description,
  });

  int get totalCost => entryFee + travelCost;

  int get totalContenders => 1 << rounds; // 2^rounds: 2->4, 3->8, 4->16, 5->32
}

class TournamentBracket {
  final String tournamentId;
  final int totalRounds;
  final List<TournamentMatch> matches;
  int currentRoundIndex;
  bool isFinished;
  TournamentContender? champion;

  TournamentBracket({
    required this.tournamentId,
    required this.totalRounds,
    required this.matches,
    this.currentRoundIndex = 0,
    this.isFinished = false,
    this.champion,
  });

  TournamentMatch? get activePlayerMatch {
    for (final m in matches) {
      if (m.roundIndex == currentRoundIndex && m.isPlayerMatch && !m.isCompleted) {
        return m;
      }
    }
    return null;
  }

  List<TournamentMatch> get matchesInCurrentRound =>
      matches.where((m) => m.roundIndex == currentRoundIndex).toList();

  /// Advance a match with the specified winner.
  void advanceMatch(int matchId, TournamentContender matchWinner) {
    final match = matches.firstWhere((m) => m.matchId == matchId);
    match.winner = matchWinner;
    match.isCompleted = true;

    // Check if this was the Championship Final
    if (match.roundIndex == totalRounds - 1) {
      isFinished = true;
      champion = matchWinner;
      return;
    }

    // Determine the next match node in the tree
    // Matches in roundIndex r are numbered sequentially.
    // In round 0, matches 0 and 1 feed into match in round 1, etc.
    final currentRoundMatches =
        matches.where((m) => m.roundIndex == match.roundIndex).toList();
    final matchPosInRound = currentRoundMatches.indexOf(match);
    final nextRoundMatchPos = matchPosInRound ~/ 2;

    final nextRoundMatches =
        matches.where((m) => m.roundIndex == match.roundIndex + 1).toList();

    if (nextRoundMatchPos < nextRoundMatches.length) {
      final nextMatch = nextRoundMatches[nextRoundMatchPos];
      if (matchPosInRound % 2 == 0) {
        nextMatch.contender1 = matchWinner;
      } else {
        nextMatch.contender2 = matchWinner;
      }
    }

    // Check if all matches in the current round are completed
    final allCurrentRoundDone =
        currentRoundMatches.every((m) => m.isCompleted);
    if (allCurrentRoundDone && currentRoundIndex < totalRounds - 1) {
      currentRoundIndex += 1;
    }
  }

  /// Automatically simulate NPC vs NPC matches for the current round
  void simulateAllNpcMatchesForCurrentRound({GameRng? rng}) {
    final gameRng = rng ?? GameRng(DateTime.now().microsecondsSinceEpoch);

    for (final m in matchesInCurrentRound) {
      if (!m.isCompleted && !m.isPlayerMatch && m.contender1 != null && m.contender2 != null) {
        final c1 = m.contender1!;
        final c2 = m.contender2!;

        // Deterministic simulation via headless MatchEngine
        final engine = MatchEngine(
          player: c1.toCombatant(),
          opponent: c2.toCombatant(),
          totalRounds: 3,
          seed: gameRng.nextInt(1000000),
        );
        final result = engine.simulateEntireMatch();
        final winnerContender = result.isPlayerWinner ? c1 : c2;
        advanceMatch(m.matchId, winnerContender);
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'tournamentId': tournamentId,
        'totalRounds': totalRounds,
        'currentRoundIndex': currentRoundIndex,
        'isFinished': isFinished,
        'champion': champion?.toJson(),
        'matches': matches.map((m) => m.toJson()).toList(),
      };

  factory TournamentBracket.fromJson(Map<String, dynamic> json) =>
      TournamentBracket(
        tournamentId: json['tournamentId'] as String,
        totalRounds: json['totalRounds'] as int,
        currentRoundIndex: json['currentRoundIndex'] as int? ?? 0,
        isFinished: json['isFinished'] as bool? ?? false,
        champion: json['champion'] != null
            ? TournamentContender.fromJson(json['champion'] as Map<String, dynamic>)
            : null,
        matches: (json['matches'] as List<dynamic>?)
                ?.map((e) => TournamentMatch.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class TournamentEngine {
  /// 6 Community Track + 5 School Track Tournaments (Section 10 Spec)
  static final List<TournamentInfo> allTournaments = [
    // --- COMMUNITY TRACK (KOMUNIDAD) ---
    const TournamentInfo(
      id: 'inter_purok',
      name: 'Inter-Purok Cup',
      track: TournamentTrack.community,
      tier: 1,
      division: TournamentDivision.bukas,
      rounds: 2, // 4 contenders
      entryFee: 0,
      travelCost: 0,
      prizeMoney: 500,
      fameReward: 20,
      scheduledMonth: 7, // July
      scheduledWeek: 3,
      minFame: 0,
      minCampRank: 'purok',
      description: 'Labanan ng mga bagong arnisador sa barangay basketball court o bakanteng lote.',
    ),
    const TournamentInfo(
      id: 'inter_barangay',
      name: 'Inter-Barangay Games',
      track: TournamentTrack.community,
      tier: 2,
      division: TournamentDivision.bukas,
      rounds: 3, // 8 contenders
      entryFee: 100,
      travelCost: 0,
      prizeMoney: 1500,
      fameReward: 60,
      scheduledMonth: 1, // January (Pista season)
      scheduledWeek: 2,
      minFame: 150,
      minCampRank: 'barangay',
      description: 'Taunang palaro tuwing kapistahan ng patron. May premyo at papuri mula sa Kapitan.',
    ),
    const TournamentInfo(
      id: 'inter_bayan',
      name: 'Inter-Bayan (Town) Arnis Championship',
      track: TournamentTrack.community,
      tier: 3,
      division: TournamentDivision.bukas,
      rounds: 3, // 8 contenders
      entryFee: 300,
      travelCost: 0,
      prizeMoney: 4000,
      fameReward: 150,
      scheduledMonth: 3, // March
      scheduledWeek: 2,
      minFame: 600,
      minCampRank: 'bayan',
      description: "Mayor's Cup na nilalahukan ng pinakamagagaling na mandirigma ng buong bayan.",
    ),
    const TournamentInfo(
      id: 'provincial_meet',
      name: 'Provincial Arnis Meet',
      track: TournamentTrack.community,
      tier: 4,
      division: TournamentDivision.bukas,
      rounds: 4, // 16 contenders
      entryFee: 800,
      travelCost: 500,
      prizeMoney: 10000,
      fameReward: 400,
      scheduledMonth: 5, // May
      scheduledWeek: 3,
      minFame: 2500,
      minCampRank: 'probinsya',
      description: 'Lalawigan level na torneyo sa kapitolyo. Matitindi ang mga delegado.',
    ),
    const TournamentInfo(
      id: 'regional_open',
      name: 'Regional Open',
      track: TournamentTrack.community,
      tier: 5,
      division: TournamentDivision.bukas,
      rounds: 4, // 16 contenders
      entryFee: 1500,
      travelCost: 1500,
      prizeMoney: 30000,
      fameReward: 900,
      scheduledMonth: 9, // September
      scheduledWeek: 2,
      minFame: 9000,
      minCampRank: 'rehiyon',
      description: "Bakbakan ng mga kampeon mula sa iba't ibang probinsya.",
    ),
    const TournamentInfo(
      id: 'pambansang_kampeonato',
      name: 'Pambansang Kampeonato (National Open)',
      track: TournamentTrack.community,
      tier: 6,
      division: TournamentDivision.bukas,
      rounds: 5, // 32 contenders
      entryFee: 3000,
      travelCost: 4000,
      prizeMoney: 100000,
      fameReward: 2500,
      scheduledMonth: 11, // November
      scheduledWeek: 4,
      minFame: 30000,
      minCampRank: 'pambansa',
      description: 'Ang rurok ng sining ng Baston sa Pilipinas. Dito kinikilala ang tunay na alamat.',
    ),

    // --- SCHOOL TRACK (PAARALAN) ---
    const TournamentInfo(
      id: 'school_intrams',
      name: 'School Intramurals',
      track: TournamentTrack.school,
      tier: 1,
      division: TournamentDivision.elementarya,
      rounds: 2, // 4 contenders
      entryFee: 0,
      travelCost: 0,
      prizeMoney: 300,
      scholarshipPoints: 50,
      fameReward: 20,
      scheduledMonth: 8, // August
      scheduledWeek: 3,
      minFame: 0,
      minCampRank: 'purok',
      description: 'Palaro sa paaralan. Kailangan ng Grado >= 75% para makasali.',
    ),
    const TournamentInfo(
      id: 'district_meet',
      name: 'District Meet',
      track: TournamentTrack.school,
      tier: 2,
      division: TournamentDivision.elementarya,
      rounds: 3, // 8 contenders
      entryFee: 0,
      travelCost: 0,
      prizeMoney: 800,
      scholarshipPoints: 100,
      fameReward: 50,
      scheduledMonth: 10, // October
      scheduledWeek: 2,
      minFame: 150,
      minCampRank: 'barangay',
      description: 'Torneyo ng mga pinakamahusay na paaralan sa buong distrito.',
    ),
    const TournamentInfo(
      id: 'division_meet',
      name: 'Division Meet',
      track: TournamentTrack.school,
      tier: 3,
      division: TournamentDivision.sekondarya,
      rounds: 3, // 8 contenders
      entryFee: 0,
      travelCost: 0,
      prizeMoney: 1500,
      scholarshipPoints: 200,
      fameReward: 120,
      scheduledMonth: 11, // November
      scheduledWeek: 3,
      minFame: 600,
      minCampRank: 'bayan',
      description: 'Labanan ng mga panlungsod at pampurok na varsity.',
    ),
    const TournamentInfo(
      id: 'regional_athletic',
      name: 'Regional Athletic Meet',
      track: TournamentTrack.school,
      tier: 4,
      division: TournamentDivision.sekondarya,
      rounds: 4, // 16 contenders
      entryFee: 0,
      travelCost: 800,
      prizeMoney: 4000,
      scholarshipPoints: 400,
      fameReward: 400,
      scheduledMonth: 1, // January
      scheduledWeek: 2,
      minFame: 2500,
      minCampRank: 'probinsya',
      description: 'Qualifying meet para sa Palarong Pambansa. Mataas ang dangal ng eskwelahan.',
    ),
    const TournamentInfo(
      id: 'palarong_pambansa',
      name: 'Palarong Pambansa',
      track: TournamentTrack.school,
      tier: 5,
      division: TournamentDivision.bukas,
      rounds: 5, // 32 contenders
      entryFee: 0,
      travelCost: 3000,
      prizeMoney: 20000,
      scholarshipPoints: 1000,
      fameReward: 2000,
      scheduledMonth: 4, // April (Summer break)
      scheduledWeek: 3,
      minFame: 9000,
      minCampRank: 'rehiyon',
      description: 'Ang pinakamalaking palarong pampaaralan sa bansa tuwing bakasyon.',
    ),
  ];

  static const List<String> rivalGyms = [
    'Berto Club',
    'Toda Purok Club',
    'Ilaya Bakbakan Gym',
    'San Isidro Kali',
    'Sipol Kali Dojo',
    'Katipunan Eskrima Academy',
    'Dela Cruz Martial Guild',
    'Maharlika Arnis Club',
    'Western Visayas Bastoneros',
  ];

  static const List<String> opponentFirstNames = [
    'Berto', 'Kanor', 'Dodong', 'Lorenzo', 'Danilo', 'Andres', 'Datu', 'Nonoy',
    'Gardo', 'Isagani', 'Arnel', 'Crisanto', 'Renato', 'Lito', 'Bayani', 'Nestor',
  ];

  static const List<String> opponentLastNames = [
    'Batuta', 'Dimagiba', 'Malabanan', 'Dela Cruz', 'Magtanggol', 'Kidlat',
    'Tigre', 'Alon', 'Sipol', 'Matapang', 'Bagsik', 'Silang', 'Agila',
  ];

  /// Generate procedurally scaled NPC contenders matching Section 10 tier stats
  static TournamentContender generateOpponent({
    required int tier,
    required int seed,
    bool isFinalsBoss = false,
  }) {
    final rng = GameRng(seed);

    // Target stats from Balance table
    final baseTarget = Balance.opponentStatTargetByTier[tier] ?? 100.0;
    final variance = rng.rangeDouble(0.85, 1.15); // ±15%
    final finalsBonus = isFinalsBoss ? 1.10 : 1.0; // +10% for final round
    final totalTarget = baseTarget * variance * finalsBonus;

    // Distribute across 4 stats: Lakas, Bilis, Diskarte, Salag
    final lakas = totalTarget * rng.rangeDouble(0.24, 0.32);
    final bilis = totalTarget * rng.rangeDouble(0.22, 0.30);
    final diskarte = totalTarget * rng.rangeDouble(0.20, 0.28);
    final salag = max(5.0, totalTarget - (lakas + bilis + diskarte));

    final firstName = opponentFirstNames[rng.nextInt(opponentFirstNames.length)];
    final lastName = opponentLastNames[rng.nextInt(opponentLastNames.length)];
    final gym = rivalGyms[rng.nextInt(rivalGyms.length)];
    final style = ArnisStyle.values[rng.nextInt(ArnisStyle.values.length)];

    return TournamentContender(
      id: 'opp_${seed}_$tier',
      name: '$firstName "$lastName"',
      gymName: gym,
      lakas: double.parse(lakas.toStringAsFixed(1)),
      bilis: double.parse(bilis.toStringAsFixed(1)),
      diskarte: double.parse(diskarte.toStringAsFixed(1)),
      salag: double.parse(salag.toStringAsFixed(1)),
      style: style,
      isPlayer: false,
    );
  }

  /// Create a complete, fully populated single-elimination bracket
  static TournamentBracket createBracket({
    required TournamentInfo tournament,
    required List<Student> playerStudents,
    int? seed,
  }) {
    final rng = GameRng(seed ?? DateTime.now().microsecondsSinceEpoch);
    final totalContenders = tournament.totalContenders;
    final totalRounds = tournament.rounds;

    // 1. Generate contenders
    final contenders = <TournamentContender>[];

    // Seed up to 2 player students
    for (int i = 0; i < min(playerStudents.length, 2); i++) {
      contenders.add(TournamentContender.fromStudent(playerStudents[i]));
    }

    // Fill remaining spots with procedurally scaled NPCs
    var oppSeed = rng.nextInt(100000);
    while (contenders.length < totalContenders) {
      final isLastSlot = contenders.length == totalContenders - 1;
      contenders.add(generateOpponent(
        tier: tournament.tier,
        seed: oppSeed++,
        isFinalsBoss: isLastSlot,
      ));
    }

    // Shuffle NPCs while keeping player students seeded
    final playerContenders = contenders.where((c) => c.isPlayer).toList();
    final npcContenders = contenders.where((c) => !c.isPlayer).toList();
    npcContenders.shuffle(Random(rng.nextInt(10000)));

    final seededContenders = <TournamentContender>[];
    if (playerContenders.length == 1) {
      // Player in match 0
      seededContenders.add(playerContenders[0]);
      seededContenders.addAll(npcContenders);
    } else if (playerContenders.length >= 2) {
      // Player 1 in match 0, Player 2 on the opposite side of the bracket!
      seededContenders.add(playerContenders[0]);
      seededContenders.addAll(npcContenders.sublist(0, (totalContenders ~/ 2) - 1));
      seededContenders.add(playerContenders[1]);
      seededContenders.addAll(npcContenders.sublist((totalContenders ~/ 2) - 1));
    } else {
      seededContenders.addAll(npcContenders);
    }

    // 2. Build Bracket Matches
    final matches = <TournamentMatch>[];
    int matchIdCounter = 1;

    // Round 0 (Initial Round)
    final round0MatchesCount = totalContenders ~/ 2;
    for (int i = 0; i < round0MatchesCount; i++) {
      final stage = _getStageName(roundIndex: 0, totalRounds: totalRounds);
      final c1 = seededContenders[i * 2];
      final c2 = seededContenders[i * 2 + 1];

      matches.add(TournamentMatch(
        matchId: matchIdCounter++,
        roundIndex: 0,
        stageName: stage,
        contender1: c1,
        contender2: c2,
      ));
    }

    // Subsequent Rounds (Empty matches waiting for winners)
    var matchesInRound = round0MatchesCount ~/ 2;
    for (int r = 1; r < totalRounds; r++) {
      final stage = _getStageName(roundIndex: r, totalRounds: totalRounds);
      for (int i = 0; i < matchesInRound; i++) {
        matches.add(TournamentMatch(
          matchId: matchIdCounter++,
          roundIndex: r,
          stageName: stage,
        ));
      }
      matchesInRound ~/= 2;
    }

    return TournamentBracket(
      tournamentId: tournament.id,
      totalRounds: totalRounds,
      matches: matches,
    );
  }

  static String _getStageName({required int roundIndex, required int totalRounds}) {
    final roundsRemaining = totalRounds - 1 - roundIndex;
    if (roundsRemaining == 0) return 'Championship Final';
    if (roundsRemaining == 1) return 'Semi-Finals';
    if (roundsRemaining == 2) return 'Quarter-Finals';
    if (roundsRemaining == 3) return 'Round of 16';
    return 'Elimination Round ${roundIndex + 1}';
  }

  /// Verify if a student is eligible for the tournament
  static bool isStudentEligible(Student student, TournamentInfo info) {
    if (student.status == StudentStatus.injured) return false;

    if (info.track == TournamentTrack.school) {
      if (!student.isVarsityEligible) return false; // >= 75%
      if (info.division == TournamentDivision.elementarya) {
        if (student.grade < 1 || student.grade > 6) return false;
      } else if (info.division == TournamentDivision.sekondarya) {
        if (student.grade < 7 || student.grade > 12) return false;
      }
    } else {
      // Community Track age checks
      if (info.division == TournamentDivision.elementarya && student.age > 12) {
        return false;
      }
      if (info.division == TournamentDivision.sekondarya &&
          (student.age < 13 || student.age > 18)) {
        return false;
      }
    }
    return true;
  }

  /// Check if the tournament is currently unlocked based on fame and camp rank
  static bool isTournamentUnlocked({
    required TournamentInfo info,
    required int campFame,
    required int highestParticipatedTierCommunity,
    required int highestParticipatedTierSchool,
  }) {
    if (campFame < info.minFame) return false;

    // Tier participation prerequisite:
    // Tier 1 is always unlocked. Tier > 1 requires participation in Tier - 1.
    if (info.tier > 1) {
      final highestTier = info.track == TournamentTrack.community
          ? highestParticipatedTierCommunity
          : highestParticipatedTierSchool;
      if (highestTier < info.tier - 1) return false;
    }

    return true;
  }
}
