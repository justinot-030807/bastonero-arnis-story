import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/main.dart';

void main() {
  testWidgets('Bastonero App launches Title Screen and enters training camp', (WidgetTester tester) async {
    await tester.pumpWidget(const BastoneroApp());
    await tester.pump();

    // Verify Title Screen elements render
    expect(find.text('BASTONERO'), findsNWidgets(3)); // Stacked embossed title
    expect(find.text('PANGUNAHING MENYU'), findsOneWidget);
    expect(find.textContaining('BAGONG LARO'), findsOneWidget);

    // Tap BAGONG LARO to open save slots
    await tester.tap(find.textContaining('BAGONG LARO'));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap NEW in Slot 1
    expect(find.text('MGA SAVE SLOTS (PUMILI NG SLOT)'), findsOneWidget);
    await tester.tap(find.text('NEW').first);
    await tester.pump(const Duration(milliseconds: 300));

    // Character & Coach Creator Modal appears
    expect(find.textContaining('PAGLIKHA NG ARNISADOR AT COACH'), findsOneWidget);
    await tester.tap(find.textContaining('SIMULAN ANG PAGLALAKBAY'));
    await tester.pump(const Duration(milliseconds: 300));

    // Advance story prologue dialogue
    while (find.textContaining('SUNOD >>').evaluate().isNotEmpty) {
      await tester.tap(find.textContaining('SUNOD >>').first);
      await tester.pump(const Duration(milliseconds: 300));
    }
    if (find.textContaining('SIGE! (CONFIRM)').evaluate().isNotEmpty) {
      await tester.tap(find.textContaining('SIGE! (CONFIRM)').first);
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Now inside Bakuran Camp
    expect(find.textContaining('BAKURAN TRAINING CAMP'), findsOneWidget);
    expect(find.text('SANAY'), findsOneWidget);
    expect(find.text('ARAL'), findsOneWidget);
  });
}
