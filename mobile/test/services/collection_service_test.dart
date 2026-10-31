import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/services/collection_service.dart';

void queryTests() {
  group('CollectionService', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('Firestore query filters records by creator', () async {
      await firestore.collection('collections').add({
        'farmerName': 'Farmer A',
        'quantityLitres': 12.5,
        'createdBy': 'user-123',
        'collectionDate': Timestamp.fromDate(DateTime(2026, 10, 18)),
      });

      await firestore.collection('collections').add({
        'farmerName': 'Farmer B',
        'quantityLitres': 8.0,
        'createdBy': 'another-user',
        'collectionDate': Timestamp.fromDate(DateTime(2026, 10, 17)),
      });

      final snapshot = await firestore
          .collection('collections')
          .where('createdBy', isEqualTo: 'user-123')
          .orderBy('collectionDate', descending: true)
          .get();

      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['farmerName'], 'Farmer A');
      expect(snapshot.docs.first.data()['quantityLitres'], 12.5);
    });

    test(
      'Firestore query returns an empty result when no records match',
      () async {
        final snapshot = await firestore
            .collection('collections')
            .where('createdBy', isEqualTo: 'user-123')
            .orderBy('collectionDate', descending: true)
            .get();

        expect(snapshot.docs, isEmpty);
      },
    );

    test('Firestore query sorts records by date, newest first', () async {
      await firestore.collection('collections').add({
        'farmerName': 'Older Farmer',
        'quantityLitres': 5.0,
        'createdBy': 'user-123',
        'collectionDate': Timestamp.fromDate(DateTime(2026, 10, 17)),
      });

      await firestore.collection('collections').add({
        'farmerName': 'Newer Farmer',
        'quantityLitres': 10.0,
        'createdBy': 'user-123',
        'collectionDate': Timestamp.fromDate(DateTime(2026, 10, 19)),
      });

      final snapshot = await firestore
          .collection('collections')
          .where('createdBy', isEqualTo: 'user-123')
          .orderBy('collectionDate', descending: true)
          .get();

      expect(snapshot.docs, hasLength(2));
      expect(snapshot.docs.first.data()['farmerName'], 'Newer Farmer');
      expect(snapshot.docs.last.data()['farmerName'], 'Older Farmer');
    });
  });
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  queryTests();
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

    service = CollectionService(firestore: firestore, auth: auth);
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

      await service.deleteCollection(collectionId: 'collection-1');

      final deletedDocument = await firestore
          .collection('collections')
          .doc('collection-1')
          .get();

      expect(deletedDocument.exists, isFalse);
    });

    test('rejects deletion when no user is signed in', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => service.deleteCollection(collectionId: 'collection-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects an empty collection ID', () async {
      expect(
        () => service.deleteCollection(collectionId: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deleting a missing document completes safely', () async {
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
}
