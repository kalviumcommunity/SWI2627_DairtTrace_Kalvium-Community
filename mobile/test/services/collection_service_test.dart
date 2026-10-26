
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

      final deletedDocument = await firestore
          .collection('collections')
          .doc('collection-1')
          .get();

      expect(deletedDocument.exists, isFalse);
    });

    test('rejects deletion when no user is signed in', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => service.deleteCollection(
          collectionId: 'collection-1',
        ),
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
        service.deleteCollection(
          collectionId: 'does-not-exist',
        ),
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
