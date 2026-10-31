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
    await tester.pump();

    // Tap NEW in Slot 1
    expect(find.text('MGA SAVE SLOTS (PUMILI NG SLOT)'), findsOneWidget);
    await tester.tap(find.text('NEW').first);
    await tester.pump();

    // Now inside Bakuran Camp
    expect(find.textContaining('BAKURAN TRAINING CAMP'), findsOneWidget);
    expect(find.text('SANAY'), findsOneWidget);
    expect(find.text('ARAL'), findsOneWidget);
  });
}
