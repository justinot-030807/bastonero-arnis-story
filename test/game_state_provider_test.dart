import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/providers/game_state_provider.dart';
import 'package:bastonero_arnis_story/models/facility_model.dart';
import 'package:bastonero_arnis_story/models/fighter_model.dart';
import 'package:bastonero_arnis_story/models/tournament_model.dart';

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

    test('Gym Facilities: Building, Upgrades, Expansion to 8 slots, and Synergies', () {
      state.pesos = 5000; // grant testing funds

      // Build Buko Stand in slot 2 (adjacent to starter Gulong in slot 0 or desk in slot 1)
      // Starter slots: [0: Gulong, 1: Study Desk]
      // Build Footwork in slot 2, Buko Stand in slot 3
      state.buildFacility(2, FacilityType.footworkTires);
      state.buildFacility(3, FacilityType.bukoStand);

      expect(state.slots[2]?.type, FacilityType.footworkTires);
      expect(state.slots[3]?.type, FacilityType.bukoStand);

      // Verify active synergies include Hydration Rush or Presko Training
      final synergies = state.activeSynergies;
      expect(synergies, isNotEmpty);

      // Expand gym slots from 4 to 8
      expect(state.maxSlots, 4);
      final expanded = state.expandGymSlots();
      expect(expanded, isTrue);
      expect(state.maxSlots, 8);
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
  });
}
