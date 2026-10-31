// test/economy_calendar_test.dart
// PURE RETRO TESTS - Phase 3 Economy, Calendar, Bailout, and Eligibility verification.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bastonero_arnis_story/domain/balance.dart';
import 'package:bastonero_arnis_story/domain/models/monthly_ledger.dart';
import 'package:bastonero_arnis_story/domain/models/student.dart';
import 'package:bastonero_arnis_story/domain/models/trainer.dart';
import 'package:bastonero_arnis_story/domain/systems/data_loader.dart';
import 'package:bastonero_arnis_story/providers/game_state_provider.dart';
import 'package:bastonero_arnis_story/ui/overlays/monthly_summary_modal.dart';

void main() {
  setUpAll(() {
    DataLoader.loadAllData();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 3 - Economy, Tuition, and Upkeep Tests', () {
    test('Weekly tuition and store passive income accrue properly', () {
      final state = GameStateProvider();
      state.enterGame();
      state.autoPause();

      // Initial state: 3 students paying 50 each = 150/week
      final initialPesos = state.pesos;
      state.advanceOneWeek();

      // Pesos should have grown by at least weekly tuition (150)
      expect(state.pesos, greaterThanOrEqualTo(initialPesos + 150));
      expect(state.currentMonthTuition, 150);
    });

    test('Month-end rollover deducts upkeep and trainer salaries and creates MonthlyLedger', () {
      final state = GameStateProvider();
      state.enterGame();
      state.autoPause();

      // Add a trainer with 600 monthly salary
      state.camp.trainers.add(
        const Trainer(id: 'guro_kanor', name: 'Guro Kanor', specialty: 'lakas', salary: 600),
      );

      // We start at Week 1. Advance through Weeks 1, 2, 3, 4 to reach month-end.
      state.advanceOneWeek(); // Week 1 -> 2
      state.advanceOneWeek(); // Week 2 -> 3
      state.advanceOneWeek(); // Week 3 -> 4
      expect(state.week, 4);
      expect(state.shouldShowMonthlySummary, false);

      // Now advance from Week 4 -> triggers month rollover!
      state.advanceOneWeek();
      expect(state.week, 1);
      expect(state.month, 7); // Rolled from Month 6 (June) to Month 7 (July)
      expect(state.shouldShowMonthlySummary, true);
      expect(state.lastMonthlyLedger, isNotNull);

      final ledger = state.lastMonthlyLedger!;
      expect(ledger.month, 6);
      expect(ledger.year, 1);
      // Upkeep for 1 floor = 100 + 1*80 = 180
      expect(ledger.upkeepDeduction, 180);
      expect(ledger.trainerSalaries, 600);
      expect(ledger.tuitionIncome, greaterThan(0));
      expect(ledger.totalExpenses, 180 + 600);
    });

    test('Safety Net: Bailout loan triggers when money drops below 0', () {
      final state = GameStateProvider();
      state.enterGame();
      state.autoPause();

      // Force money low so upkeep + salaries make it negative
      state.pesos = 50;
      state.camp.money = 50;

      // Add expensive trainers to cause deficit
      state.camp.trainers.add(
        const Trainer(id: 'guro_pro', name: 'Master Arnis', specialty: 'all', salary: 1200),
      );

      // Advance to week 4 then trigger rollover
      state.week = 4;
      state.advanceOneWeek(); // Month end rollover

      expect(state.shouldShowMonthlySummary, true);
      expect(state.lastMonthlyLedger!.hadBailout, true);
      expect(state.lastMonthlyLedger!.bailoutGranted, Balance.bailoutLoanAmount);
      // Bailout should keep funds positive
      expect(state.pesos, greaterThan(0));
      expect(state.bailoutWeeksRemaining, 8);
      expect(state.hasActiveBailout, true);

      // Verify weekly repayment is deducted in subsequent weeks
      final fundsBeforeRepay = state.pesos;
      state.advanceOneWeek();
      expect(state.bailoutWeeksRemaining, 7);
      expect(state.currentMonthDebtPaid, 250);
      expect(state.pesos, lessThanOrEqualTo(fundsBeforeRepay));
    });
  });

  group('Phase 3 - School Year, Summer Break, and Academic Eligibility', () {
    test('School months (June-March) cause academic grade decay if not studying', () {
      final state = GameStateProvider();
      state.enterGame();
      state.autoPause();

      state.month = 6; // June (School month)
      final initialGrade = state.activeStudent.gradePercent;

      // Train Power (not study)
      state.performTraining(ActionType.trainPower);
      expect(state.activeStudent.gradePercent, lessThan(initialGrade));
      expect(state.fighter.academics, lessThan(initialGrade));
    });

    test('Summer Break (April & May) freezes academic grade decay', () {
      final state = GameStateProvider();
      state.enterGame();
      state.autoPause();

      state.month = 4; // April (Summer break)
      expect(state.isSummerBreak, true);

      final initialGrade = state.activeStudent.gradePercent;
      state.performTraining(ActionType.trainPower);

      // In summer break, academics should not decay!
      expect(state.activeStudent.gradePercent, equals(initialGrade));
      expect(state.fighter.academics, equals(initialGrade));
    });

    test('Academic standing flags: Varsity eligible, warning, and suspended', () {
      final student = Student(
        id: 'std_test',
        name: 'Ramon',
        gradePercent: 85.0,
      );

      // Above 80: fully eligible
      expect(student.isVarsityEligible, true);
      expect(student.isIntramsEligible, true);
      expect(student.isAcademicWarning, false);
      expect(student.isFailing, false);

      // 78%: warning / not eligible for Intrams, but varsity minimum is 75
      student.gradePercent = 78.0;
      expect(student.isVarsityEligible, true);
      expect(student.isIntramsEligible, false);
      expect(student.isAcademicWarning, true);
      expect(student.isFailing, false);

      // 72%: failing / completely suspended
      student.gradePercent = 72.0;
      expect(student.isVarsityEligible, false);
      expect(student.isIntramsEligible, false);
      expect(student.isAcademicWarning, true);
      expect(student.isFailing, true);
    });
  });

  group('Phase 3 - Speed Control & MonthlySummaryModal UI', () {
    test('Speed control transitions cleanly between pause, 1x, 2x, 4x', () {
      final state = GameStateProvider();
      expect(state.speed, GameSpeed.pause);

      state.setSpeed(GameSpeed.normal1x);
      expect(state.speed, GameSpeed.normal1x);

      state.setSpeed(GameSpeed.fast2x);
      expect(state.speed, GameSpeed.fast2x);

      state.setSpeed(GameSpeed.fast4x);
      expect(state.speed, GameSpeed.fast4x);

      state.autoPause();
      expect(state.speed, GameSpeed.pause);
    });

    testWidgets('MonthlySummaryModal displays financial report and dismisses', (WidgetTester tester) async {
      const ledger = MonthlyLedger(
        month: 6,
        year: 1,
        startingMoney: 650,
        tuitionIncome: 600,
        passiveIncome: 240,
        sponsorIncome: 0,
        prizeIncome: 500,
        upkeepDeduction: 180,
        trainerSalaries: 600,
        debtRepayment: 0,
        bailoutGranted: 0,
        endingMoney: 1210,
      );

      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlySummaryModal(
              ledger: ledger,
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify UI text renders
      expect(find.text('BUWANANG ULAT SA KEUWANGAN'), findsOneWidget);
      expect(find.text('+P600'), findsOneWidget); // tuition
      expect(find.text('-P180'), findsOneWidget); // upkeep
      expect(find.text('P1210'), findsOneWidget); // ending balance
      expect(find.text('TANGGAPIN AT MAGPATULOY'), findsOneWidget);

      // Tap dismiss
      await tester.tap(find.text('TANGGAPIN AT MAGPATULOY'));
      await tester.pump();
      expect(dismissed, true);
    });
  });
}
