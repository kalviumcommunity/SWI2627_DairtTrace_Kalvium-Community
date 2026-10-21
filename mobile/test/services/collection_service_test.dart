
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/models/collection.dart';
import 'package:mobile/services/collection_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;
  late CollectionService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    user = MockUser();

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('user-123');

    service = CollectionService(
      firestore: firestore,
      auth: auth,
    );
  });

  group('deleteCollection', () {
    test('deletes the specified collection document', () async {
      await firestore.collection('collections').doc('collection-1').set({
        'farmerName': 'Ramesh',
        'quantityLitres': 12.5,
        'collectionDate': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'createdBy': 'user-123',
      });

      await service.deleteCollection(
        collectionId: 'collection-1',
      );

      final document = await firestore
          .collection('collections')
          .doc('collection-1')
          .get();

      expect(document.exists, isFalse);
    });

    test('rejects deletion when signed out', () async {
      when(() => auth.currentUser).thenReturn(null);

      await expectLater(
        service.deleteCollection(collectionId: 'collection-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects an empty collection ID', () async {
      await expectLater(
        service.deleteCollection(collectionId: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles deletion of a missing document safely', () async {
      await expectLater(
        service.deleteCollection(collectionId: 'does-not-exist'),
        completes,
      );

      final document = await firestore
          .collection('collections')
          .doc('does-not-exist')
          .get();

      expect(document.exists, isFalse);
    });
  });

  group('Collection server timestamps', () {
    test('serializes server timestamp sentinels', () {
      final collection = Collection(
        id: '',
        farmerName: 'Ramesh',
        quantityLitres: 12.5,
        collectionDate: null,
        createdBy: 'user-123',
      );

      final data = collection.toFirestore();

      expect(data['farmerName'], 'Ramesh');
      expect(data['quantityLitres'], 12.5);
      expect(data['createdBy'], 'user-123');
      expect(data['collectionDate'], isA<FieldValue>());
      expect(data['createdAt'], isA<FieldValue>());
    });

    test('parses Firestore timestamps into DateTime', () async {
      final expectedDate = DateTime.utc(2026, 10, 20, 8, 30);
      final reference =
          firestore.collection('collections').doc('timestamp-test');

      await reference.set({
        'farmerName': 'Ramesh',
        'quantityLitres': 12.5,
        'collectionDate': Timestamp.fromDate(expectedDate),
        'createdAt': Timestamp.fromDate(expectedDate),
        'createdBy': 'user-123',
      });

      final snapshot = await reference.get();
      final collection = Collection.fromFirestore(snapshot);

      expect(
        collection.collectionDate?.toUtc(),
        expectedDate.toUtc(),
      );
    });

    test('returns null when collectionDate is not a Timestamp', () async {
      final reference =
          firestore.collection('collections').doc('missing-date');

      await reference.set({
        'farmerName': 'Ramesh',
        'quantityLitres': 12.5,
        'collectionDate': null,
        'createdAt': Timestamp.now(),
        'createdBy': 'user-123',
      });

      final snapshot = await reference.get();
      final collection = Collection.fromFirestore(snapshot);

      expect(collection.collectionDate, isNull);
    });
  });
}
