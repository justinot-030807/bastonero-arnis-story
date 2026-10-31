import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../domain/match_engine.dart';
import '../domain/models/student.dart';
import '../models/fighter_model.dart';
import '../models/tournament_model.dart';
import 'components/arena_component.dart';
import 'components/fighter_component.dart';
import 'components/floating_text.dart';

class ArnisMatchGame extends FlameGame {
  final FighterModel playerFighter;
  final FighterModel opponentFighter;
  final Student? playerStudent;
  final Student? opponentStudent;
  final ArenaType arenaType;
  final TournamentModel? tournament;
  final void Function(bool playerWon, int maxDamage)? onMatchEnded;
  final int? _seed;

  late final MatchEngine engine;
  late ArenaComponent arena;
  late FighterComponent player;
  late FighterComponent opponent;

  // Match Status
  bool isMatchOver = false;
  bool isPlayerWinner = false;

  double get matchTimer => engine.roundTimeRemaining;
  set matchTimer(double val) {
    engine.roundTimeRemaining = val;
  }

  // Combo & Damage Tracking
  int playerComboCount = 0;
  int highestDamageDealt = 0;

  // Coach Gigil / Aura Meter (0.0 to 100.0)
  double get coachGigilMeter => engine.coachGigil;
  set coachGigilMeter(double val) {
    engine.coachGigil = val.clamp(0.0, 100.0);
  }

  // Time Scale for dramatic slow-mo & Finisher Tap
  double timeScale = 1.0;
  double _cameraShake = 0.0;
  double _koSlowdownTimer = 0.0;
  bool _hasTriggeredResultOverlay = false;

  // Finisher Tap state (TAMAAN!)
  bool isInFinisherTap = false;
  double _simTimer = 0.0;

  // Live Announcer Log History (Zero Emojis!)
  final List<String> announcerLogs = [
    'REFEREE: Handa na ang dalawang arnisador sa court!',
    'Simula ng Round 1!',
  ];

  ArnisMatchGame({
    required this.playerFighter,
    required this.opponentFighter,
    this.playerStudent,
    this.opponentStudent,
    this.arenaType = ArenaType.purokLupa,
    this.tournament,
    this.onMatchEnded,
    int? seed,
  }) : _seed = seed;

