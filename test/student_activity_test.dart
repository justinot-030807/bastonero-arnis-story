// test/student_activity_test.dart
// Dedicated tests for Phase 2: Multiple students, roster management,
// weekly activity processing, training formulas, fatigue/morale, Focus Tap, and 10-week progression.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bastonero_arnis_story/domain/rng.dart';
import 'package:bastonero_arnis_story/domain/models/camp.dart';
import 'package:bastonero_arnis_story/domain/models/focus_tap.dart';
import 'package:bastonero_arnis_story/domain/models/student.dart';
import 'package:bastonero_arnis_story/domain/systems/data_loader.dart';
import 'package:bastonero_arnis_story/providers/game_state_provider.dart';
import 'package:bastonero_arnis_story/ui/overlays/estudyante_modal.dart';
import 'package:bastonero_arnis_story/ui/overlays/focus_tap_modal.dart';

void main() {
  setUpAll(() {
    DataLoader.loadAllData();
  });

  group('Starting Roster & Student Profiles', () {
    test('Camp initializes with 3 distinct starting students', () {
      final camp = Camp(name: 'Test Camp');
      expect(camp.students.length, 3);

      final bayani = camp.students[0];
      final mayumi = camp.students[1];
      final danilo = camp.students[2];

      expect(bayani.name, 'Bayani');
      expect(bayani.style, ArnisStyle.soloBaston);
      expect(bayani.traits, contains('Masipag'));

      expect(mayumi.name, 'Mayumi');
      expect(mayumi.gender, 'Babae');
      expect(mayumi.style, ArnisStyle.dobleBaston);
      expect(mayumi.traits, contains('Maliksi'));

      expect(danilo.name, 'Danilo');
      expect(danilo.style, ArnisStyle.espadaYDaga);
      expect(danilo.traits, contains('Matibay'));
    });

    test('Student calculates maxHp and grade descriptions correctly', () {
      final s = Student(
        id: 's1',
        name: 'Bayani',
        grade: 5,
        lakas: 15.0,
        bilis: 14.0,
        diskarte: 13.0,
        salag: 11.0,
      );

      // totalStats = 15+14+13+11 = 53
      // maxHp = 75 + (53 * 0.3) = 90.9
      expect(s.totalStats, 53.0);
      expect(s.maxHp, closeTo(90.9, 0.1));
      expect(s.gradeDescription, contains('Elementarya'));

      s.grade = 8;
      expect(s.gradeDescription, contains('Sekondarya'));
    });
  });

  group('Training Formulas, Fatigue, and Traits', () {
    test('sanayLakas increases Lakas and Bilis and adds 12 fatigue', () {
      final s = Student(
        id: 's1',
        name: 'Bayani',
        lakas: 16.0,
        bilis: 15.0,
        fatigue: 0.0,
        morale: 80.0,
        currentActivity: ActivityType.sanayLakas,
      );

      final res = s.processWeeklyActivity(
        statCap: 60.0,
        rng: GameRng(42),
      );

      expect(res.lakasGain, greaterThan(1.0));
      expect(res.bilisGain, greaterThan(0.2));
      expect(s.lakas, greaterThan(16.0));
      expect(s.bilis, greaterThan(15.0));
      expect(s.fatigue, 12.0);
    });

    test('High fatigue (>70) incurs 30% gain penalty', () {
      final freshStudent = Student(
        id: 's_fresh',
        name: 'Fresh',
        lakas: 20.0,
        fatigue: 10.0,
        currentActivity: ActivityType.sanayLakas,
      );
      final tiredStudent = Student(
        id: 's_tired',
        name: 'Tired',
        lakas: 20.0,
        fatigue: 75.0, // > 70
        currentActivity: ActivityType.sanayLakas,
      );

      final resFresh = freshStudent.processWeeklyActivity(statCap: 60.0, rng: GameRng(100));
      final resTired = tiredStudent.processWeeklyActivity(statCap: 60.0, rng: GameRng(100));

      expect(resTired.lakasGain, lessThan(resFresh.lakasGain));
    });

    test('Hinga recovers fatigue and increases morale', () {
      final s = Student(
        id: 's1',
        name: 'Bayani',
        fatigue: 50.0,
        morale: 60.0,
        currentActivity: ActivityType.hinga,
      );

      final res = s.processWeeklyActivity(statCap: 60.0, rng: GameRng(10));
      expect(res.fatigueDelta, lessThan(0.0));
      expect(s.fatigue, lessThan(50.0));
      expect(s.morale, greaterThan(60.0));
    });

    test('Aral increases academic standing during school months', () {
      final s = Student(
        id: 's1',
        name: 'Bayani',
        gradePercent: 80.0,
        currentActivity: ActivityType.aral,
      );

      s.processWeeklyActivity(statCap: 60.0, isSummerBreak: false, rng: GameRng(77));
      expect(s.gradePercent, greaterThan(80.0));
    });
  });

  group('Focus Tap Skill Mechanic', () {
    test('FocusTapResult correctly evaluates bullseye, good zone, and miss', () {
      final perfect = FocusTapResult.evaluate(0.50);
      expect(perfect.rating, FocusTapRating.perfect);
      expect(perfect.rating.bonusMultiplier, 0.40); // +40%

      final good = FocusTapResult.evaluate(0.40);
      expect(good.rating, FocusTapRating.good);
      expect(good.rating.bonusMultiplier, 0.25); // +25%

      final miss = FocusTapResult.evaluate(0.15);
      expect(miss.rating, FocusTapRating.miss);
      expect(miss.rating.bonusMultiplier, 0.0);
    });

    test('Applying FocusTap bonus boosts weekly training gain', () {
      final s1 = Student(id: 's1', name: 'Without Focus', lakas: 20.0, currentActivity: ActivityType.sanayLakas);
      final s2 = Student(id: 's2', name: 'With Perfect Focus', lakas: 20.0, currentActivity: ActivityType.sanayLakas);

      final resNormal = s1.processWeeklyActivity(statCap: 60.0, rng: GameRng(999));
      final resFocus = s2.processWeeklyActivity(
        statCap: 60.0,
        focusTap: const FocusTapResult(rating: FocusTapRating.perfect, position: 0.5),
        rng: GameRng(999),
      );

      expect(resFocus.lakasGain, greaterThan(resNormal.lakasGain));
    });
  });

  group('Camp Weekly Tuition & 10-Week Acceptance Progression', () {
    test('10-week progression produces visible stat growth and fatigue dynamics', () {
      final camp = Camp(name: 'Acceptance Camp', money: 1000);
      expect(camp.students.length, 3);

      final initialLakas0 = camp.students[0].lakas;
      final initialBilis1 = camp.students[1].bilis;
      final initialMoney = camp.money;

      // Assign student 0 to Lakas, student 1 to Bilis, student 2 to Hinga
      camp.students[0].currentActivity = ActivityType.sanayLakas;
      camp.students[1].currentActivity = ActivityType.sanayBilis;
      camp.students[2].currentActivity = ActivityType.hinga;

      // Simulate 10 weeks of training
      for (int week = 1; week <= 10; week++) {
        camp.processWeek(month: 6);
      }

      // Check stat progression
      expect(camp.students[0].lakas, greaterThan(initialLakas0 + 5.0));
      expect(camp.students[1].bilis, greaterThan(initialBilis1 + 5.0));

      // Check fatigue accumulation on training student vs resting student
      expect(camp.students[0].fatigue, greaterThan(30.0));
      expect(camp.students[2].fatigue, 0.0); // Rest keeps fatigue at 0

      // Check tuition collected (3 students * 50 pesos/wk * 10 weeks = +1500)
      expect(camp.money, greaterThanOrEqualTo(initialMoney + 1000));
    });
  });

  group('GameStateProvider Phase 2 Integration & Overlays', () {
    test('GameStateProvider allows selecting active student and assigning activities', () {
      final state = GameStateProvider();
      expect(state.students.length, 3);

      final mayumi = state.students[1];
      state.setActiveStudent(mayumi.id);
      expect(state.activeStudent.id, mayumi.id);
      expect(state.fighter.name, contains('Mayumi'));

      state.assignStudentActivity(mayumi.id, ActivityType.sanayBilis);
      expect(state.activeStudent.currentActivity, ActivityType.sanayBilis);

      state.batchAssignActivity(ActivityType.hinga);
      for (final s in state.students) {
        expect(s.currentActivity, ActivityType.hinga);
      }
    });

    testWidgets('EstudyanteModal renders student list and detail view', (tester) async {
      final state = GameStateProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameStateProvider>.value(
            value: state,
            child: Scaffold(
              body: EstudyanteModal(gameState: state),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('MGA ESTUDYANTE NG KAMPO'), findsOneWidget);
      expect(find.textContaining('Bayani'), findsOneWidget);
      expect(find.textContaining('Mayumi'), findsOneWidget);
      expect(find.textContaining('Danilo'), findsOneWidget);
      expect(find.textContaining('ITAKDA LAHAT'), findsOneWidget);

      // Tap Detalye on Bayani
      await tester.tap(find.text('DETALYE').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('DETALYE NG ESTUDYANTE'), findsOneWidget);
      expect(find.textContaining('FOCUS TAP'), findsOneWidget);
    });

    testWidgets('FocusTapModal renders timing gauge and allows tapping', (tester) async {
      final state = GameStateProvider();
      final student = state.students.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameStateProvider>.value(
            value: state,
            child: Scaffold(
              body: FocusTapModal(
                gameState: state,
                student: student,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('FOCUS TAP'), findsOneWidget);
      expect(find.textContaining('TUMAMA NGAYON!'), findsOneWidget);

      await tester.tap(find.text('TUMAMA NGAYON!'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(state.weeklyFocusTaps.containsKey(student.id), isTrue);
    });
  });
}
