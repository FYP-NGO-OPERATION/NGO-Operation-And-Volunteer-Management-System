import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_volunteer_app/providers/auth_provider.dart';
import 'package:ngo_volunteer_app/screens/shop/shop_list_screen.dart';

import 'package:ngo_volunteer_app/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ngo_volunteer_app/services/shop_service.dart';

void main() {
  group('ShopListScreen A11y Tests', () {
    testWidgets('ShopListScreen renders Semantics label for Add to Cart button', (WidgetTester tester) async {
      final fakeFirestore = FakeFirebaseFirestore();
      
      // Inject product data
      await fakeFirestore.collection('products').add({
        'name': 'Charity Mug',
        'price': 250.0,
        'stock': 10,
        'image': '',
        'category': 'Merch',
      });

      // Override global DI if ShopService supports it (or mock the UI behavior).
      // Here we assume ShopService uses the default instance unless mocked, but we just want to verify the render tree.
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(create: (_) {
              final auth = AuthProvider();
              // In a real mock, you'd set auth.user here
              return auth;
            }),
          ],
          child: MaterialApp(
            home: ShopListScreen(
              shopService: ShopService(db: fakeFirestore),
            ),
          ),
        ),
      );

      // The list might load asynchronously. We can just test the Semantics node structure on a fake product card directly,
      // or pump.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // allow streams to emit
      await tester.pump();

      // Find Semantics nodes that have "Add Charity Mug to cart for 250.00 Rupees"
      final semanticsNode = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Add Charity Mug to cart for 250.00 Rupees' &&
            widget.properties.button == true,
      );

      // It may fail to find it if NetworkImage is trying to load ''. We'll rely on the structure.
      // Assuming empty list or NetworkImage handled, we look for the Semantics widget.
      // If image fails, errorWidget is shown, UI continues rendering.
      expect(semanticsNode, findsOneWidget);
    });
  });
}
