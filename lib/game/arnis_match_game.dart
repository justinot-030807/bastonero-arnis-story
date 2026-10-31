import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/fighter_model.dart';
import '../models/tournament_model.dart';
import 'components/arena_component.dart';
import 'components/fighter_component.dart';
import 'components/floating_text.dart';

class ArnisMatchGame extends FlameGame {
  final FighterModel playerFighter;
  final FighterModel opponentFighter;
  final ArenaType arenaType;
  final TournamentModel? tournament;
  final void Function(bool playerWon)? onMatchEnded;

  late ArenaComponent arena;
  late FighterComponent player;
  late FighterComponent opponent;

  // Match Status
  double matchTimer = 60.0;
  bool isMatchOver = false;
  bool isPlayerWinner = false;

  // Coach Gigil / Aura Meter (0.0 to 100.0)
  double coachGigilMeter = 30.0;

  // Time Scale for dramatic slow-mo
  double timeScale = 1.0;

  // Clinch state
  bool isInClinchMiniGame = false;

  ArnisMatchGame({
    required this.playerFighter,
    required this.opponentFighter,
    this.arenaType = ArenaType.purokLupa,
    this.tournament,
    this.onMatchEnded,
  });

  @override
  Color backgroundColor() => const Color(0xFF0F172A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Arena Background
    arena = ArenaComponent(size: size, arenaType: arenaType);
    add(arena);

    // 2. Positions
    final floorY = size.y * 0.78;
    final pX = size.x * 0.28;
    final oX = size.x * 0.72;

    // 3. Player Fighter
    player = FighterComponent(
      fighter: playerFighter,
      position: Vector2(pX, floorY),
      isFacingRight: true,
      headbandColor: const Color(0xFFDC2626), // Red Corner
      sandoColor: const Color(0xFF1E293B),
    );

    // 4. Opponent Fighter
    opponent = FighterComponent(
      fighter: opponentFighter,
      position: Vector2(oX, floorY),
      isFacingRight: false,
      headbandColor: const Color(0xFF2563EB), // Blue Corner
      sandoColor: const Color(0xFF334155),
    );

    // Wire mutual references
    player.opponent = opponent;
    opponent.opponent = player;

    // Wire Callbacks
    player.onHitLanded = (attacker, damage, isCrit) {
      coachGigilMeter = (coachGigilMeter + 10.0).clamp(0.0, 100.0);
    };

    player.onClinchTriggered = _handleClinchTriggered;
    opponent.onClinchTriggered = _handleClinchTriggered;

    add(player);
    add(opponent);

    // Show initial Match HUD overlay safely
    _addOverlaySafely('matchHud');
  }

  void _addOverlaySafely(String name) {
    try {
      overlays.add(name);
    } catch (_) {
      // In headless testing without GameWidget overlay builders, ignore
    }
  }

  void _removeOverlaySafely(String name) {
    try {
      overlays.remove(name);
    } catch (_) {
      // In headless testing, ignore
    }
  }

  void _handleClinchTriggered() {
    if (isInClinchMiniGame || isMatchOver) return;
    isInClinchMiniGame = true;

    // Dramatic slow motion
    timeScale = 0.15;

    // Trigger Timing Mini-game Overlay
    _addOverlaySafely('timingMinigame');
  }

  // Mini-Game Result Callback called from Flutter Overlay
  void resolveClinchMiniGame({required bool isPerfect, required bool isSuccess}) {
    timeScale = 1.0;
    isInClinchMiniGame = false;
    _removeOverlaySafely('timingMinigame');

    if (isPerfect) {
      // Cinematic Signature Move Execution!
      final moveName = playerFighter.style.signatureMove;
      final damage = player.combatPower * 2.2;

      opponent.receiveDamage(damage, isCrit: true, fromAttacker: player);
      opponent.disarm();

      add(FloatingTextComponent(
        text: '🔥 $moveName! 🔥',
        position: Vector2(player.position.x - 30, player.position.y - 100),
        color: const Color(0xFFFFD700),
        fontSize: 16,
      ));

      coachGigilMeter = (coachGigilMeter + 25.0).clamp(0.0, 100.0);
    } else if (isSuccess) {
      // Good hit
      final damage = player.combatPower * 1.3;
      opponent.receiveDamage(damage, isCrit: false, fromAttacker: player);

      add(FloatingTextComponent(
        text: 'ASINTADO! Solid Counter Strike!',
        position: Vector2(player.position.x - 20, player.position.y - 90),
        color: const Color(0xFF4ADE80),
        fontSize: 14,
      ));
    } else {
      // Miss: Countered by opponent
      final counterDamage = opponent.combatPower * 1.2;
      player.receiveDamage(counterDamage, isCrit: false, fromAttacker: opponent);

      add(FloatingTextComponent(
        text: 'SABLAY! Countered!',
        position: Vector2(player.position.x - 20, player.position.y - 90),
        color: const Color(0xFFF87171),
        fontSize: 14,
      ));
    }

    // Reset fighters back to idle
    player.animState = FighterAnimState.idle;
    opponent.animState = FighterAnimState.idle;
  }

  // COACH SHOUT COMMANDS
  bool shoutBira() {
    if (coachGigilMeter < 35.0 || isMatchOver) return false;
    coachGigilMeter -= 35.0;
    player.applyBira();
    return true;
  }

  bool shoutSalag() {
    if (coachGigilMeter < 30.0 || isMatchOver) return false;
    coachGigilMeter -= 30.0;
    player.applySalag();
    return true;
  }

  bool shoutDiskarte() {
    if (coachGigilMeter < 45.0 || isMatchOver) return false;
    coachGigilMeter -= 45.0;
    player.applyDiskarte();
    return true;
  }

  @override
  void update(double dt) {
    final scaledDt = dt * timeScale;
    super.update(scaledDt);

    if (isMatchOver) return;

    // Passive gigil charge
    coachGigilMeter = (coachGigilMeter + (4.0 * scaledDt)).clamp(0.0, 100.0);

    // Round countdown
    matchTimer -= scaledDt;
    if (matchTimer <= 0) {
      matchTimer = 0;
      _endMatchByDecisions();
      return;
    }

    // Check KO
    if (player.currentHp <= 0) {
      _endMatch(playerWon: false);
    } else if (opponent.currentHp <= 0) {
      _endMatch(playerWon: true);
    }
  }

  void _endMatchByDecisions() {
    final playerHpRatio = player.currentHp / player.fighter.maxHp;
    final opponentHpRatio = opponent.currentHp / opponent.fighter.maxHp;
    _endMatch(playerWon: playerHpRatio >= opponentHpRatio);
  }

  void _endMatch({required bool playerWon}) {
    if (isMatchOver) return;
    isMatchOver = true;
    isPlayerWinner = playerWon;

    final resultText = playerWon ? 'PANALO! (VICTORY)' : 'TALO (DEFEAT)';
    final resultColor = playerWon ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    add(FloatingTextComponent(
      text: resultText,
      position: Vector2(size.x * 0.5 - 70, size.y * 0.35),
      color: resultColor,
      fontSize: 22,
      upwardSpeed: 10,
    ));

    _addOverlaySafely('matchResult');
    onMatchEnded?.call(playerWon);
  }
}
