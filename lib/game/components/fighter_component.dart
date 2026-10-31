import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/fighter_model.dart';
import 'floating_text.dart';

enum FighterAnimState {
  idle,
  stepping,
  striking,
  blocking,
  hitStun,
  clinch,
}

class FighterComponent extends PositionComponent {
  final FighterModel fighter;
  final bool isFacingRight;
  final Color headbandColor;
  final Color sandoColor;

  // Combat State
  FighterAnimState animState = FighterAnimState.idle;
  double currentHp;
  double currentStamina;
  double strikeCooldown = 0.0;
  double animTimer = 0.0;
  double hitStunTimer = 0.0;
  double strikeProgress = 0.0;

  // Aura states from Coach Commands
  bool hasBiraAura = false;
  double biraTimer = 0.0;

  bool hasSalagAura = false;
  double salagTimer = 0.0;

  bool hasDiskarteAura = false;
  double diskarteTimer = 0.0;

  bool isDisarmed = false;
  double disarmTimer = 0.0;

  // Reference to opponent
  FighterComponent? opponent;

  // Callbacks to Game
  void Function(FighterComponent attacker, double damage, bool isCrit)? onHitLanded;
  void Function()? onClinchTriggered;

  FighterComponent({
    required this.fighter,
    required Vector2 position,
    required this.isFacingRight,
    this.headbandColor = const Color(0xFFEF4444),
    this.sandoColor = const Color(0xFF1E293B),
  })  : currentHp = fighter.hp,
        currentStamina = fighter.stamina,
        super(position: position, size: Vector2(48, 80), priority: 10, anchor: Anchor.bottomCenter);

  // Computed combat stats taking aura into account
  double get combatPower {
    double p = fighter.effectivePower;
    if (hasBiraAura) p *= 1.30;
    if (isDisarmed) p *= 0.50;
    return p;
  }

  double get combatSpeed {
    double s = fighter.effectiveSpeed;
    if (hasBiraAura) s *= 1.30;
    return s;
  }

  double get combatTechnique {
    double t = fighter.effectiveTechnique;
    if (hasDiskarteAura) t *= 1.40;
    return t;
  }

  double get combatDefense {
    double d = fighter.effectiveDefense;
    if (hasSalagAura) d *= 1.50;
    return d;
  }

  // Activate Coach Auras
  void applyBira() {
    hasBiraAura = true;
    biraTimer = 5.0;
    parent?.add(FloatingTextComponent(
      text: 'BIRA! (+30% Lakas & Bilis)',
      position: position + Vector2(-30, -90),
      color: const Color(0xFFF97316),
      fontSize: 13,
    ));
  }

  void applySalag() {
    hasSalagAura = true;
    salagTimer = 5.0;
    animState = FighterAnimState.blocking;
    parent?.add(FloatingTextComponent(
      text: 'SALAG! (+50% Depensa)',
      position: position + Vector2(-30, -90),
      color: const Color(0xFF38BDF8),
      fontSize: 13,
    ));
  }

