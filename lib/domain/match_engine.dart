// lib/domain/match_engine.dart
// PURE DART - NO FLUTTER OR FLAME IMPORTS.
// Headless, deterministic match simulation engine for Bastonero: Arnis Story.

import 'dart:math';
import 'balance.dart';
import 'models/student.dart';
import 'rng.dart';

enum MatchEndReason {
  knockout,
  refereeStoppage,
  decision,
}

enum CoachCommand {
  bira,
  salag,
  diskarte,
}

enum StrikeOutcome {
  miss,
  blocked,
  hit,
  criticalHit,
}

class StrikeResult {
  final StrikeOutcome outcome;
  final double damage;
  final bool isCrit;
  final bool isBlocked;
  final String commentary;

  const StrikeResult({
    required this.outcome,
    required this.damage,
    this.isCrit = false,
    this.isBlocked = false,
    required this.commentary,
  });
}

class Combatant {
  final String id;
  final String name;
  final double maxHp;
  double currentHp;
  final double lakas;
  final double bilis;
  final double diskarte;
  final double salag;
  final ArnisStyle style;
  final List<String> moves;
  final List<String> traits;

  double actionMeter = 0.0;
  double pusoMeter = 0.0; // 0..100, fills on landed hits, triggers Finisher Tap
  double biraBuffDuration = 0.0;
  double salagBuffDuration = 0.0;
  double stunDuration = 0.0;

  // Match Stats
  int strikesAttempted = 0;
  int strikesLanded = 0;
  int strikesBlocked = 0;
  int critsLanded = 0;
  int comboCount = 0;
  int highestCombo = 0;
  double totalDamageDealt = 0.0;
  double maxDamageSingleHit = 0.0;

  Combatant({
    required this.id,
    required this.name,
    required this.maxHp,
    required this.currentHp,
    required this.lakas,
    required this.bilis,
    required this.diskarte,
    required this.salag,
    this.style = ArnisStyle.soloBaston,
    List<String>? moves,
    List<String>? traits,
  })  : moves = moves ?? ['abaniko'],
        traits = traits ?? [];

  factory Combatant.fromStudent(Student s) {
    return Combatant(
      id: s.id,
      name: '${s.name} "${s.nickname}"',
      maxHp: s.maxHp,
      currentHp: s.maxHp,
      lakas: s.lakas,
      bilis: s.bilis,
      diskarte: s.diskarte,
      salag: s.salag,
      style: s.style,
      moves: List<String>.from(s.moves),
      traits: List<String>.from(s.traits),
    );
  }

  factory Combatant.create({
    required String id,
    required String name,
    double lakas = 15.0,
    double bilis = 14.0,
    double diskarte = 13.0,
    double salag = 11.0,
    ArnisStyle style = ArnisStyle.soloBaston,
    List<String>? moves,
    List<String>? traits,
  }) {
    final totalStats = lakas + bilis + diskarte + salag;
    final hp = Balance.hpBaseOffset + (totalStats * Balance.hpStatMultiplier);
    return Combatant(
      id: id,
      name: name,
      maxHp: hp,
      currentHp: hp,
      lakas: lakas,
      bilis: bilis,
      diskarte: diskarte,
      salag: salag,
      style: style,
      moves: moves,
      traits: traits,
    );
  }

  double get effectiveLakas =>
      lakas * (biraBuffDuration > 0 ? (1.0 + Balance.biraPowerBuff) : 1.0);

  double get effectiveSalag =>
      salag * (salagBuffDuration > 0 ? (1.0 + Balance.salagDefenseBuff) : 1.0);

  double get hpPercent => (currentHp / maxHp).clamp(0.0, 1.0);
  bool get isKnockedOut => currentHp <= 0.0;
  bool get isStunned => stunDuration > 0.0;
}

class MatchResult {
  final Combatant winner;
  final Combatant loser;
  final MatchEndReason endReason;
  final int totalRoundsFought;
  final int totalTicks;
  final double finalRoundTimeRemaining;

