// Basic widget test for CropClaim AI app

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const CropClaimApp());

    // Verify that splash screen loads
    expect(find.text('CropClaim AI'), findsOneWidget);
    expect(
      find.text('Instant Crop Damage Assessment\nfor PMFBY'),
      findsOneWidget,
    );
  });
}
