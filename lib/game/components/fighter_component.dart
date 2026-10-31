import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/fighter_model.dart';
import '../arnis_match_game.dart';
import '../asset_registry.dart';
import 'floating_text.dart';

enum FighterAnimState {
  idle,
  stepping,
  striking,
  signatureAbaniko,
  signatureHeavenSix,
  blocking,
  hitStun,
  clinch,
  knockdown,
  victory,
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

  // Dodge afterimage ghost position
  Vector2? dodgeGhostPos;
  double dodgeGhostOpacity = 0.0;

  // Whether strikes are controlled by headless deterministic MatchEngine
  bool isDrivenByEngine = true;

  // Reference to opponent
  FighterComponent? opponent;

  // Callbacks to Game & Announcer
  void Function(FighterComponent attacker, double damage, bool isCrit)? onHitLanded;
  void Function()? onClinchTriggered;
  void Function(String eventLog)? onAnnouncerLog;

  FighterComponent({
    required this.fighter,
    required Vector2 position,
    required this.isFacingRight,
    this.headbandColor = const Color(0xFFDC2626),
    this.sandoColor = const Color(0xFF1E293B),
  })  : currentHp = fighter.hp,
        currentStamina = fighter.stamina,
        super(position: position, size: Vector2(48, 80), priority: 10, anchor: Anchor.bottomCenter);

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

  // Coach Shouts (Zero Emojis!)
  void applyBira() {
    hasBiraAura = true;
    biraTimer = 5.0;
    parent?.add(FloatingTextComponent(
      text: '[BIRA! +30% LAKAS]',
      position: position + Vector2(-30, -90),
      color: const Color(0xFFE6482E),
      fontSize: 12,
    ));
    onAnnouncerLog?.call('${fighter.name} sumugod sa sigaw ng Coach: BIRA!');
  }

  void applySalag() {
    hasSalagAura = true;
    salagTimer = 5.0;
    animState = FighterAnimState.blocking;
    parent?.add(FloatingTextComponent(
      text: '[SALAG! +50% DEP]',
      position: position + Vector2(-30, -90),
      color: const Color(0xFF38BDF8),
      fontSize: 12,
    ));
    onAnnouncerLog?.call('${fighter.name} itinaas ang baston para sa depensang SALAG!');
  }