  const MatchResult({
    required this.winner,
    required this.loser,
    required this.endReason,
    required this.totalRoundsFought,
    required this.totalTicks,
    required this.finalRoundTimeRemaining,
  });

  bool get isPlayerWinner => winner.id.startsWith('std_') || winner.id == 'player';
}

class MatchEngine {
  final Combatant player;
  final Combatant opponent;
  final int totalRounds;
  final GameRng rng;

  int currentRound = 1;
  double roundTimeRemaining = Balance.roundDurationSeconds;
  bool isMatchOver = false;
  Combatant? winner;
  Combatant? loser;
  MatchEndReason? endReason;
  int totalTicksElapsed = 0;

  double coachGigil = 30.0; // 0..100
  final List<String> recentLogs = [];
  void Function(Combatant attacker, Combatant defender, StrikeResult result)? onStrike;

  static const List<String> hitCommentary = [
    'Hataw sa tagiliran!',
    'Solidong tama ng yantok!',
    'Mabilis na abaniko strike!',
    'Bira mula sa kanang kamay!',
    'Pumalag ang baston sa balikat!',
    'Sapul sa tagiliran!',
    'Diretsong tama sa dibdib!',
    'Mabilis na counter strike!',
    'Lumagutok ang tama ng stick!',
    'Matinding pasok sa bukas na depensa!',
  ];

  static const List<String> blockCommentary = [
    'Salag! Matibay na harang ng baston!',
    'Nasalag ang mabigat na hataw!',
    'Harang ng kahoy! Nabawasan ang pinsala!',
    'Naiharang ang kaliwang baston!',
    'Matatag na sangga mula sa kalaban!',
    'Sangga! Dumausdos ang tama!',
  ];

  static const List<String> missCommentary = [
    'Sablay! Dumaplis lang sa hangin!',
    'Nakaiwas sa bira!',
    'Mabilis na hakbang pabalik, ligtas sa tama!',
    'Sablay! Mabilis ang footwork!',
    'Muntik na, pero umiwas sa oras!',
  ];

  static const List<String> critCommentary = [
    'GRABE! Tagos sa salag ang hataw!',
    'ASINTADO! Pambihirang Abaniko Tres Puntas!',
    'KUMALATOG! Wasak ang depensa!',
    'KRITIKAL! Nagpagewang ang kalaban!',
    'Napakalakas na palo! Lumipad ang alikabok!',
  ];

  MatchEngine({
    required this.player,
    required this.opponent,
    this.totalRounds = Balance.standardRounds,
    int? seed,
  }) : rng = GameRng(seed ?? DateTime.now().microsecondsSinceEpoch) {
    _addLog('REFEREE: Handa na ang dalawang arnisador sa court!');
    _addLog('Simula ng Round 1!');
  }

  void _addLog(String msg) {
    recentLogs.add(msg);
    if (recentLogs.length > 30) {
      recentLogs.removeAt(0);
    }
  }

