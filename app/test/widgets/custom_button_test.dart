import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_volunteer_app/widgets/common/custom_button.dart';

void main() {
  group('CustomButton UI Throttling Tests', () {
    testWidgets('CustomButton calls onPressed when tapped and not loading', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Test Button',
            onPressed: () => pressed = true,
            isLoading: false,
          ),
        ),
      ));

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('CustomButton blocks multiple rapid taps while isLoading', (WidgetTester tester) async {
      int pressCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Loading Button',
            onPressed: () => pressCount++,
            isLoading: true,
          ),
        ),
      ));

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      // Verify that the CircularProgressIndicator is showing
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Attempt to tap multiple times
      await tester.tap(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Because isLoading is true, onPressed should be null in ElevatedButton
      final elevatedButton = tester.widget<ElevatedButton>(buttonFinder);
      expect(elevatedButton.onPressed, isNull);

      // Verify no clicks were registered
      expect(pressCount, 0);
    });
  });
}
