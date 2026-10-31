import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/main.dart';

void main() {
  testWidgets('Bastonero App launches Title Screen and renders menu options', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const BastoneroApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Title Screen elements render
    expect(find.text('BASTONERO'), findsNWidgets(3)); // Stacked embossed title
    expect(find.text('PANGUNAHING MENYU'), findsOneWidget);
    expect(find.textContaining('BAGONG LARO'), findsOneWidget);
    expect(find.textContaining('SAVE SLOTS'), findsOneWidget);
    expect(find.textContaining('SETTINGS'), findsOneWidget);
  });
}
