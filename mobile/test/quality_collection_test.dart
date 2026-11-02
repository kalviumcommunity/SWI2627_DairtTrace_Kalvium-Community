import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/collection.dart';
import 'package:mobile/services/collection_service.dart';
import 'package:mobile/utils/quality_checker.dart';
import 'package:mobile/form_validators.dart';

class _Auth extends Mock implements FirebaseAuth {}

class _User extends Mock implements User {}

class _Service extends Mock implements CollectionService {}

void main() {
  late FakeFirebaseFirestore db;
  late _Auth auth;
  late CollectionService service;
  setUp(() {
    db = FakeFirebaseFirestore();
    auth = _Auth();
    final user = _User();
    when(() => user.uid).thenReturn('owner');
    when(() => auth.currentUser).thenReturn(user);
    service = CollectionService(firestore: db, auth: auth);
  });

  test('threshold boundaries are accepted; invalid readings cannot pass', () {
    expect(
      QualityChecker.check(fat: 3, snf: 8, temperature: 10).status,
      'ACCEPTED',
    );
    for (final bad in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
      -1.0,
    ]) {
      expect(
        () => QualityChecker.check(fat: bad, snf: 8, temperature: 6),
        throwsArgumentError,
      );
      expect(
        () => QualityChecker.check(fat: 4, snf: bad, temperature: 6),
        throwsArgumentError,
      );
      expect(
        () => QualityChecker.check(fat: 4, snf: 8, temperature: bad),
        throwsArgumentError,
      );
    }
    expect(
      () => QualityChecker.check(fat: 101, snf: 8, temperature: 6),
      throwsArgumentError,
    );
    expect(
      () => QualityChecker.check(fat: 4, snf: 101, temperature: 6),
      throwsArgumentError,
    );
  });

  test(
    'form requires finite, non-negative readings and bounded percentages',
    () {
      for (final input in [null, '', ' ', 'abc', 'NaN', 'Infinity', '-1']) {
        expect(
          validateQualityReading(input, label: 'Fat %', percentage: true),
          isNotNull,
        );
        expect(validateQualityReading(input, label: 'Temperature'), isNotNull);
      }
      expect(
        validateQualityReading('101', label: 'SNF %', percentage: true),
        isNotNull,
      );
      expect(
        validateQualityReading(' 8.5 ', label: 'SNF %', percentage: true),
        isNull,
      );
      expect(validateQualityReading('0', label: 'Temperature'), isNull);
    },
  );

  for (final alert in [false, true]) {
    test(
      'service persists ${alert ? 'alert' : 'accepted'} readings and round trips model',
      () async {
        final id = await service.addCollection(
          farmerName: '  Farmer Name ',
          quantityLitres: 12.5,
          fat: alert ? 2 : 4,
          snf: 8.5,
          temperature: 6,
        );
        final doc = await db.collection('collections').doc(id).get();
        final collection = Collection.fromFirestore(doc);
        expect(collection.farmerName, 'Farmer Name');
        expect(collection.createdBy, 'owner');
        expect(collection.quantityLitres, 12.5);
        expect(collection.fat, alert ? 2.0 : 4.0);
        expect(collection.snf, 8.5);
        expect(collection.temperature, 6.0);
        expect(collection.qualityStatus, alert ? 'ALERT' : 'ACCEPTED');
        expect(doc.data()!['createdAt'], isA<Timestamp>());
        expect(collection.collectionDate, isNotNull);
        expect(
          collection.toFirestore()['qualityStatus'],
          collection.qualityStatus,
        );
      },
    );
  }

  test(
    'legacy, null and malformed quality fields remain readable and unknown',
    () async {
      for (final extra in <Map<String, dynamic>>[
        {},
        {'fat': null, 'snf': null, 'temperature': null},
        {
          'fat': 'invalid',
          'snf': 8,
          'temperature': 6,
          'qualityStatus': 'ACCEPTED',
        },
      ]) {
        final ref = await db.collection('collections').add({
          'farmerName': 'Legacy Farmer',
          'quantityLitres': 10,
          'createdBy': 'owner',
          ...extra,
        });
        final item = Collection.fromFirestore(await ref.get());
        expect(item.fat, isNull);
        expect(item.qualityStatus, 'UNKNOWN');
        if (extra.isEmpty) {
          expect(item.toFirestore().containsKey('qualityStatus'), isFalse);
        }
        expect(item.quantityLitres, 10.0);
        expect(item.collectionDate, isNull);
      }
    },
  );

  test('service rejects invalid readings without writing', () async {
    for (final bad in [-1.0, double.nan, double.infinity, 101.0]) {
      await expectLater(
        service.addCollection(
          farmerName: 'Farmer Name',
          quantityLitres: 12,
          fat: bad,
          snf: 8.5,
          temperature: 6,
        ),
        throwsArgumentError,
      );
    }
    expect((await db.collection('collections').get()).docs, isEmpty);
  });

  test('service preserves sign-in requirement and owner filtering', () async {
    await service.addCollection(
      farmerName: 'My Farmer',
      quantityLitres: 12,
      fat: 4,
      snf: 8,
      temperature: 6,
    );
    await db.collection('collections').add({
      'farmerName': 'Other Farmer',
      'quantityLitres': 5,
      'createdBy': 'other',
      'collectionDate': Timestamp.now(),
    });
    expect(await service.watchCollections().first, hasLength(1));
    when(() => auth.currentUser).thenReturn(null);
    await expectLater(
      service.addCollection(
        farmerName: 'Farmer Name',
        quantityLitres: 12,
        fat: 4,
        snf: 8.5,
        temperature: 6,
      ),
      throwsStateError,
    );
    expect(() => service.watchCollections(), throwsStateError);
  });

  for (final alert in [false, true]) {
    testWidgets(
      'form saves ${alert ? 'ALERT' : 'ACCEPTED'}, clears readings and shows feedback',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: MilkCollectionPage(collectionService: service)),
        );
        await tester.pumpAndSettle();
        final values = ['Farmer Name', '12.5', alert ? '2' : '4', '8.5', '6'];
        for (var i = 0; i < values.length; i++) {
          await tester.enterText(find.byType(TextFormField).at(i), values[i]);
        }
        await tester.ensureVisible(find.text('Save Collection'));
        await tester.tap(find.text('Save Collection'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            alert
                ? 'Collection saved. Quality ALERT:'
                : 'Collection saved successfully!',
          ),
          findsWidgets,
        );
        final docs = (await db.collection('collections').get()).docs;
        expect(docs, hasLength(1));
        expect(
          docs.single.data()['qualityStatus'],
          alert ? 'ALERT' : 'ACCEPTED',
        );
        for (final field in tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        )) {
          expect(field.controller!.text, isEmpty);
        }
        await tester.ensureVisible(
          find.text('Quality: ${alert ? 'ALERT' : 'ACCEPTED'}'),
        );
        expect(find.text('Temperature: 6.0°C'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('invalid form does not save', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MilkCollectionPage(collectionService: service)),
    );
    await tester.pumpAndSettle();
    final values = ['Farmer Name', '12.5', 'NaN', '101', '-1'];
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), values[i]);
    }
    await tester.ensureVisible(find.text('Save Collection'));
    await tester.tap(find.text('Save Collection'));
    await tester.pumpAndSettle();
    expect(find.text('Enter Fat % between 0 and 100.'), findsOneWidget);
    expect((await db.collection('collections').get()).docs, isEmpty);
  });

  testWidgets('legacy records display unknown quality without zero readings', (
    tester,
  ) async {
    await db.collection('collections').add({
      'farmerName': 'Legacy Farmer',
      'quantityLitres': 5,
      'createdBy': 'owner',
      'collectionDate': Timestamp.now(),
    });
    await tester.pumpWidget(
      MaterialApp(home: MilkCollectionPage(collectionService: service)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Quality: UNKNOWN'));
    expect(find.text('Temperature: —°C'), findsOneWidget);
  });

  testWidgets(
    'pending save disables inputs and prevents duplicate submission',
    (tester) async {
      final mock = _Service();
      final saved = Completer<String>();
      when(() => mock.watchCollections()).thenAnswer((_) => Stream.value([]));
      when(
        () => mock.addCollection(
          farmerName: any(named: 'farmerName'),
          quantityLitres: any(named: 'quantityLitres'),
          fat: any(named: 'fat'),
          snf: any(named: 'snf'),
          temperature: any(named: 'temperature'),
        ),
      ).thenAnswer((_) => saved.future);
      await tester.pumpWidget(
        MaterialApp(home: MilkCollectionPage(collectionService: mock)),
      );
      await tester.pumpAndSettle();
      final values = ['Farmer Name', '12.5', '4', '8.5', '6'];
      for (var i = 0; i < values.length; i++) {
        await tester.enterText(find.byType(TextFormField).at(i), values[i]);
      }
      await tester.ensureVisible(find.text('Save Collection'));
      await tester.tap(find.text('Save Collection'));
      await tester.pump();
      for (final field in tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      )) {
        expect(field.enabled, isFalse);
      }
      saved.complete('id');
      await tester.pumpAndSettle();
      verify(
        () => mock.addCollection(
          farmerName: 'Farmer Name',
          quantityLitres: 12.5,
          fat: 4,
          snf: 8.5,
          temperature: 6,
        ),
      ).called(1);
    },
  );
}
