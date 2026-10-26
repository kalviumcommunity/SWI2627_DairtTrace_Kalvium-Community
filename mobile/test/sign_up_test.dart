import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/main.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('User sign up', () {
    testWidgets('validates required and malformed input before registration', (
      tester,
    ) async {
      final auth = _MockFirebaseAuth();

      await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
      await tester.tap(find.text('New user? Create an account'));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), '12345');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters.'),
        findsOneWidget,
      );
      verifyNever(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('creates an account with trimmed email and entered password', (
      tester,
    ) async {
      final auth = _MockFirebaseAuth();
      final credential = _MockUserCredential();
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => credential);

      await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
      await tester.tap(find.text('New user? Create an account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  farmer@example.com  ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secure123');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      verify(
        () => auth.createUserWithEmailAndPassword(
          email: 'farmer@example.com',
          password: 'secure123',
        ),
      ).called(1);
      expect(find.text('Register'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsNothing,
      );
    });

    testWidgets('shows an actionable message when the email is already used', (
      tester,
    ) async {
      final auth = _MockFirebaseAuth();
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
      await tester.tap(find.text('New user? Create an account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'farmer@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secure123');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('This email is already registered.'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets(
      'shows password guidance when Firebase rejects a weak password',
      (tester) async {
        final auth = _MockFirebaseAuth();
        when(
          () => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: 'weak-password'));

        await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
        await tester.tap(find.text('New user? Create an account'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'farmer@example.com',
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'secure123');
        await tester.tap(find.text('Register'));
        await tester.pumpAndSettle();

        expect(find.text('Choose a stronger password.'), findsOneWidget);
        expect(find.text('Register'), findsOneWidget);
      },
    );
  });
}
