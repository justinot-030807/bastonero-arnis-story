// lib/domain/systems/event_system.dart
// Pure Dart event system for weekly rolls, cooldowns, and effect application.

import 'dart:math';
import '../models/camp.dart';
import '../models/event.dart';
import '../rng.dart';

class EventApplicationResult {
  final GameEvent event;
  final EventChoice? choice;
  final int moneyDelta;
  final int fameDelta;
  final double moraleDelta;
  final double fatigueDelta;
  final double gradeDelta;
  final String logMessage;
  final bool hasWalkInRecruit;
  final bool hasFreeScholarRecruit;
  final bool isTrainingBlocked;

  const EventApplicationResult({
    required this.event,
    this.choice,
    this.moneyDelta = 0,
    this.fameDelta = 0,
    this.moraleDelta = 0.0,
    this.fatigueDelta = 0.0,
    this.gradeDelta = 0.0,
    required this.logMessage,
    this.hasWalkInRecruit = false,
    this.hasFreeScholarRecruit = false,
    this.isTrainingBlocked = false,
  });
}

class EventSystem {
  final List<GameEvent> events;

  EventSystem({required this.events});

  /// Evaluates whether an event can trigger based on camp conditions and cooldowns.
  bool canTrigger(GameEvent event, Camp camp, int month, int week, Map<String, int> cooldowns) {
    // Check cooldown
    if ((cooldowns[event.id] ?? 0) > 0) {
      return false;
    }

    // Check specific month trigger if set
    if (event.triggerMonth != null && event.triggerMonth != month) {
      return false;
    }

    // Check conditions
    if (event.condition != null) {
      switch (event.condition) {
        case 'has_failing_student':
          final hasFailing = camp.students.any((s) => s.isVarsityEligible == false && s.grade > 0);
          if (!hasFailing) return false;
          break;
        case 'has_alumni':
          if (camp.alumni.isEmpty) return false;
          break;
        case 'rainy_season':
          if (month < 6 || month > 10) return false;
          break;
        default:
          break;
      }
    }

    return true;
  }

  /// Rolls for a random event during the weekly calendar tick.
  /// Standard trigger rate: ~25% per week (sane rate approx 1 event a month).
  GameEvent? rollWeeklyEvent({
    required Camp camp,
    required int month,
    required int week,
    required GameRng rng,
    required Map<String, int> cooldowns,
    double triggerChance = 0.25,
  }) {
    // Guaranteed seasonal event: Pasko in December Week 4
    if (month == 12 && week == 4) {
      final pasko = events.firstWhere((e) => e.id == 'pasko', orElse: () => events.first);
      if (canTrigger(pasko, camp, month, week, cooldowns)) {
        return pasko;
      }
    }

    // Guaranteed seasonal event: Bagyo in July Week 2 if not on cooldown
    if (month == 7 && week == 2) {
      final bagyo = events.firstWhere((e) => e.id == 'bagyo', orElse: () => events.first);
      if (canTrigger(bagyo, camp, month, week, cooldowns)) {
        return bagyo;
      }
    }

    // Standard weekly roll check
    if (rng.nextDouble() > triggerChance) {
      return null;
    }

    // Filter valid candidate events
    final candidates = events.where((e) => canTrigger(e, camp, month, week, cooldowns)).toList();
    if (candidates.isEmpty) return null;

    final index = rng.nextInt(candidates.length);
    return candidates[index];
  }

