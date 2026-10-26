
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/collection.dart';
import 'package:mobile/services/collection_service.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockCollectionService extends Mock implements CollectionService {}

void main() {
  group('Firebase startup errors', () {
    testWidgets('shows recovery guidance when Firebase cannot start', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirebaseStartupErrorScreen()),
      );

      expect(find.text('Unable to start DairyTrace'), findsOneWidget);
      expect(find.textContaining('restart the app'), findsOneWidget);
    });
  });

  group('Authentication errors', () {
    testWidgets('hides raw messages for unmapped Firebase auth errors', (
      tester,
    ) async {
      final auth = _MockFirebaseAuth();
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'unknown-error',
          message: 'internal backend details',
        ),
      );

      await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'farmer@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
        find.text('Authentication failed. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('internal backend details'), findsNothing);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('maps known Firebase auth errors to actionable messages', (
      tester,
    ) async {
      final auth = _MockFirebaseAuth();
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Internal network details',
        ),
      );

      await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'farmer@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Check your internet connection.'), findsOneWidget);
      expect(find.text('Internal network details'), findsNothing);
    });

    testWidgets('shows a safe message for unexpected sign-in failures', (
      tester,
    ) async {
      final auth = _MockFirebaseAuth();
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(StateError('internal backend details'));

      await tester.pumpWidget(MaterialApp(home: LoginPage(auth: auth)));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'farmer@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('internal backend details'), findsNothing);
    });
  });

  group('Collection list errors', () {
    testWidgets('retries the stream after a collection load failure', (
      tester,
    ) async {
      final service = _MockCollectionService();
      var streamRequests = 0;
      when(() => service.watchCollections()).thenAnswer((_) {
        streamRequests++;
        if (streamRequests == 1) {
          return Stream<List<Collection>>.error(
            StateError('Temporary Firestore failure'),
          );
        }
        return Stream<List<Collection>>.value([]);
      });

      await tester.pumpWidget(
        MaterialApp(home: MilkCollectionPage(collectionService: service)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Unable to load collections'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.ensureVisible(find.text('Try Again'));
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(streamRequests, 2);
      expect(
        find.text('No collections yet. Record your first collection.'),
        findsOneWidget,
      );
    });

    testWidgets('shows a permission error and preserves form values on save', (
      tester,
    ) async {
      final service = _MockCollectionService();
      when(
        () => service.watchCollections(),
      ).thenAnswer((_) => Stream<List<Collection>>.value([]));
      when(
        () => service.addCollection(
          farmerName: any(named: 'farmerName'),
          quantityLitres: any(named: 'quantityLitres'),
        ),
      ).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Internal Firestore details',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: MilkCollectionPage(collectionService: service)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Farmer Name');
      await tester.enterText(find.byType(TextFormField).at(1), '12.5');
      await tester.ensureVisible(find.text('Save Collection'));
      await tester.tap(find.text('Save Collection'));
      await tester.pumpAndSettle();

      expect(
        find.text('Access denied. Check your Firestore security rules.'),
        findsNWidgets(2),
      );
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(fields[0].controller?.text, 'Farmer Name');
      expect(fields[1].controller?.text, '12.5');
      expect(find.text('Internal Firestore details'), findsNothing);
    });

    testWidgets('notifies the user when sign-out fails', (tester) async {
      final auth = _MockFirebaseAuth();
      final service = _MockCollectionService();
      when(
        () => service.watchCollections(),
      ).thenAnswer((_) => Stream<List<Collection>>.value([]));
      when(
        () => auth.signOut(),
      ).thenThrow(StateError('internal sign-out details'));

      await tester.pumpWidget(
        MaterialApp(
          home: MilkCollectionPage(collectionService: service, auth: auth),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();

      expect(
        find.text('Unable to sign out. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('DairyTrace'), findsOneWidget);
    });

    testWidgets('shows a safe message when collection deletion is denied', (
      tester,
    ) async {
      final service = _MockCollectionService();
      when(() => service.watchCollections()).thenAnswer(
        (_) => Stream<List<Collection>>.value([
          const Collection(
            id: 'collection-1',
            farmerName: 'Farmer Name',
            quantityLitres: 12.5,
            collectionDate: null,
            createdBy: 'user-1',
          ),
        ]),
      );
      when(
        () => service.deleteCollection(collectionId: 'collection-1'),
      ).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Internal Firestore details',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: MilkCollectionPage(collectionService: service)),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byTooltip('Delete collection'));
      await tester.tap(find.byTooltip('Delete collection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(
        find.text('Access denied. You cannot delete this collection.'),
        findsOneWidget,
      );
      expect(find.text('Internal Firestore details'), findsNothing);
    });

    testWidgets('shows a safe message when collection deletion fails', (
      tester,
    ) async {
      final service = _MockCollectionService();
      when(() => service.watchCollections()).thenAnswer(
        (_) => Stream<List<Collection>>.value([
          const Collection(
            id: 'collection-1',
            farmerName: 'Farmer Name',
            quantityLitres: 12.5,
            collectionDate: null,
            createdBy: 'user-1',
          ),
        ]),
      );
      when(
        () => service.deleteCollection(collectionId: 'collection-1'),
      ).thenThrow(StateError('Internal deletion details'));

      await tester.pumpWidget(
        MaterialApp(home: MilkCollectionPage(collectionService: service)),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byTooltip('Delete collection'));
      await tester.tap(find.byTooltip('Delete collection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(
        find.text('Could not delete the collection. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Internal deletion details'), findsNothing);
    });
  });
}
