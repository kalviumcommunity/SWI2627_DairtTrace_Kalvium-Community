import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
