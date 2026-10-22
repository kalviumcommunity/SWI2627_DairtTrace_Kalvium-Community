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
      final authState = StreamController<User?>();

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateChanges: () => authState.stream),
        ),
      );

      expect(find.text('Checking your authentication...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await authState.close();
    });

    testWidgets('shows the login form when signed out', (tester) async {
      final authState = StreamController<User?>();

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateChanges: () => authState.stream),
        ),
      );
      authState.add(null);
      await tester.pump();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New user? Create an account'), findsOneWidget);

      await authState.close();
    });

    testWidgets('shows the splash screen when signed in', (tester) async {
      final authState = StreamController<User?>();

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authStateChanges: () => authState.stream),
        ),
      );
      authState.add(_MockUser());
      await tester.pump();

      expect(find.text('DairyTrace'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      await authState.close();
    });

    testWidgets('retries authentication after a stream error', (tester) async {
      final firstAuthState = StreamController<User?>();
      final retryAuthState = StreamController<User?>();
      var streamRequests = 0;

      Stream<User?> authStateChanges() {
        streamRequests++;
        return streamRequests == 1
            ? firstAuthState.stream
            : retryAuthState.stream;
      }

      await tester.pumpWidget(
        MaterialApp(home: AuthGate(authStateChanges: authStateChanges)),
      );
      firstAuthState.addError(StateError('Temporary auth stream failure'));
      await tester.pump();

      expect(
        find.text('Unable to check your account. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      retryAuthState.add(null);
      await tester.pump();

      expect(streamRequests, 2);
      expect(find.text('Sign In'), findsOneWidget);

      await firstAuthState.close();
      await retryAuthState.close();
    });
  });
}
