import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/main.dart';

void main() {
  testWidgets('Bastonero App launches and displays training camp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BastoneroApp());
    await tester.pump();

    // Verify key UI elements render
    expect(find.textContaining('BAKURAN TRAINING CAMP'), findsOneWidget);
    expect(find.text('SANAY'), findsOneWidget);
    expect(find.text('ARAL'), findsOneWidget);
  });
}
