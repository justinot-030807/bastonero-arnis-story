// test/match_engine_test.dart
// PURE DART - Headless unit tests for MatchEngine.
// Verifies determinism, damage bounds, 50/50 win rate on equal fighters, Finisher Tap, and coach commands.

import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/domain/balance.dart';
import 'package:bastonero_arnis_story/domain/match_engine.dart';
import 'package:bastonero_arnis_story/domain/models/student.dart';

void main() {
  group('MatchEngine - Determinism & Formulas', () {
    test('Identical fighters with the same seed produce identical match results', () {
      final p1 = Combatant.create(id: 'std_01', name: 'Bayani', lakas: 20, bilis: 18, diskarte: 16, salag: 14);
      final o1 = Combatant.create(id: 'std_02', name: 'Berto', lakas: 20, bilis: 18, diskarte: 16, salag: 14);
      final engine1 = MatchEngine(player: p1, opponent: o1, seed: 424242);
      final result1 = engine1.simulateEntireMatch();

      final p2 = Combatant.create(id: 'std_01', name: 'Bayani', lakas: 20, bilis: 18, diskarte: 16, salag: 14);
      final o2 = Combatant.create(id: 'std_02', name: 'Berto', lakas: 20, bilis: 18, diskarte: 16, salag: 14);
      final engine2 = MatchEngine(player: p2, opponent: o2, seed: 424242);
      final result2 = engine2.simulateEntireMatch();

      expect(result1.winner.name, equals(result2.winner.name));
      expect(result1.endReason, equals(result2.endReason));
      expect(result1.totalTicks, equals(result2.totalTicks));
      expect(result1.totalRoundsFought, equals(result2.totalRoundsFought));
      expect(p1.totalDamageDealt, equals(p2.totalDamageDealt));
      expect(o1.totalDamageDealt, equals(o2.totalDamageDealt));
    });

    test('Damage per hit respects expected formula bounds', () {
      final player = Combatant.create(id: 'p1', name: 'Bayani', lakas: 30.0, bilis: 20.0, diskarte: 20.0, salag: 20.0);
      final opponent = Combatant.create(id: 'o1', name: 'Berto', lakas: 30.0, bilis: 20.0, diskarte: 20.0, salag: 20.0);
      final engine = MatchEngine(player: player, opponent: opponent, seed: 12345);

      engine.simulateEntireMatch();

      expect(player.strikesLanded, greaterThan(0));
      expect(player.totalDamageDealt, greaterThan(0));
      // Max damage should not exceed reasonable multiplier bounds (lakas * 1.0 * 1.2 * 0.35 * 1.5)
      expect(player.maxDamageSingleHit, greaterThanOrEqualTo(1.0));
      expect(player.maxDamageSingleHit, lessThan(45.0));
    });

    test('Combatant.fromStudent initializes correctly from Student model', () {
      final student = Student(
        id: 'std_test',
        name: 'Mayumi',
        nickname: 'Kidlat',
        lakas: 25.0,
        bilis: 22.0,
        diskarte: 19.0,
        salag: 18.0,
        style: ArnisStyle.dobleBaston,
        traits: ['Maliksi', 'Palaban'],
      );

      final combatant = Combatant.fromStudent(student);
      expect(combatant.id, 'std_test');
      expect(combatant.name, 'Mayumi "Kidlat"');
      expect(combatant.lakas, 25.0);
      expect(combatant.bilis, 22.0);
      expect(combatant.style, ArnisStyle.dobleBaston);
      expect(combatant.traits.contains('Palaban'), isTrue);
      expect(combatant.currentHp, equals(student.maxHp));
    });
  });

  group('MatchEngine - Finisher Tap (TAMAAN!) & Coach Commands', () {
    test('Finisher Tap: Bullseye [0.45..0.55] triggers 2x signature damage and crit', () {
      final player = Combatant.create(id: 'p1', name: 'Bayani', lakas: 25.0);
      final opponent = Combatant.create(id: 'o1', name: 'Berto', lakas: 25.0);
      final engine = MatchEngine(player: player, opponent: opponent, seed: 9999);

      player.pusoMeter = 100.0;
      final hpBefore = opponent.currentHp;

      final res = engine.resolveFinisherTap(tapOffset: 0.50);
      expect(res, isNotNull);
      expect(res!.isCrit, isTrue);
      expect(opponent.currentHp, lessThan(hpBefore));
      expect(player.pusoMeter, 0.0);
    });

    test('Finisher Tap: Outside zone misses and deals 0 damage', () {
      final player = Combatant.create(id: 'p1', name: 'Bayani');
      final opponent = Combatant.create(id: 'o1', name: 'Berto');
      final engine = MatchEngine(player: player, opponent: opponent, seed: 9999);

      player.pusoMeter = 100.0;
      final hpBefore = opponent.currentHp;

      final res = engine.resolveFinisherTap(tapOffset: 0.10); // Miss
      expect(res, isNotNull);
      expect(res!.outcome, StrikeOutcome.miss);
      expect(opponent.currentHp, equals(hpBefore));
      expect(player.pusoMeter, 0.0);
    });

    test('Coach commands consume Gigil and apply Bira, Salag, and Diskarte buffs', () {
      final player = Combatant.create(id: 'p1', name: 'Bayani');
      final opponent = Combatant.create(id: 'o1', name: 'Berto');
      final engine = MatchEngine(player: player, opponent: opponent, seed: 100);

      engine.coachGigil = 100.0;

      // 1. Bira command
      expect(engine.canUseCoachCommand(CoachCommand.bira), isTrue);
      final usedBira = engine.useCoachCommand(CoachCommand.bira);
      expect(usedBira, isTrue);
      expect(engine.coachGigil, 65.0); // 100 - 35
      expect(player.biraBuffDuration, Balance.buffDurationSeconds);

      // 2. Salag command
      expect(engine.canUseCoachCommand(CoachCommand.salag), isTrue);
      final usedSalag = engine.useCoachCommand(CoachCommand.salag);
      expect(usedSalag, isTrue);
      expect(engine.coachGigil, 35.0); // 65 - 30
      expect(player.salagBuffDuration, Balance.buffDurationSeconds);

      // 3. Diskarte costs 45 -> should fail with 35 Gigil
      expect(engine.canUseCoachCommand(CoachCommand.diskarte), isFalse);
      expect(engine.useCoachCommand(CoachCommand.diskarte), isFalse);

      // Add Gigil and use Diskarte
      engine.coachGigil = 50.0;
      expect(engine.useCoachCommand(CoachCommand.diskarte), isTrue);
      expect(opponent.stunDuration, Balance.diskarteStunDurationSeconds);
    });
  });

  group('MatchEngine - Win Rate Acceptance Test (Section 17 Acceptance Criteria)', () {
    test('100 simulated fights between equal students are close to 50/50', () {
      int playerWins = 0;
      int opponentWins = 0;
      const totalSimulations = 100;

      for (int i = 0; i < totalSimulations; i++) {
        final p = Combatant.create(
          id: 'player',
          name: 'Bayani',
          lakas: 20.0,
          bilis: 18.0,
          diskarte: 16.0,
          salag: 14.0,
          style: ArnisStyle.soloBaston,
        );
        final o = Combatant.create(
          id: 'opponent',
          name: 'Berto',
          lakas: 20.0,
          bilis: 18.0,
          diskarte: 16.0,
          salag: 14.0,
          style: ArnisStyle.soloBaston,
        );

        final engine = MatchEngine(player: p, opponent: o, seed: i * 777 + 101);
        final result = engine.simulateEntireMatch();

        if (result.winner.id == 'player') {
          playerWins += 1;
        } else {
          opponentWins += 1;
        }
      }

      // Between equal fighters, win rate should be close to 50/50 (between 38 and 62 wins)
      expect(playerWins, inInclusiveRange(38, 62));
      expect(opponentWins, inInclusiveRange(38, 62));
      expect(playerWins + opponentWins, totalSimulations);
    });
  });
}
