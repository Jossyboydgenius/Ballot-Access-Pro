import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  // Simple test to verify that we can create a GoogleMap widget
  testWidgets('Google Map can be created', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 10,
            ),
            onMapCreated: (GoogleMapController controller) {},
          ),
        ),
      ),
    );

    // This test will pass if the GoogleMap widget renders without errors
    expect(find.byType(GoogleMap), findsOneWidget);
  });
}
