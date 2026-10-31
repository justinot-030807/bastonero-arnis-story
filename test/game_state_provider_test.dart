import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/providers/game_state_provider.dart';
import 'package:bastonero_arnis_story/models/facility_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameStateProvider & Career Progression Tests', () {
    late GameStateProvider state;

    setUp(() {
      state = GameStateProvider();
    });

    test('Initial Career State starts at Grade 5, Age 11, Month 6 (June)', () {
      expect(state.year, 1);
      expect(state.month, 6); // Pasukan / June
      expect(state.week, 1);
      expect(state.fighter.gradeLevel, 5);
      expect(state.fighter.age, 11);
      expect(state.fighter.academics, 86.0);
      expect(state.fighter.isEligibleForSchoolVarsity, isTrue);
    });

    test('Academic Grade Checks: >= 80 Varsity Eligible, < 80 Suspended', () {
      state.fighter.academics = 82.0;
      expect(state.fighter.isEligibleForSchoolVarsity, isTrue);
      expect(state.fighter.isPassingSchool, isTrue);

      state.fighter.academics = 78.0;
      expect(state.fighter.isEligibleForSchoolVarsity, isFalse);
      expect(state.fighter.isPassingSchool, isTrue);

      state.fighter.academics = 68.0;
      expect(state.fighter.isEligibleForSchoolVarsity, isFalse);
      expect(state.fighter.isPassingSchool, isFalse);
    });

    test('Training actions consume stamina and advance calendar by 1 week', () {
      final initialPower = state.fighter.power;
      final initialWeek = state.week;
      final initialStamina = state.fighter.stamina;

      final success = state.performTraining(ActionType.trainPower);
      expect(success, isTrue);
      expect(state.fighter.power, greaterThan(initialPower));
      expect(state.week, initialWeek + 1);
      expect(state.fighter.stamina, lessThan(initialStamina));
    });

    test('Studying under Mango Tree increases Academics (Grado)', () {
      state.fighter.academics = 76.0;
      final success = state.performTraining(ActionType.study);
      expect(success, isTrue);
      expect(state.fighter.academics, greaterThan(76.0));
    });

    test('Gym Facilities: Building, Upgrades, Cutaway Expansion, and Synergies', () {
      state.pesos = 5000; // grant testing funds

      // Starter slots: 2
      expect(state.maxSlots, 2);

      // Expand to 4 slots
      final expanded1 = state.expandGymSlots();
      expect(expanded1, isTrue);
      expect(state.maxSlots, 4);

      // Build Footwork in slot 2, Buko Stand in slot 3
      state.buildFacility(2, FacilityType.footworkTires);
      state.buildFacility(3, FacilityType.bukoStand);

      expect(state.slots[2]?.type, FacilityType.footworkTires);
      expect(state.slots[3]?.type, FacilityType.bukoStand);

      // Verify active synergies include Hydration Rush or Presko Training
      final synergies = state.activeSynergies;
      expect(synergies, isNotEmpty);

      // Expand gym slots to 6 (Upper floor expansion)
      final expanded2 = state.expandGymSlots();
      expect(expanded2, isTrue);
      expect(state.maxSlots, 6);
    });

    test('Tournaments: School Track requires Grade >= 80, Street Track open to all', () {
      final schoolTourney = state.tournaments.firstWhere((t) => t.id == 'school_intrams');
      final streetTourney = state.tournaments.firstWhere((t) => t.id == 'purok_bakbakan');

      // Varsity student in month 9 (September)
      state.fighter.academics = 85.0;
      expect(schoolTourney.isEligible(state.fighter, 9), isTrue);

      // Student suspended due to low grade
      state.fighter.academics = 74.0;
      expect(schoolTourney.isEligible(state.fighter, 9), isFalse);

      // Street track remains open regardless of grade
      expect(streetTourney.isEligible(state.fighter, 1), isTrue);
    });

    test('Tournament Bracketing: Single-elimination bracket advances from Semis to Finals', () {
      final tourney = state.tournaments.firstWhere((t) => t.id == 'purok_bakbakan');
      final bracket = tourney.bracket;
      expect(bracket, isNotNull);
      expect(bracket!.matches.length, 3); // Semis A, Semis B, Championship Final

      final activeMatch = bracket.activePlayerMatch;
      expect(activeMatch, isNotNull);
      expect(activeMatch!.stageName, 'Semi-Finals A');

      // Win Semifinal A
      final opp1 = activeMatch.fighter2Data!;
      state.handleBracketMatchResult(
        tournament: tourney,
        currentOpponent: opp1,
        won: true,
        maxDamage: 35,
      );

      // Verify Semifinals B was simulated and Championship Final is now populated with Bayani
      expect(bracket.matches[0].isCompleted, isTrue);
      expect(bracket.matches[0].winnerName, state.fighter.name);
      expect(bracket.matches[1].isCompleted, isTrue); // AI vs AI completed
      expect(bracket.matches[2].fighter1Name, state.fighter.name);
      expect(bracket.matches[2].fighter2Name, isNotEmpty);
      expect(bracket.currentRoundIndex, 1);

      // Win Championship Final
      final finalsOpponent = bracket.matches[2].fighter2Data!;
      state.handleBracketMatchResult(
        tournament: tourney,
        currentOpponent: finalsOpponent,
        won: true,
        maxDamage: 45,
      );

      expect(bracket.isFinished, isTrue);
      expect(tourney.isCompleted, isTrue);
    });

    test('Opponent Head-to-Head Dossier: Tracks matches, wins, losses, peak damage, and dates', () {
      final tourney = state.tournaments.firstWhere((t) => t.id == 'purok_bakbakan');
      final opponent = tourney.rounds.first;

      final initialRecord = state.opponentRecords[opponent.name];
      final initialMatches = initialRecord?.matchesFought ?? 0;
      final initialWins = initialRecord?.wins ?? 0;

      // Simulate a victory
      state.recordOpponentMatch(
        opponent: opponent,
        won: true,
        maxDamage: 38,
      );

      final updatedRecord = state.opponentRecords[opponent.name]!;
      expect(updatedRecord.matchesFought, initialMatches + 1);
      expect(updatedRecord.wins, initialWins + 1);
      expect(updatedRecord.highestDamageDealt, greaterThanOrEqualTo(38));
      expect(updatedRecord.lastResult, 'PANALO');
      expect(updatedRecord.lastEncounter, contains('Yr 1'));
    });
  });
}
