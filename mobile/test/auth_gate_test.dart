import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/main.dart';

class _MockUser extends Mock implements User {}

void main() {
  group('AuthGate state management', () {
    testWidgets('shows a loading state until authentication is resolved', (
      tester,
    ) async {
      final authController = StreamController<User?>();

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateChanges: () => authController.stream),
        ),
      );

      expect(find.text('Checking your authentication...'), findsOneWidget);

      await authController.close();
    });
    testWidgets('shows the login form when signed out', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateChanges: () => Stream<User?>.value(null)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New user? Create an account'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
    testWidgets('shows the splash screen when signed in', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(
            authStateChanges: () => Stream<User?>.value(_MockUser()),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('DairyTrace'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Dispose of the splash screen before delayed navigation
      // can initialize Firestore.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('retries authentication after a stream error', (tester) async {
      var streamRequests = 0;

      Stream<User?> authStateChanges() {
        streamRequests++;

        if (streamRequests == 1) {
          return Stream<User?>.error(
            StateError('Temporary auth stream failure'),
          );
        }

        return Stream<User?>.value(null);
      }

      await tester.pumpWidget(
        MaterialApp(home: AuthGate(authStateChanges: authStateChanges)),
      );

      await tester.pump();

      expect(
        find.text('Unable to check your account. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      await tester.pump();

      expect(streamRequests, 2);
      expect(find.text('Sign In'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