  static ArnisStyle _convertStyle(FighterStyle style) {
    switch (style) {
      case FighterStyle.soloBaston:
        return ArnisStyle.soloBaston;
      case FighterStyle.dobleBaston:
        return ArnisStyle.dobleBaston;
      case FighterStyle.espadaYDaga:
        return ArnisStyle.espadaYDaga;
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF0F172A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Initialize Arena Component
    arena = ArenaComponent(size: size, arenaType: arenaType);
    add(arena);

    final topBound = 85.0;
    final bottomBound = size.y - 215.0;
    final arenaCenterY = topBound + (bottomBound - topBound) * 0.50;
    final arenaCenterX = size.x * 0.5;

    final floorY = arenaCenterY + 14.0;
    final pX = arenaCenterX - 45.0;
    final oX = arenaCenterX + 45.0;

    // 2. Initialize Visual Fighter Components
    player = FighterComponent(
      fighter: playerFighter,
      position: Vector2(pX, floorY),
      isFacingRight: true,
      headbandColor: const Color(0xFFDC2626), // Red Corner
      sandoColor: const Color(0xFF1E293B),
    );
    player.isDrivenByEngine = true;

    opponent = FighterComponent(
      fighter: opponentFighter,
      position: Vector2(oX, floorY),
      isFacingRight: false,
      headbandColor: const Color(0xFF2563EB), // Blue Corner
      sandoColor: const Color(0xFF334155),
    );
    opponent.isDrivenByEngine = true;

    player.opponent = opponent;
    opponent.opponent = player;

    add(player);
    add(opponent);

    // 3. Initialize Pure Dart Deterministic MatchEngine
    final pCombatant = playerStudent != null
        ? Combatant.fromStudent(playerStudent!)
        : Combatant(
            id: 'player',
            name: playerFighter.name,
            maxHp: playerFighter.maxHp,
            currentHp: playerFighter.hp,
            lakas: playerFighter.effectivePower,
            bilis: playerFighter.effectiveSpeed,
            diskarte: playerFighter.effectiveTechnique,
            salag: playerFighter.effectiveDefense,
            style: _convertStyle(playerFighter.style),
            moves: [playerFighter.style.signatureMove],
          );

    final oCombatant = opponentStudent != null
        ? Combatant.fromStudent(opponentStudent!)
        : Combatant(
            id: 'opponent',
            name: opponentFighter.name,
            maxHp: opponentFighter.maxHp,
            currentHp: opponentFighter.hp,
            lakas: opponentFighter.effectivePower,
            bilis: opponentFighter.effectiveSpeed,
            diskarte: opponentFighter.effectiveTechnique,
            salag: opponentFighter.effectiveDefense,
            style: _convertStyle(opponentFighter.style),
            moves: [opponentFighter.style.signatureMove],
          );

    final isElementary = (tournament?.minGradeLevel != null && tournament!.minGradeLevel <= 6) ||
        (playerStudent != null && playerStudent!.grade <= 6 && playerStudent!.grade > 0);
    final totalRounds = isElementary ? 2 : 3;

    engine = MatchEngine(
      player: pCombatant,
      opponent: oCombatant,
      totalRounds: totalRounds,
      seed: _seed,
    );

    engine.onStrike = _handleEngineStrike;

    _addOverlaySafely('matchHud');
  }

  void _handleEngineStrike(Combatant attacker, Combatant defender, StrikeResult result) {
    if (attacker == engine.player) {
      player.performVisualStrike(isSpecial: result.isCrit);

      if (result.outcome == StrikeOutcome.miss) {
        opponent.dodgeGhostPos = opponent.position.clone();
        opponent.dodgeGhostOpacity = 0.7;
        add(FloatingTextComponent(
          text: '[IWAS! MISS]',
          position: opponent.position + Vector2(-15, -70),
          color: const Color(0xFF4ADE80),
          fontSize: 11,
        ));
      } else if (result.outcome == StrikeOutcome.blocked) {
        opponent.performVisualBlock();
        opponent.currentHp = engine.opponent.currentHp;
        add(FloatingTextComponent(
          text: '[SALAG! -${result.damage.toInt()}]',
          position: opponent.position + Vector2(-15, -70),
          color: const Color(0xFF38BDF8),
          fontSize: 11,
        ));
      } else {
        opponent.currentHp = engine.opponent.currentHp;
        opponent.animState = FighterAnimState.hitStun;
        opponent.hitStunTimer = result.isCrit ? 0.35 : 0.20;

        if (result.isCrit) {
          _cameraShake = 0.30;
        }

        final displayText = result.isCrit ? '[LAKAS!] -${result.damage.toInt()}' : '-${result.damage.toInt()}';
        final textColor = result.isCrit ? const Color(0xFFDC2626) : const Color(0xFFF4B41B);

        add(FloatingTextComponent(
          text: displayText,
          position: opponent.position + Vector2(-15, -75),
          color: textColor,
          fontSize: result.isCrit ? 15 : 12,
          upwardSpeed: result.isCrit ? 60 : 40,
        ));

        if (engine.player.comboCount >= 2) {
          add(FloatingTextComponent(
            text: '${engine.player.comboCount}-Hit Combo!',
            position: Vector2(opponent.position.x - 35, opponent.position.y - 110),
            color: const Color(0xFFEF4444),
            fontSize: 15,
            upwardSpeed: 30,
          ));
        }
      }
    } else {
      opponent.performVisualStrike(isSpecial: result.isCrit);

      if (result.outcome == StrikeOutcome.miss) {
        player.dodgeGhostPos = player.position.clone();
        player.dodgeGhostOpacity = 0.7;
        add(FloatingTextComponent(
          text: '[IWAS! MISS]',
          position: player.position + Vector2(-15, -70),
          color: const Color(0xFF4ADE80),
          fontSize: 11,
        ));
      } else if (result.outcome == StrikeOutcome.blocked) {
        player.performVisualBlock();
        player.currentHp = engine.player.currentHp;
        add(FloatingTextComponent(
          text: '[SALAG! -${result.damage.toInt()}]',
          position: player.position + Vector2(-15, -70),
          color: const Color(0xFF38BDF8),
          fontSize: 11,
        ));
      } else {
        player.currentHp = engine.player.currentHp;
        player.animState = FighterAnimState.hitStun;
        player.hitStunTimer = result.isCrit ? 0.35 : 0.20;

        if (result.isCrit) {
          _cameraShake = 0.25;
        }

        final displayText = result.isCrit ? '[ARAY!] -${result.damage.toInt()}' : '-${result.damage.toInt()}';
        add(FloatingTextComponent(
          text: displayText,
          position: player.position + Vector2(-15, -75),
          color: const Color(0xFFDC2626),
          fontSize: 12,
          upwardSpeed: 40,
        ));
      }
    }

    _syncFromEngine();
  }

  void _syncFromEngine() {
    matchTimer = engine.roundTimeRemaining;
    coachGigilMeter = engine.coachGigil;
    playerComboCount = engine.player.comboCount;
    if (engine.player.maxDamageSingleHit.toInt() > highestDamageDealt) {
      highestDamageDealt = engine.player.maxDamageSingleHit.toInt();
    }

    // Sync announcer logs
    if (engine.recentLogs.isNotEmpty) {
      final latest = engine.recentLogs.last;
      if (announcerLogs.isEmpty || announcerLogs.last != latest) {
        announcerLogs.add(latest);
        if (announcerLogs.length > 6) {
          announcerLogs.removeAt(0);
        }
      }
    }
  }

  void _addOverlaySafely(String name) {
    try {
      overlays.add(name);
    } catch (_) {}
  }

  void _removeOverlaySafely(String name) {
    try {
      overlays.remove(name);
    } catch (_) {}
  }

  // FINISHER TAP PROMPT (TAMAAN!)
  void _triggerFinisherTap() {
    if (isInFinisherTap || isMatchOver) return;
    isInFinisherTap = true;
    timeScale = 0.15;
    _addOverlaySafely('timingMinigame');
  }

  void resolveFinisherTap({required double tapOffset}) {
    timeScale = 1.0;
    isInFinisherTap = false;
    _removeOverlaySafely('timingMinigame');

    final result = engine.resolveFinisherTap(tapOffset: tapOffset);
    if (result != null && result.damage > 0) {
      _cameraShake = 0.45;
      final signature = playerFighter.style.signatureMove;
      add(FloatingTextComponent(
        text: '[$signature! ${result.isCrit ? "PERFECT" : "SOLID"}]',
        position: Vector2(player.position.x - 30, player.position.y - 100),
        color: const Color(0xFFFDE047),
        fontSize: 16,
      ));
    } else {
      add(FloatingTextComponent(
        text: '[SABLAY! MOVE WASTED]',
        position: Vector2(player.position.x - 20, player.position.y - 90),
        color: const Color(0xFFDC2626),
        fontSize: 13,
      ));
    }

    _syncFromEngine();
    if (engine.isMatchOver) {
      _handleMatchFinished();
    }
  }

  void resolveClinchMiniGame({required bool isPerfect, required bool isSuccess}) {
    if (isPerfect) {
      engine.player.pusoMeter = 100.0;
      resolveFinisherTap(tapOffset: 0.50);
      opponent.isDisarmed = true;
    } else if (isSuccess) {
      engine.player.pusoMeter = 100.0;
      resolveFinisherTap(tapOffset: 0.35);
    } else {
      resolveFinisherTap(tapOffset: 0.10);
    }
  }

  // COACH SHOUT COMMANDS
  bool shoutBira() {
    if (isMatchOver) return false;
    final success = engine.useCoachCommand(CoachCommand.bira);
    if (success) {
      player.applyBira();
      _syncFromEngine();
    }
    return success;
  }

  bool shoutSalag() {
    if (isMatchOver) return false;
    final success = engine.useCoachCommand(CoachCommand.salag);
    if (success) {
      player.applySalag();
      _syncFromEngine();
    }
    return success;
  }

  bool shoutDiskarte() {
    if (isMatchOver) return false;
    final success = engine.useCoachCommand(CoachCommand.diskarte);
    if (success) {
      player.applyDiskarte();
      opponent.animState = FighterAnimState.hitStun;
      opponent.hitStunTimer = 3.0;
      _syncFromEngine();
    }
    return success;
  }

  @override
  void update(double dt) {
    // Camera shake handling
    if (_cameraShake > 0) {
      _cameraShake -= dt;
      arena.position.x = sin(_cameraShake * 60) * 4.0;
      arena.position.y = cos(_cameraShake * 60) * 4.0;
      if (_cameraShake <= 0) {
        arena.position.setZero();
      }
    }

    final scaledDt = dt * timeScale;
    super.update(scaledDt);

    // KO slow-down timer
    if (_koSlowdownTimer > 0) {
      _koSlowdownTimer -= dt;
      if (_koSlowdownTimer <= 0 && !_hasTriggeredResultOverlay) {
        _hasTriggeredResultOverlay = true;
        timeScale = 1.0;
        _addOverlaySafely('matchResult');
        onMatchEnded?.call(isPlayerWinner, highestDamageDealt);
      }
      return;
    }

    if (isMatchOver || isInFinisherTap) return;

    // Simulation stepping (0.5 s per tick)
    _simTimer += scaledDt;
    while (_simTimer >= 0.5 && !engine.isMatchOver) {
      _simTimer -= 0.5;
      engine.tick();
      _syncFromEngine();

      // Trigger Finisher Tap when Puso meter reaches 100%
      if (engine.player.pusoMeter >= 100.0 && !isInFinisherTap) {
        _triggerFinisherTap();
        break;
      }

      if (engine.isMatchOver) {
        _handleMatchFinished();
        break;
      }
    }
  }

  void _handleMatchFinished() {
    if (isMatchOver) return;
    isMatchOver = true;
    isPlayerWinner = engine.winner == engine.player;

    // Dramatic 1-second KO slowdown
    timeScale = 0.2;
    _koSlowdownTimer = 0.25; // 0.25 in real time when timeScale is 0.2 ≈ 1.25s

    if (isPlayerWinner) {
      player.animState = FighterAnimState.victory;
      opponent.animState = FighterAnimState.knockdown;
    } else {
      player.animState = FighterAnimState.knockdown;
      opponent.animState = FighterAnimState.victory;
    }

    final reasonText = engine.endReason == MatchEndReason.knockout
        ? 'KO'
        : (engine.endReason == MatchEndReason.refereeStoppage ? 'TKO' : 'DECISION');
    final resultText = isPlayerWinner ? '[PANALO! $reasonText]' : '[TALO! $reasonText]';
    final resultColor = isPlayerWinner ? const Color(0xFF22C55E) : const Color(0xFFDC2626);

    add(FloatingTextComponent(
      text: resultText,
      position: Vector2(size.x * 0.5 - 70, size.y * 0.35),
      color: resultColor,
      fontSize: 20,
      upwardSpeed: 10,
    ));
  }
}
