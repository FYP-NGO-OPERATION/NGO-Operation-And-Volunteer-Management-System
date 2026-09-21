import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ngo_volunteer_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('App starts and shows splash or auth screen', (tester) async {
      // Launch the app
      app.main();
      
      // Wait for app to render and settle
      await tester.pumpAndSettle();

      // Verify no exceptions were thrown during launch
      expect(find.byType(app.MyApp), findsOneWidget);
    });
  });
}