  /// Advance simulation by one fixed tick (0.5 s).
  void tick() {
    if (isMatchOver) return;

    totalTicksElapsed += 1;
    const dt = Balance.combatTickSeconds; // 0.5 s

    // 1. Update active buffs and stun durations
    if (player.biraBuffDuration > 0) {
      player.biraBuffDuration = max(0.0, player.biraBuffDuration - dt);
    }
    if (player.salagBuffDuration > 0) {
      player.salagBuffDuration = max(0.0, player.salagBuffDuration - dt);
    }
    if (player.stunDuration > 0) {
      player.stunDuration = max(0.0, player.stunDuration - dt);
    }

    if (opponent.biraBuffDuration > 0) {
      opponent.biraBuffDuration = max(0.0, opponent.biraBuffDuration - dt);
    }
    if (opponent.salagBuffDuration > 0) {
      opponent.salagBuffDuration = max(0.0, opponent.salagBuffDuration - dt);
    }
    if (opponent.stunDuration > 0) {
      opponent.stunDuration = max(0.0, opponent.stunDuration - dt);
    }

    // 2. Passive Coach Gigil Fill (+1% per second = +0.5% per tick)
    coachGigil = min(100.0, coachGigil + (Balance.gigilPassivePerSecond * dt));

    // 3. Action Meters Progression
    if (!player.isStunned) {
      player.actionMeter += player.bilis / Balance.actionSpeedDivisor;
    }
    if (!opponent.isStunned) {
      opponent.actionMeter += opponent.bilis / Balance.actionSpeedDivisor;
    }

    // 4. Resolve Actions (whoever crosses action threshold strikes)
    if (player.actionMeter >= Balance.actionThreshold) {
      player.actionMeter -= Balance.actionThreshold;
      _executeStrike(attacker: player, defender: opponent);
      if (_checkMatchEnd()) return;
    }

    if (opponent.actionMeter >= Balance.actionThreshold) {
      opponent.actionMeter -= Balance.actionThreshold;
      _executeStrike(attacker: opponent, defender: player);
      if (_checkMatchEnd()) return;
    }

    // 5. Round Timer Tick
    roundTimeRemaining -= dt;
    if (roundTimeRemaining <= 0.0) {
      if (currentRound < totalRounds) {
        currentRound += 1;
        roundTimeRemaining = Balance.roundDurationSeconds;
        _addLog('--- ROUND $currentRound ---');
      } else {
        _endMatchByDecision();
      }
    }
  }

  StrikeResult _executeStrike({
    required Combatant attacker,
    required Combatant defender,
    double extraMultiplier = 1.0,
    bool forceCrit = false,
    bool isFinisher = false,
  }) {
    attacker.strikesAttempted += 1;

    // Normal hit roll only if not a Finisher
    if (!isFinisher) {
      final diff = attacker.diskarte - defender.effectiveSalag;
      final denom = attacker.diskarte + defender.effectiveSalag + 50.0;
      final hitChance = (0.5 + 0.4 * (diff / denom)).clamp(Balance.minHitChance, Balance.maxHitChance);

      final roll = rng.nextDouble();
      if (roll > hitChance) {
        // Missed strike
        attacker.comboCount = 0;
        final comment = missCommentary[rng.nextInt(missCommentary.length)];
        _addLog('${attacker.name}: $comment');
        final missResult = StrikeResult(
          outcome: StrikeOutcome.miss,
          damage: 0.0,
          commentary: comment,
        );
        onStrike?.call(attacker, defender, missResult);
        return missResult;
      }
    }

    // Landed strike
    attacker.strikesLanded += 1;
    attacker.comboCount += 1;
    if (attacker.comboCount > attacker.highestCombo) {
      attacker.highestCombo = attacker.comboCount;
    }

    // Puso Meter Boost (+20% per landed strike, unless it was a finisher)
    if (!isFinisher) {
      attacker.pusoMeter = min(100.0, attacker.pusoMeter + 20.0);
    }

    // Defender builds Gigil when hit (+5%)
    if (defender == player) {
      coachGigil = min(100.0, coachGigil + Balance.gigilPerHitTaken);
    }

    // Block Chance: D.salag / (D.salag + A.lakas + 40)
    double blockChance = defender.effectiveSalag /
        (defender.effectiveSalag + attacker.effectiveLakas + 40.0);
    if (defender.style == ArnisStyle.espadaYDaga) {
      blockChance += Balance.espadaExtraBlockChance;
    }
    final isBlocked = rng.nextDouble() < blockChance;
    if (isBlocked) {
      defender.strikesBlocked += 1;
    }

    // Weapon Multiplier
    double weaponMult = Balance.weaponSoloBastonMult;
    if (attacker.style == ArnisStyle.dobleBaston) {
      weaponMult = Balance.weaponDobleBastonMult;
    } else if (attacker.style == ArnisStyle.espadaYDaga) {
      weaponMult = Balance.weaponEspadaYDagaMult;
    }

    // Critical Chance: 5% + 0.05 * (diskarte / 10)% + traits
    final critTraitBonus = attacker.traits.contains('Palaban') ? 0.05 : 0.0;
    final critChance = 0.05 + 0.005 * (attacker.diskarte / 10.0) + critTraitBonus;
    final isCrit = forceCrit || (rng.nextDouble() < critChance);
    if (isCrit) {
      attacker.critsLanded += 1;
    }

    // Damage Formula (Section 9):
    // damage = A.lakas * weaponMult * moveMult * random(0.8, 1.2) * 0.35 * (crit ? 1.5 : 1)
    final variance = rng.rangeDouble(0.8, 1.2);
    double damage = attacker.effectiveLakas *
        weaponMult *
        extraMultiplier *
        variance *
        0.35 *
        (isCrit ? Balance.criticalMultiplier : 1.0);

    if (isBlocked) {
      damage *= Balance.blockDamageReduction;
    }

    // Doble Baston delivers a rapid second strike
    if (attacker.style == ArnisStyle.dobleBaston) {
      final secondVariance = rng.rangeDouble(0.8, 1.2);
      double secondHit = attacker.effectiveLakas *
          weaponMult *
          extraMultiplier *
          secondVariance *
          0.35 *
          (isCrit ? Balance.criticalMultiplier : 1.0);
      if (isBlocked) secondHit *= Balance.blockDamageReduction;
      damage += secondHit;
    }

    damage = max(1.0, damage);
    defender.currentHp = max(0.0, defender.currentHp - damage);

    attacker.totalDamageDealt += damage;
    if (damage > attacker.maxDamageSingleHit) {
      attacker.maxDamageSingleHit = damage;
    }

    // Generate Filipino commentary
    String commentary;
    if (isCrit) {
      commentary = critCommentary[rng.nextInt(critCommentary.length)];
    } else if (isBlocked) {
      commentary = blockCommentary[rng.nextInt(blockCommentary.length)];
    } else {
      commentary = hitCommentary[rng.nextInt(hitCommentary.length)];
    }
    _addLog('${attacker.name}: $commentary (-${damage.toStringAsFixed(1)} HP)');

    final result = StrikeResult(
      outcome: isCrit
          ? StrikeOutcome.criticalHit
          : (isBlocked ? StrikeOutcome.blocked : StrikeOutcome.hit),
      damage: damage,
      isCrit: isCrit,
      isBlocked: isBlocked,
      commentary: commentary,
    );
    onStrike?.call(attacker, defender, result);
    return result;
  }