  void applyDiskarte() {
    hasDiskarteAura = true;
    diskarteTimer = 5.0;
    parent?.add(FloatingTextComponent(
      text: '[DISKARTE! SABONG LOCK]',
      position: position + Vector2(-30, -90),
      color: const Color(0xFFFDE047),
      fontSize: 12,
    ));
    onAnnouncerLog?.call('${fighter.name} naghanap ng sabong clinch sa DISKARTE command!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    animTimer += dt;

    if (dodgeGhostOpacity > 0) {
      dodgeGhostOpacity -= dt * 3.0;
      if (dodgeGhostOpacity <= 0) dodgeGhostPos = null;
    }

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

    if (hitStunTimer > 0) {
      hitStunTimer -= dt;
      if (hitStunTimer <= 0) animState = FighterAnimState.idle;
      return;
    }

    if (animState == FighterAnimState.striking ||
        animState == FighterAnimState.signatureAbaniko ||
        animState == FighterAnimState.signatureHeavenSix) {
      strikeProgress += dt * 4.5;
      if (strikeProgress >= 1.0) {
        strikeProgress = 0.0;
        animState = FighterAnimState.idle;
      }
      return;
    }

    if (animState == FighterAnimState.clinch) return;

    strikeCooldown -= dt;
    _runAutoBattlerAI(dt);
  }

  void _runAutoBattlerAI(double dt) {
    if (opponent == null || currentHp <= 0 || opponent!.currentHp <= 0) return;

    final targetX = opponent!.position.x;
    final currentX = position.x;
    final distance = (targetX - currentX).abs();
    const strikeRange = 64.0;

    if (hasDiskarteAura && distance <= strikeRange + 12) {
      triggerClinch();
      return;
    }

    if (distance > strikeRange + 10) {
      final dir = targetX > currentX ? 1.0 : -1.0;
      final stepSpeed = (35.0 + combatSpeed * 1.8);
      position.x += dir * stepSpeed * dt;
      animState = FighterAnimState.stepping;
    } else if (distance < strikeRange - 16) {
      final dir = targetX > currentX ? -1.0 : 1.0;
      position.x += dir * 25.0 * dt;
      animState = FighterAnimState.stepping;
    } else {
      if (!isDrivenByEngine && strikeCooldown <= 0) {
        _attemptStrikeOrDefense();
      } else {
        if (animState != FighterAnimState.blocking &&
            animState != FighterAnimState.striking &&
            animState != FighterAnimState.signatureAbaniko &&
            animState != FighterAnimState.signatureHeavenSix &&
            animState != FighterAnimState.hitStun &&
            animState != FighterAnimState.knockdown &&
            animState != FighterAnimState.victory) {
          animState = FighterAnimState.idle;
        }
      }
    }

    // Clamp to canvas mat boundaries
    final parentGame = findParent<ArnisMatchGame>();
    if (parentGame != null) {
      final cx = parentGame.size.x * 0.5;
      final ringHalfW = min(parentGame.size.x * 0.44, 160.0);
      position.x = position.x.clamp(cx - ringHalfW + 35.0, cx + ringHalfW - 35.0);
    }
  }

  void _attemptStrikeOrDefense() {
    if (opponent == null) return;
    final rnd = Random();

    if (opponent!.animState == FighterAnimState.striking && rnd.nextDouble() < (combatDefense / 60.0)) {
      animState = FighterAnimState.blocking;
      strikeCooldown = 0.35;
      return;
    }

    // Roll for regular strike vs style signature move
    if (rnd.nextDouble() < 0.20 && fighter.styleMasteries[fighter.style]! >= 2) {
      if (fighter.style == FighterStyle.soloBaston) {
        animState = FighterAnimState.signatureAbaniko;
      } else {
        animState = FighterAnimState.signatureHeavenSix;
      }
    } else {
      animState = FighterAnimState.striking;
    }

    strikeProgress = 0.0;
    final attackInterval = (1.4 - (combatSpeed * 0.025)).clamp(0.40, 1.30);
    strikeCooldown = attackInterval;

    if (opponent!.animState == FighterAnimState.striking && rnd.nextDouble() < 0.28) {
      triggerClinch();
      return;
    }

    _executeStrike();
  }

  void _executeStrike() {
    if (opponent == null) return;
    final rnd = Random();

    final hitRoll = rnd.nextDouble() * 100.0;
    final opponentDodge = opponent!.combatSpeed * 0.6;

    if (hitRoll < opponentDodge) {
      // Dodge / Iwas! Leave afterimage ghost
      opponent!.dodgeGhostPos = opponent!.position.clone();
      opponent!.dodgeGhostOpacity = 0.7;

      opponent!.parent?.add(FloatingTextComponent(
        text: '[IWAS! DODGE]',
        position: opponent!.position + Vector2(-15, -70),
        color: const Color(0xFF4ADE80),
        fontSize: 11,
      ));
      onAnnouncerLog?.call('${opponent!.fighter.name} mabilis na umilag sa palo!');
      return;
    }

    // Block / Salag!
    if (opponent!.animState == FighterAnimState.blocking ||
        opponent!.hasSalagAura ||
        (rnd.nextDouble() < (opponent!.combatDefense / 85.0))) {
      opponent!.parent?.add(FloatingTextComponent(
        text: '[SALAG! BLOCK]',
        position: opponent!.position + Vector2(-15, -70),
        color: const Color(0xFF38BDF8),
        fontSize: 11,
      ));

      final chipDamage = max(1.0, (combatPower * 0.15) - (opponent!.combatDefense * 0.1));
      opponent!.receiveDamage(chipDamage, isCrit: false, fromAttacker: this);
      onAnnouncerLog?.call('Tumataginting na SALAG! Nasangga ang palo!');
      return;
    }

    // Crit or Hit
    final isSpecialMove = animState == FighterAnimState.signatureAbaniko || animState == FighterAnimState.signatureHeavenSix;
    final critChance = ((combatTechnique / 75.0) + (isSpecialMove ? 0.25 : 0.0)).clamp(0.05, 0.60);
    final isCrit = rnd.nextDouble() < critChance;

    double damage = combatPower * (isCrit ? 1.75 : 1.0) + (rnd.nextDouble() * 4.0);
    damage = max(3.0, damage - (opponent!.combatDefense * 0.3));

    opponent!.receiveDamage(damage, isCrit: isCrit, fromAttacker: this);

    if (isCrit) {
      onAnnouncerLog?.call('NAPAKALAKAS! Tumagos ang palo ni ${fighter.name}!');
    }
  }

  void receiveDamage(double damage, {required bool isCrit, required FighterComponent fromAttacker}) {
    currentHp = (currentHp - damage).clamp(0.0, fighter.maxHp);
    hitStunTimer = isCrit ? 0.35 : 0.20;
    animState = FighterAnimState.hitStun;

    final knockDir = position.x > fromAttacker.position.x ? 1.0 : -1.0;
    position.x += knockDir * (isCrit ? 16.0 : 8.0);
    final parentGame = findParent<ArnisMatchGame>();
    if (parentGame != null) {
      final cx = parentGame.size.x * 0.5;
      final ringHalfW = min(parentGame.size.x * 0.44, 160.0);
      position.x = position.x.clamp(cx - ringHalfW + 35.0, cx + ringHalfW - 35.0);
    }

    final displayText = isCrit ? '[LAKAS!] -${damage.toInt()}' : '-${damage.toInt()}';
    final textColor = isCrit ? const Color(0xFFDC2626) : const Color(0xFFF4B41B);

    parent?.add(FloatingTextComponent(
      text: displayText,
      position: position + Vector2(-15, -75),
      color: textColor,
      fontSize: isCrit ? 15 : 12,
      upwardSpeed: isCrit ? 60 : 40,
    ));

    onHitLanded?.call(fromAttacker, damage, isCrit);
  }

  void performVisualStrike({bool isSpecial = false}) {
    if (isSpecial) {
      animState = fighter.style == FighterStyle.soloBaston
          ? FighterAnimState.signatureAbaniko
          : FighterAnimState.signatureHeavenSix;
    } else {
      animState = FighterAnimState.striking;
    }
    strikeProgress = 0.0;
  }

  void performVisualBlock() {
    animState = FighterAnimState.blocking;
    strikeCooldown = 0.4;
  }

  void triggerClinch() {
    animState = FighterAnimState.clinch;
    if (opponent != null) {
      opponent!.animState = FighterAnimState.clinch;
    }
    parent?.add(FloatingTextComponent(
      text: '[SABONG! STICK LOCK]',
      position: Vector2((position.x + (opponent?.position.x ?? position.x)) / 2 - 40, position.y - 85),
      color: const Color(0xFFFDE047),
      fontSize: 13,
    ));
    onAnnouncerLog?.call('REFEREE: Sabong! Nagkapit ang mga baston!');
    onClinchTriggered?.call();
  }

  void disarm() {
    isDisarmed = true;
    disarmTimer = 6.0;
    parent?.add(FloatingTextComponent(
      text: '[AGAW-BASTON! -50% DMG]',
      position: position + Vector2(-40, -95),
      color: const Color(0xFFE6482E),
      fontSize: 12,
    ));
    onAnnouncerLog?.call('AGAW-BASTON! Nalaglag ang baston ni ${fighter.name}!');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw Dodge Afterimage ghost if active
    if (dodgeGhostPos != null && dodgeGhostOpacity > 0) {
      canvas.save();
      final ghostPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: dodgeGhostOpacity * 0.5);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), ghostPaint);
      canvas.restore();
    }

    canvas.save();
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
        ..color = const Color(0x66E6482E)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(-4, -4, size.x + 8, size.y + 8), biraPaint);
    }
    if (hasSalagAura) {
      final salagPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(Rect.fromLTWH(-2, -2, size.x + 4, size.y + 4), salagPaint);
    }
    if (hasDiskarteAura) {
      final diskartePaint = Paint()
        ..color = const Color(0xFFFDE047)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), diskartePaint);
    }
  }

  void _renderProceduralPixelFighter(Canvas canvas) {
    if (animState == FighterAnimState.knockdown) {
      _renderKnockdown(canvas);
      return;
    }

    double bounceY = 0;
    if (animState == FighterAnimState.idle) {
      bounceY = sin(animTimer * 5.0) * 1.5;
    } else if (animState == FighterAnimState.stepping) {
      bounceY = sin(animTimer * 12.0) * 3.0;
    } else if (animState == FighterAnimState.victory) {
      bounceY = sin(animTimer * 8.0) * 2.5;
    } else if (animState == FighterAnimState.hitStun) {
      bounceY = (Random().nextDouble() - 0.5) * 4.0;
    }

    final outline = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final skin = Paint()..color = const Color(0xFFF2B880);

    // High-visibility character placeholder box via AssetRegistry
    final baseColor = fighter.isPlayer ? const Color(0xFF38BDF8) : const Color(0xFFDC2626);
    final isStunned = animState == FighterAnimState.hitStun;
    final bodyColor = isStunned ? const Color(0xFFE6482E) : baseColor;

    AssetRegistry.drawPlaceholder(
      canvas,
      Rect.fromLTWH(12, 16 + bounceY, 24, 48),
      label: fighter.name.split(' ').first.toUpperCase(),
      color: bodyColor,
      fontSize: 6.5,
    );

    // Bastons & Arms
    if (animState == FighterAnimState.victory) {
      _renderVictoryArms(canvas, bounceY, outline);
    } else {
      _renderBastonsAndArms(canvas, bounceY, skin, outline);
    }
  }

  void _renderVictoryArms(Canvas canvas, double bounceY, Paint outline) {
    final stickPaint = _getWeaponPaint();
    canvas.drawRect(Rect.fromLTWH(8, -12 + bounceY, 5, 24), stickPaint);
    canvas.drawRect(Rect.fromLTWH(8, -12 + bounceY, 5, 24), outline);
    canvas.drawRect(Rect.fromLTWH(35, -12 + bounceY, 5, 24), stickPaint);
    canvas.drawRect(Rect.fromLTWH(35, -12 + bounceY, 5, 24), outline);
  }

  void _renderKnockdown(Canvas canvas) {
    AssetRegistry.drawPlaceholder(
      canvas,
      const Rect.fromLTWH(4, 56, 40, 20),
      label: 'KO',
      color: const Color(0xFFEF4444),
    );
  }

  void _renderBastonsAndArms(Canvas canvas, double bounceY, Paint skin, Paint outline) {
    final stickPaint = _getWeaponPaint();

    if (animState == FighterAnimState.signatureAbaniko) {
      // Abaniko 3-fanning arc motion trail
      final swingAngle = (-0.9 + (strikeProgress * 1.8)) * pi;
      canvas.save();
      canvas.translate(28, 30 + bounceY);
      canvas.rotate(swingAngle);

      canvas.drawRect(const Rect.fromLTWH(0, -3, 16, 6), skin);
      canvas.drawRect(const Rect.fromLTWH(0, -3, 16, 6), outline);
      canvas.drawRect(const Rect.fromLTWH(12, -26, 5, 52), stickPaint);
      canvas.drawRect(const Rect.fromLTWH(12, -26, 5, 52), outline);

      // 3 Fanning Arc Trail Slices
      final fanPaint = Paint()
        ..color = const Color(0x66FDE047)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(const Rect.fromLTWH(-30, -45, 90, 90), -pi * 0.5, pi * 0.9, false, fanPaint);

      canvas.restore();
    } else if (animState == FighterAnimState.signatureHeavenSix) {
      // Doble baston sinawali flurry
      final weave = sin(strikeProgress * 4 * pi) * 10;
      canvas.save();
      canvas.translate(28, 28 + bounceY);

      canvas.drawRect(Rect.fromLTWH(0, -3 + weave, 16, 6), skin);
      canvas.drawRect(Rect.fromLTWH(12, -24 + weave, 5, 48), stickPaint);
      canvas.drawRect(Rect.fromLTWH(12, -24 + weave, 5, 48), outline);

      canvas.drawRect(Rect.fromLTWH(-8, 4 - weave, 16, 6), skin);
      canvas.drawRect(Rect.fromLTWH(4, -18 - weave, 5, 48), stickPaint);
      canvas.drawRect(Rect.fromLTWH(4, -18 - weave, 5, 48), outline);

      canvas.restore();
    } else if (animState == FighterAnimState.striking) {
      final swingAngle = (-0.8 + (strikeProgress * 1.6)) * pi;
      canvas.save();
      canvas.translate(28, 30 + bounceY);
      canvas.rotate(swingAngle);

      canvas.drawRect(const Rect.fromLTWH(0, -3, 16, 6), skin);
      canvas.drawRect(const Rect.fromLTWH(0, -3, 16, 6), outline);
      canvas.drawRect(const Rect.fromLTWH(12, -26, 5, 52), stickPaint);
      canvas.drawRect(const Rect.fromLTWH(12, -26, 5, 52), outline);

      canvas.restore();
    } else if (animState == FighterAnimState.blocking) {
      canvas.save();
      canvas.translate(32, 28 + bounceY);
      canvas.rotate(-0.35);

      canvas.drawRect(const Rect.fromLTWH(0, -3, 15, 6), skin);
      canvas.drawRect(const Rect.fromLTWH(0, -3, 15, 6), outline);
      canvas.drawRect(const Rect.fromLTWH(10, -25, 5, 50), stickPaint);
      canvas.drawRect(const Rect.fromLTWH(10, -25, 5, 50), outline);

      // Block shield spark
      final shieldPaint = Paint()
        ..color = const Color(0x8838BDF8)
        ..style = PaintingStyle.fill;
      canvas.drawRect(const Rect.fromLTWH(6, -28, 12, 56), shieldPaint);

      canvas.restore();
    } else if (animState == FighterAnimState.clinch) {
      canvas.save();
      canvas.translate(36, 26 + bounceY);
      canvas.rotate(0.2);

      canvas.drawRect(const Rect.fromLTWH(0, -3, 14, 6), skin);
      canvas.drawRect(const Rect.fromLTWH(8, -28, 5, 56), stickPaint);
      canvas.drawRect(const Rect.fromLTWH(8, -28, 5, 56), outline);

      final spark = Paint()..color = const Color(0xFFFDE047);
      canvas.drawRect(Rect.fromCenter(center: const Offset(10, -10), width: 10, height: 10), spark);

      canvas.restore();
    } else {
      // Idle Style Stance
      if (fighter.style == FighterStyle.soloBaston) {
        canvas.drawRect(Rect.fromLTWH(26, 30 + bounceY, 12, 6), skin);
        canvas.drawRect(Rect.fromLTWH(34, 10 + bounceY, 5, 42), stickPaint);
        canvas.drawRect(Rect.fromLTWH(34, 10 + bounceY, 5, 42), outline);
      } else if (fighter.style == FighterStyle.dobleBaston) {
        canvas.drawRect(Rect.fromLTWH(26, 28 + bounceY, 12, 6), skin);
        canvas.drawRect(Rect.fromLTWH(35, 8 + bounceY, 5, 42), stickPaint);
        canvas.drawRect(Rect.fromLTWH(35, 8 + bounceY, 5, 42), outline);

        canvas.drawRect(Rect.fromLTWH(14, 30 + bounceY, 10, 6), skin);
        canvas.drawRect(Rect.fromLTWH(10, 12 + bounceY, 5, 38), stickPaint);
        canvas.drawRect(Rect.fromLTWH(10, 12 + bounceY, 5, 38), outline);
      } else {
        canvas.drawRect(Rect.fromLTWH(26, 28 + bounceY, 12, 6), skin);
        canvas.drawRect(Rect.fromLTWH(36, 6 + bounceY, 5, 46), stickPaint);
        canvas.drawRect(Rect.fromLTWH(36, 6 + bounceY, 5, 46), outline);

        final dagger = Paint()..color = const Color(0xFFCBD5E1);
        canvas.drawRect(Rect.fromLTWH(14, 32 + bounceY, 10, 6), skin);
        canvas.drawRect(Rect.fromLTWH(16, 22 + bounceY, 4, 16), dagger);
        canvas.drawRect(Rect.fromLTWH(16, 22 + bounceY, 4, 16), outline);
      }
    }
  }

  Paint _getWeaponPaint() {
    final weaponId = fighter.equippedWeapon.id;
    if (weaponId == 'padded_stick') {
      return Paint()..color = headbandColor;
    } else if (weaponId == 'bahi') {
      return Paint()..color = const Color(0xFF564064);
    } else if (weaponId == 'kamagong') {
      return Paint()..color = const Color(0xFF1A1C2C);
    } else {
      return Paint()..color = const Color(0xFFF4B41B);
    }
  }
}