  void applyDiskarte() {
    hasDiskarteAura = true;
    diskarteTimer = 5.0;
    parent?.add(FloatingTextComponent(
      text: 'DISKARTE! (Counter Focus)',
      position: position + Vector2(-30, -90),
      color: const Color(0xFFEAB308),
      fontSize: 13,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    animTimer += dt;

    // Update Auras
    if (hasBiraAura) {
      biraTimer -= dt;
      if (biraTimer <= 0) hasBiraAura = false;
    }
    if (hasSalagAura) {
      salagTimer -= dt;
      if (salagTimer <= 0) hasSalagAura = false;
    }
    if (hasDiskarteAura) {
      diskarteTimer -= dt;
      if (diskarteTimer <= 0) hasDiskarteAura = false;
    }
    if (isDisarmed) {
      disarmTimer -= dt;
      if (disarmTimer <= 0) isDisarmed = false;
    }

    // Hit stun timer
    if (hitStunTimer > 0) {
      hitStunTimer -= dt;
      if (hitStunTimer <= 0) {
        animState = FighterAnimState.idle;
      }
      return; // stun freezes action
    }

    // Strike progress
    if (animState == FighterAnimState.striking) {
      strikeProgress += dt * 4.0;
      if (strikeProgress >= 1.0) {
        strikeProgress = 0.0;
        animState = FighterAnimState.idle;
      }
      return;
    }

    // Clinch state
    if (animState == FighterAnimState.clinch) {
      return; // handled by mini-game
    }

    // AI & Auto-battler logic
    strikeCooldown -= dt;
    _runAutoBattlerAI(dt);
  }

  void _runAutoBattlerAI(double dt) {
    if (opponent == null || currentHp <= 0 || opponent!.currentHp <= 0) return;

    final targetX = opponent!.position.x;
    final currentX = position.x;
    final distance = (targetX - currentX).abs();
    const strikeRange = 64.0;

    // In diskarte aura or close clash, chance to clinch
    if (hasDiskarteAura && distance <= strikeRange + 10) {
      triggerClinch();
      return;
    }

    // Distance positioning
    if (distance > strikeRange + 10) {
      // Step closer
      final dir = targetX > currentX ? 1.0 : -1.0;
      final stepSpeed = (35.0 + combatSpeed * 1.8);
      position.x += dir * stepSpeed * dt;
      animState = FighterAnimState.stepping;
    } else if (distance < strikeRange - 16) {
      // Too close, retreat slightly
      final dir = targetX > currentX ? -1.0 : 1.0;
      position.x += dir * 25.0 * dt;
      animState = FighterAnimState.stepping;
    } else {
      // In combat sweet spot
      if (strikeCooldown <= 0) {
        _attemptStrikeOrDefense();
      } else {
        if (animState != FighterAnimState.blocking) {
          animState = FighterAnimState.idle;
        }
      }
    }
  }

  void _attemptStrikeOrDefense() {
    if (opponent == null) return;
    final rnd = Random();

    // Roll for defense stance if opponent is currently striking
    if (opponent!.animState == FighterAnimState.striking && rnd.nextDouble() < (combatDefense / 60.0)) {
      animState = FighterAnimState.blocking;
      strikeCooldown = 0.35;
      return;
    }

    // Roll to Strike
    animState = FighterAnimState.striking;
    strikeProgress = 0.0;
    // Attack speed formula: higher speed = shorter cooldown
    final attackInterval = (1.4 - (combatSpeed * 0.025)).clamp(0.40, 1.30);
    strikeCooldown = attackInterval;

    // Check if opponent also strikes simultaneously (Stick Sabong / Clash!)
    if (opponent!.animState == FighterAnimState.striking && rnd.nextDouble() < 0.28) {
      triggerClinch();
      return;
    }

    // Execute Strike against Opponent
    _executeStrike();
  }

  void _executeStrike() {
    if (opponent == null) return;
    final rnd = Random();

    final hitRoll = rnd.nextDouble() * 100.0;
    final opponentDodge = opponent!.combatSpeed * 0.6;

    if (hitRoll < opponentDodge) {
      // Opponent Dodged!
      opponent!.parent?.add(FloatingTextComponent(
        text: 'IWAS! (Dodge)',
        position: opponent!.position + Vector2(-15, -70),
        color: const Color(0xFF6EE7B7),
        fontSize: 12,
      ));
      return;
    }

    // Opponent Block Check
    if (opponent!.animState == FighterAnimState.blocking ||
        (opponent!.hasSalagAura) ||
        (rnd.nextDouble() < (opponent!.combatDefense / 85.0))) {
      opponent!.parent?.add(FloatingTextComponent(
        text: 'SALAG! (Block)',
        position: opponent!.position + Vector2(-15, -70),
        color: const Color(0xFF93C5FD),
        fontSize: 12,
      ));

      // Heavily mitigated chip damage
      final chipDamage = max(1.0, (combatPower * 0.15) - (opponent!.combatDefense * 0.1));
      opponent!.receiveDamage(chipDamage, isCrit: false, fromAttacker: this);
      return;
    }

    // Regular or Critical Hit
    final critChance = (combatTechnique / 75.0).clamp(0.05, 0.45);
    final isCrit = rnd.nextDouble() < critChance;

    double damage = combatPower * (isCrit ? 1.75 : 1.0) + (rnd.nextDouble() * 4.0);
    damage = max(3.0, damage - (opponent!.combatDefense * 0.3));

    opponent!.receiveDamage(damage, isCrit: isCrit, fromAttacker: this);
  }

  void receiveDamage(double damage, {required bool isCrit, required FighterComponent fromAttacker}) {
    currentHp = (currentHp - damage).clamp(0.0, fighter.maxHp);
    hitStunTimer = isCrit ? 0.35 : 0.20;
    animState = FighterAnimState.hitStun;

    // Knockback
    final knockDir = position.x > fromAttacker.position.x ? 1.0 : -1.0;
    position.x += knockDir * (isCrit ? 18.0 : 8.0);

    // Floating text
    final displayText = isCrit ? 'LAKAS! -${damage.toStringAsFixed(0)}' : '-${damage.toStringAsFixed(0)}';
    final textColor = isCrit ? const Color(0xFFEF4444) : const Color(0xFFFBBF24);

    parent?.add(FloatingTextComponent(
      text: displayText,
      position: position + Vector2(-15, -75),
      color: textColor,
      fontSize: isCrit ? 16 : 13,
      upwardSpeed: isCrit ? 65 : 45,
    ));

    onHitLanded?.call(fromAttacker, damage, isCrit);
  }

  void triggerClinch() {
    animState = FighterAnimState.clinch;
    if (opponent != null) {
      opponent!.animState = FighterAnimState.clinch;
    }
    parent?.add(FloatingTextComponent(
      text: '⚡ SABONG! (STICK LOCK) ⚡',
      position: Vector2((position.x + (opponent?.position.x ?? position.x)) / 2 - 40, position.y - 85),
      color: const Color(0xFFFDE047),
      fontSize: 14,
    ));
    onClinchTriggered?.call();
  }

  void disarm() {
    isDisarmed = true;
    disarmTimer = 6.0;
    parent?.add(FloatingTextComponent(
      text: 'AGAW-BASTON! (DISARMED -50% DMG)',
      position: position + Vector2(-40, -95),
      color: const Color(0xFFF43F5E),
      fontSize: 13,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    // Flip horizontally if facing left
    if (!isFacingRight) {
      canvas.scale(-1, 1);
      canvas.translate(-size.x, 0);
    }

    _renderAuras(canvas);
    _renderProceduralPixelFighter(canvas);

    canvas.restore();
  }

  void _renderAuras(Canvas canvas) {
    if (hasBiraAura) {
      final biraPaint = Paint()
        ..color = const Color(0x66FF5722)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.5), width: size.x + 22, height: size.y + 16),
        biraPaint,
      );
    }

    if (hasSalagAura) {
      final salagPaint = Paint()
        ..color = const Color(0x660284C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.5), size.y * 0.52, salagPaint);
    }

    if (hasDiskarteAura) {
      final diskartePaint = Paint()
        ..color = const Color(0x77EAB308)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.5), width: size.x + 16, height: size.y + 12),
        diskartePaint,
      );
    }
  }

  void _renderProceduralPixelFighter(Canvas canvas) {
    // Breathing idle offset
    double bounceY = 0;
    if (animState == FighterAnimState.idle) {
      bounceY = sin(animTimer * 5.0) * 1.5;
    } else if (animState == FighterAnimState.stepping) {
      bounceY = sin(animTimer * 12.0) * 3.0;
    } else if (animState == FighterAnimState.hitStun) {
      bounceY = (Random().nextDouble() - 0.5) * 4.0;
    }

    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final skinPaint = Paint()
      ..color = animState == FighterAnimState.hitStun
          ? const Color(0xFFFF6B6B)
          : const Color(0xFFD49B6A); // Warm Filipino skin tone

    // 1. LEGS & FOOTWEAR
    final pantsPaint = Paint()..color = const Color(0xFF1E293B);
    final shoePaint = Paint()..color = const Color(0xFFDC2626);

    // Left leg
    canvas.drawRect(Rect.fromLTWH(12, 54 + bounceY, 8, 20), pantsPaint);
    canvas.drawRect(Rect.fromLTWH(12, 54 + bounceY, 8, 20), outlinePaint);
    canvas.drawRect(Rect.fromLTWH(10, 72 + bounceY, 12, 6), shoePaint);
    canvas.drawRect(Rect.fromLTWH(10, 72 + bounceY, 12, 6), outlinePaint);

    // Right leg
    canvas.drawRect(Rect.fromLTWH(26, 54 + bounceY, 8, 20), pantsPaint);
    canvas.drawRect(Rect.fromLTWH(26, 54 + bounceY, 8, 20), outlinePaint);
    canvas.drawRect(Rect.fromLTWH(26, 72 + bounceY, 12, 6), shoePaint);
    canvas.drawRect(Rect.fromLTWH(26, 72 + bounceY, 12, 6), outlinePaint);

    // 2. TORSO & SANDO / ARMOR
    final bodyPaint = Paint()..color = sandoColor;
    canvas.drawRect(Rect.fromLTWH(13, 26 + bounceY, 22, 28), bodyPaint);
    canvas.drawRect(Rect.fromLTWH(13, 26 + bounceY, 22, 28), outlinePaint);

    // Red/Blue sash or belt
    final beltPaint = Paint()..color = headbandColor;
    canvas.drawRect(Rect.fromLTWH(12, 48 + bounceY, 24, 6), beltPaint);
    canvas.drawRect(Rect.fromLTWH(12, 48 + bounceY, 24, 6), outlinePaint);

    // 3. HEAD & HEADBAND
    // Neck
    canvas.drawRect(Rect.fromLTWH(21, 20 + bounceY, 6, 8), skinPaint);

    // Head
    canvas.drawRect(Rect.fromLTWH(14, 4 + bounceY, 20, 18), skinPaint);
    canvas.drawRect(Rect.fromLTWH(14, 4 + bounceY, 20, 18), outlinePaint);

    // Dark Hair
    final hairPaint = Paint()..color = const Color(0xFF171717);
    canvas.drawRect(Rect.fromLTWH(13, 2 + bounceY, 22, 7), hairPaint);
    canvas.drawRect(Rect.fromLTWH(12, 5 + bounceY, 4, 10), hairPaint);

    // Arnis Colored Headband
    final headBandPaint = Paint()..color = headbandColor;
    canvas.drawRect(Rect.fromLTWH(13, 7 + bounceY, 22, 5), headBandPaint);
    // Headband knot ribbon trailing behind
    canvas.drawRect(Rect.fromLTWH(8, 9 + bounceY, 6, 4), headBandPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(27, 14 + bounceY, 3, 3), eyePaint);

    // 4. ARMS & BASTON WEAPONS
    _renderArmsAndSticks(canvas, bounceY, skinPaint, outlinePaint);
  }

  void _renderArmsAndSticks(
    Canvas canvas,
    double bounceY,
    Paint skinPaint,
    Paint outlinePaint,
  ) {
    final stickPaint = _getWeaponPaint();

    if (animState == FighterAnimState.striking) {
      // Swing arc animation
      final swingAngle = (-0.8 + (strikeProgress * 1.6)) * pi;

      canvas.save();
      canvas.translate(28, 30 + bounceY);
      canvas.rotate(swingAngle);

      // Forearm
      canvas.drawRect(const Rect.fromLTWH(0, -3, 16, 6), skinPaint);
      canvas.drawRect(const Rect.fromLTWH(0, -3, 16, 6), outlinePaint);

      // Baston stick
      canvas.drawRect(const Rect.fromLTWH(12, -26, 5, 52), stickPaint);
      canvas.drawRect(const Rect.fromLTWH(12, -26, 5, 52), outlinePaint);

      // Motion Trail
      final trailPaint = Paint()
        ..color = const Color(0x55FFFFFF)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        const Rect.fromLTWH(-20, -35, 70, 70),
        -pi * 0.4,
        pi * 0.8,
        true,
        trailPaint,
      );

      canvas.restore();
    } else if (animState == FighterAnimState.blocking) {
      // Crossed block
      canvas.save();
      canvas.translate(32, 28 + bounceY);
      canvas.rotate(-0.35);

      // Arm
      canvas.drawRect(const Rect.fromLTWH(0, -3, 15, 6), skinPaint);
      canvas.drawRect(const Rect.fromLTWH(0, -3, 15, 6), outlinePaint);

      // Stick in 45-degree angle
      canvas.drawRect(const Rect.fromLTWH(10, -25, 5, 50), stickPaint);
      canvas.drawRect(const Rect.fromLTWH(10, -25, 5, 50), outlinePaint);

      canvas.restore();
    } else if (animState == FighterAnimState.clinch) {
      // Locked sticks with spark
      canvas.save();
      canvas.translate(36, 26 + bounceY);
      canvas.rotate(0.2);

      canvas.drawRect(const Rect.fromLTWH(0, -3, 14, 6), skinPaint);
      canvas.drawRect(const Rect.fromLTWH(8, -28, 5, 56), stickPaint);
      canvas.drawRect(const Rect.fromLTWH(8, -28, 5, 56), outlinePaint);

      // Clashing spark
      final sparkPaint = Paint()..color = const Color(0xFFFDE047);
      canvas.drawCircle(const Offset(10, -10), 5 + (sin(animTimer * 20.0) * 3), sparkPaint);

      canvas.restore();
    } else {
      // Idle / Stepping Stance based on Style
      switch (fighter.style) {
        case FighterStyle.soloBaston:
          // Right forward arm holding single stick
          canvas.drawRect(Rect.fromLTWH(26, 30 + bounceY, 12, 6), skinPaint);
          canvas.drawRect(Rect.fromLTWH(26, 30 + bounceY, 12, 6), outlinePaint);

          canvas.drawRect(Rect.fromLTWH(34, 10 + bounceY, 5, 42), stickPaint);
          canvas.drawRect(Rect.fromLTWH(34, 10 + bounceY, 5, 42), outlinePaint);

          // Left guard hand
          canvas.drawRect(Rect.fromLTWH(18, 32 + bounceY, 8, 6), skinPaint);
          break;

        case FighterStyle.dobleBaston:
          // Twin sticks (Sinawali guard)
          // Front stick
          canvas.drawRect(Rect.fromLTWH(26, 28 + bounceY, 12, 6), skinPaint);
          canvas.drawRect(Rect.fromLTWH(35, 8 + bounceY, 5, 42), stickPaint);
          canvas.drawRect(Rect.fromLTWH(35, 8 + bounceY, 5, 42), outlinePaint);

          // Rear stick
          canvas.drawRect(Rect.fromLTWH(14, 30 + bounceY, 10, 6), skinPaint);
          canvas.drawRect(Rect.fromLTWH(10, 12 + bounceY, 5, 38), stickPaint);
          canvas.drawRect(Rect.fromLTWH(10, 12 + bounceY, 5, 38), outlinePaint);
          break;

        case FighterStyle.espadaYDaga:
          // Long Baston in front, Dagger in rear
          canvas.drawRect(Rect.fromLTWH(26, 28 + bounceY, 12, 6), skinPaint);
          canvas.drawRect(Rect.fromLTWH(36, 6 + bounceY, 5, 46), stickPaint);
          canvas.drawRect(Rect.fromLTWH(36, 6 + bounceY, 5, 46), outlinePaint);

          // Dagger (short wooden or steel blade)
          final daggerPaint = Paint()..color = const Color(0xFFCBD5E1);
          canvas.drawRect(Rect.fromLTWH(14, 32 + bounceY, 10, 6), skinPaint);
          canvas.drawRect(Rect.fromLTWH(16, 22 + bounceY, 4, 16), daggerPaint);
          canvas.drawRect(Rect.fromLTWH(16, 22 + bounceY, 4, 16), outlinePaint);
          break;
      }
    }
  }

  Paint _getWeaponPaint() {
    final weaponId = fighter.equippedWeapon.id;
    if (weaponId == 'padded_stick') {
      return Paint()..color = headbandColor; // red or blue padded stick
    } else if (weaponId == 'bahi') {
      return Paint()..color = const Color(0xFF5C3317); // Dark brown palm wood
    } else if (weaponId == 'kamagong') {
      return Paint()..color = const Color(0xFF1C1917); // Jet black ironwood
    } else {
      // Yantok / Rattan
      return Paint()..color = const Color(0xFFDDB673); // Bamboo tan
    }
  }
}