  /// Coach Shouts
  bool canUseCoachCommand(CoachCommand cmd) {
    if (isMatchOver) return false;
    switch (cmd) {
      case CoachCommand.bira:
        return coachGigil >= Balance.costBira;
      case CoachCommand.salag:
        return coachGigil >= Balance.costSalag;
      case CoachCommand.diskarte:
        return coachGigil >= Balance.costDiskarte;
    }
  }

  bool useCoachCommand(CoachCommand cmd) {
    if (!canUseCoachCommand(cmd)) return false;

    switch (cmd) {
      case CoachCommand.bira:
        coachGigil -= Balance.costBira;
        player.biraBuffDuration = Balance.buffDurationSeconds;
        _addLog('COACH: "BIRA! Ibuhos ang buong lakas!" (+30% Lakas)');
        break;

      case CoachCommand.salag:
        coachGigil -= Balance.costSalag;
        player.salagBuffDuration = Balance.buffDurationSeconds;
        _addLog('COACH: "SALAG! Bantayan ang pwesto!" (+50% Salag)');
        break;

      case CoachCommand.diskarte:
        coachGigil -= Balance.costDiskarte;
        opponent.stunDuration = Balance.diskarteStunDurationSeconds;
        _addLog('COACH: "DISKARTE! Sabong Lock!" (Stunned ang kalaban 3s)');
        break;
    }
    return true;
  }

