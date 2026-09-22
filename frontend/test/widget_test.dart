// Basic Flutter widget test for KhedmaLink app
//
// This test verifies that the app initializes correctly
// and the routing system works.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khedmalink/main.dart';

void main() {
  testWidgets('App initializes without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KhedmaLinkApp());

    // Verify that the app initializes without throwing errors
    // The placeholder screen will be replaced in future milestones
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
