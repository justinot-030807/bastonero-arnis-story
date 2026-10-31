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
  final void Function(bool playerWon, int maxDamage)? onMatchEnded;

  late ArenaComponent arena;
  late FighterComponent player;
  late FighterComponent opponent;

  // Match Status
  double matchTimer = 60.0;
  bool isMatchOver = false;
  bool isPlayerWinner = false;

  // Combo & Damage Tracking (Image 4 Art Style)
  int playerComboCount = 0;
  double comboTimer = 0.0;
  int highestDamageDealt = 0;

  // Coach Gigil / Aura Meter (0.0 to 100.0)
  double coachGigilMeter = 30.0;

  // Time Scale for dramatic slow-mo
  double timeScale = 1.0;

  // Clinch state
  bool isInClinchMiniGame = false;

  // Live Announcer Log History (Zero Emojis!)
  final List<String> announcerLogs = [
    'REFEREE: Handa na ang dalawang arnisador sa court!',
    'Simula ng Round 1!',
  ];

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

    arena = ArenaComponent(size: size, arenaType: arenaType);
    add(arena);

    final floorY = size.y * 0.78;
    final pX = size.x * 0.28;
    final oX = size.x * 0.72;

    player = FighterComponent(
      fighter: playerFighter,
      position: Vector2(pX, floorY),
      isFacingRight: true,
      headbandColor: const Color(0xFFDC2626), // Red Corner
      sandoColor: const Color(0xFF1E293B),
    );

    opponent = FighterComponent(
      fighter: opponentFighter,
      position: Vector2(oX, floorY),
      isFacingRight: false,
      headbandColor: const Color(0xFF2563EB), // Blue Corner
      sandoColor: const Color(0xFF334155),
    );

    player.opponent = opponent;
    opponent.opponent = player;

    player.onHitLanded = (attacker, damage, isCrit) {
      coachGigilMeter = (coachGigilMeter + 10.0).clamp(0.0, 100.0);
      if (damage.toInt() > highestDamageDealt) {
        highestDamageDealt = damage.toInt();
      }

      playerComboCount += 1;
      comboTimer = 2.4;

      // Floating Combo Banner (Image 4 Emulation)
      if (playerComboCount >= 2) {
        add(FloatingTextComponent(
          text: '$playerComboCount-Hit Combo!',
          position: Vector2(opponent.position.x - 35, opponent.position.y - 110),
          color: const Color(0xFFEF4444),
          fontSize: 15,
          upwardSpeed: 30,
        ));
        _addAnnouncerLog('$playerComboCount-Hit Combo mula kay ${playerFighter.name}!');
      }
    };

    opponent.onHitLanded = (attacker, damage, isCrit) {
      playerComboCount = 0;
    };

    player.onClinchTriggered = _handleClinchTriggered;
    opponent.onClinchTriggered = _handleClinchTriggered;

    player.onAnnouncerLog = _addAnnouncerLog;
    opponent.onAnnouncerLog = _addAnnouncerLog;

    add(player);
    add(opponent);

    _addOverlaySafely('matchHud');
  }

  void _addAnnouncerLog(String msg) {
    announcerLogs.add(msg);
    if (announcerLogs.length > 5) {
      announcerLogs.removeAt(0);
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

  void _handleClinchTriggered() {
    if (isInClinchMiniGame || isMatchOver) return;
    isInClinchMiniGame = true;

    timeScale = 0.15;
    _addOverlaySafely('timingMinigame');
  }

  void resolveClinchMiniGame({required bool isPerfect, required bool isSuccess}) {
    timeScale = 1.0;
    isInClinchMiniGame = false;
    _removeOverlaySafely('timingMinigame');

    if (isPerfect) {
      final moveName = playerFighter.style.signatureMove;
      final damage = player.combatPower * 2.2;

      opponent.receiveDamage(damage, isCrit: true, fromAttacker: player);
      opponent.disarm();

      add(FloatingTextComponent(
        text: '[$moveName! PERFECT]',
        position: Vector2(player.position.x - 30, player.position.y - 100),
        color: const Color(0xFFFDE047),
        fontSize: 15,
      ));

      _addAnnouncerLog('ASINTADO! Pambihirang $moveName! Disarmed ang kalaban!');
      coachGigilMeter = (coachGigilMeter + 25.0).clamp(0.0, 100.0);
    } else if (isSuccess) {
      final damage = player.combatPower * 1.3;
      opponent.receiveDamage(damage, isCrit: false, fromAttacker: player);

      add(FloatingTextComponent(
        text: '[ASINTADO! SOLID STRIKE]',
        position: Vector2(player.position.x - 20, player.position.y - 90),
        color: const Color(0xFF4ADE80),
        fontSize: 13,
      ));
      _addAnnouncerLog('Solidong counter attack mula kay ${player.fighter.name}!');
    } else {
      final counterDamage = opponent.combatPower * 1.2;
      player.receiveDamage(counterDamage, isCrit: false, fromAttacker: opponent);

      add(FloatingTextComponent(
        text: '[SABLAY! COUNTERED]',
        position: Vector2(player.position.x - 20, player.position.y - 90),
        color: const Color(0xFFDC2626),
        fontSize: 13,
      ));
      _addAnnouncerLog('Sablay ang strike! Nag-counter si ${opponent.fighter.name}!');
    }

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

    if (comboTimer > 0) {
      comboTimer -= scaledDt;
      if (comboTimer <= 0) {
        playerComboCount = 0;
      }
    }

    coachGigilMeter = (coachGigilMeter + (4.0 * scaledDt)).clamp(0.0, 100.0);

    matchTimer -= scaledDt;
    if (matchTimer <= 0) {
      matchTimer = 0;
      _endMatchByDecisions();
      return;
    }

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

    if (playerWon) {
      player.animState = FighterAnimState.victory;
      opponent.animState = FighterAnimState.knockdown;
    } else {
      player.animState = FighterAnimState.knockdown;
      opponent.animState = FighterAnimState.victory;
    }

    final resultText = playerWon ? '[PANALO! VICTORY]' : '[TALO! DEFEAT]';
    final resultColor = playerWon ? const Color(0xFF22C55E) : const Color(0xFFDC2626);

    add(FloatingTextComponent(
      text: resultText,
      position: Vector2(size.x * 0.5 - 70, size.y * 0.35),
      color: resultColor,
      fontSize: 20,
      upwardSpeed: 10,
    ));

    _addOverlaySafely('matchResult');
    onMatchEnded?.call(playerWon, highestDamageDealt);
  }
}