  /// Finisher Tap Execution (TAMAAN!)
  StrikeResult? resolveFinisherTap({required double tapOffset}) {
    if (player.pusoMeter < 100.0 || isMatchOver) return null;
    player.pusoMeter = 0.0;

    // [0.45..0.55] Bullseye -> 2.0x signature move + guaranteed crit
    // [0.30..0.70] Good zone -> 2.0x signature move
    // Outside -> Missed finisher
    if (tapOffset >= 0.45 && tapOffset <= 0.55) {
      _addLog('TAMAAN! PERPEKTONG TAMA SA GITNA!');
      return _executeStrike(
        attacker: player,
        defender: opponent,
        extraMultiplier: Balance.finisherDamageMultiplier,
        forceCrit: true,
        isFinisher: true,
      );
    } else if (tapOffset >= 0.30 && tapOffset <= 0.70) {
      _addLog('TAMAAN! Solidong Finisher Move!');
      return _executeStrike(
        attacker: player,
        defender: opponent,
        extraMultiplier: Balance.finisherDamageMultiplier,
        forceCrit: false,
        isFinisher: true,
      );
    } else {
      _addLog('TAMAAN: Sablay ang tiyempo ng finisher!');
      const missResult = StrikeResult(
        outcome: StrikeOutcome.miss,
        damage: 0.0,
        commentary: 'Sablay ang signature finisher!',
      );
      onStrike?.call(player, opponent, missResult);
      return missResult;
    }
  }

  bool _checkMatchEnd() {
    // 1. Knockout (KO)
    if (player.isKnockedOut) {
      _finishMatch(winner: opponent, loser: player, reason: MatchEndReason.knockout);
      return true;
    }
    if (opponent.isKnockedOut) {
      _finishMatch(winner: player, loser: opponent, reason: MatchEndReason.knockout);
      return true;
    }

    // 2. Referee Stoppage (TKO)
    // HP < 10% and opponent has at least 2x HP
    if (player.hpPercent < 0.10 && opponent.currentHp >= player.currentHp * 2.0) {
      _finishMatch(winner: opponent, loser: player, reason: MatchEndReason.refereeStoppage);
      return true;
    }
    if (opponent.hpPercent < 0.10 && player.currentHp >= opponent.currentHp * 2.0) {
      _finishMatch(winner: player, loser: opponent, reason: MatchEndReason.refereeStoppage);
      return true;
    }

    return false;
  }

  void _endMatchByDecision() {
    if (player.hpPercent > opponent.hpPercent) {
      _finishMatch(winner: player, loser: opponent, reason: MatchEndReason.decision);
    } else if (opponent.hpPercent > player.hpPercent) {
      _finishMatch(winner: opponent, loser: player, reason: MatchEndReason.decision);
    } else {
      // Tie-breaker: total damage dealt
      if (player.totalDamageDealt >= opponent.totalDamageDealt) {
        _finishMatch(winner: player, loser: opponent, reason: MatchEndReason.decision);
      } else {
        _finishMatch(winner: opponent, loser: player, reason: MatchEndReason.decision);
      }
    }
  }

  void _finishMatch({
    required Combatant winner,
    required Combatant loser,
    required MatchEndReason reason,
  }) {
    isMatchOver = true;
    this.winner = winner;
    this.loser = loser;
    endReason = reason;

    final reasonText = reason == MatchEndReason.knockout
        ? 'KNOCKOUT (KO)'
        : (reason == MatchEndReason.refereeStoppage ? 'REFEREE STOPPAGE' : 'UNANIMOUS DECISION');

    _addLog('TAPOS ANG LABAN! Nanalo si ${winner.name} via $reasonText!');
  }

  /// Run entire headless simulation to the end.
  MatchResult simulateEntireMatch() {
    while (!isMatchOver) {
      tick();
    }
    return MatchResult(
      winner: winner!,
      loser: loser!,
      endReason: endReason!,
      totalRoundsFought: currentRound,
      totalTicks: totalTicksElapsed,
      finalRoundTimeRemaining: roundTimeRemaining,
    );
  }
}