  /// Applies the effects of an event (and optionally a user choice) to the camp.
  EventApplicationResult applyEventEffects({
    required GameEvent event,
    required Camp camp,
    EventChoice? choice,
    required GameRng rng,
  }) {
    final eff = Map<String, dynamic>.from(event.effects);
    if (choice != null) {
      eff.addAll(choice.effects);
    }

    int moneyDelta = 0;
    int fameDelta = 0;
    double moraleDelta = 0.0;
    double fatigueDelta = 0.0;
    double gradeDelta = 0.0;
    bool hasWalkInRecruit = false;
    bool hasFreeScholarRecruit = false;
    bool isTrainingBlocked = false;

    // 1. Money changes
    if (eff['moneyGain'] != null) {
      final gain = eff['moneyGain'] as int;
      camp.money += gain;
      moneyDelta += gain;
    }
    if (eff['costBase'] != null) {
      final cost = eff['costBase'] as int;
      camp.money = max(0, camp.money - cost);
      moneyDelta -= cost;
    }
    if (eff['repairDeduction'] == true) {
      final repairCost = 300 * camp.floors;
      camp.money = max(0, camp.money - repairCost);
      moneyDelta -= repairCost;
    }

    // 2. Fame changes
    if (eff['fameGain'] != null) {
      final gain = eff['fameGain'] as int;
      camp.fame += gain;
      fameDelta += gain;
    }

    // 3. Morale changes
    if (eff['moraleGain'] != null) {
      moraleDelta += (eff['moraleGain'] as num).toDouble();
    }
    if (eff['moralePenalty'] != null) {
      moraleDelta -= (eff['moralePenalty'] as num).toDouble();
    }

    // 4. Fatigue changes
    if (eff['fatigueAll'] != null) {
      fatigueDelta += (eff['fatigueAll'] as num).toDouble();
    }
    if (eff['fatigueRelief'] != null) {
      fatigueDelta -= (eff['fatigueRelief'] as num).toDouble();
    }

    // 5. Grade changes
    if (eff['gradeBoostAll'] != null) {
      gradeDelta += (eff['gradeBoostAll'] as num).toDouble();
    }

    // 6. Recruits
    if (eff['walkInRecruitBonus'] != null) {
      hasWalkInRecruit = true;
    }
    if (eff['freeHighPotentialRecruit'] == true) {
      hasFreeScholarRecruit = true;
    }

    // 7. Training block
    if (eff['trainingBlocked'] == true) {
      isTrainingBlocked = true;
    }

    // Apply student wide changes
    for (final s in camp.students) {
      if (moraleDelta != 0.0) {
        s.morale = (s.morale + moraleDelta).clamp(0.0, 100.0);
      }
      if (fatigueDelta != 0.0) {
        s.fatigue = (s.fatigue + fatigueDelta).clamp(0.0, 100.0);
      }
      if (gradeDelta != 0.0) {
        s.gradePercent = (s.gradePercent + gradeDelta).clamp(0.0, 100.0);
      }
      if (eff['diskarteGain'] != null) {
        s.diskarte += (eff['diskarteGain'] as num).toDouble();
      }
      if (eff['lakasGain'] != null) {
        s.lakas += (eff['lakasGain'] as num).toDouble();
      }
      if (eff['bilisGain'] != null) {
        s.bilis += (eff['bilisGain'] as num).toDouble();
      }
      if (eff['salagGain'] != null) {
        s.salag += (eff['salagGain'] as num).toDouble();
      }
      if (eff['studentsRestWeeks'] != null) {
        s.fatigue = (s.fatigue + 20).clamp(0.0, 100.0);
      }
    }

    final buffer = StringBuffer();
    buffer.write('[${event.tag.toUpperCase()}] ${event.title}: ');
    if (choice != null) {
      buffer.write('${choice.label}. ');
    }
    if (moneyDelta != 0) {
      buffer.write('${moneyDelta > 0 ? "+P" : "-P"}${moneyDelta.abs()} ');
    }
    if (fameDelta != 0) {
      buffer.write('+$fameDelta Fame ');
    }
    if (moraleDelta != 0.0) {
      buffer.write('${moraleDelta > 0 ? "+Gana" : "-Gana"} ');
    }

    return EventApplicationResult(
      event: event,
      choice: choice,
      moneyDelta: moneyDelta,
      fameDelta: fameDelta,
      moraleDelta: moraleDelta,
      fatigueDelta: fatigueDelta,
      gradeDelta: gradeDelta,
      logMessage: buffer.toString().trim(),
      hasWalkInRecruit: hasWalkInRecruit,
      hasFreeScholarRecruit: hasFreeScholarRecruit,
      isTrainingBlocked: isTrainingBlocked,
    );
  }
}
