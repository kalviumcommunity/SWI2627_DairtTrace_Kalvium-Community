import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/services/directory_service.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late MockAuth auth;
  late DirectoryService service;
  setUp(() {
    db = FakeFirebaseFirestore();
    auth = MockAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('operator-a');
    when(() => auth.currentUser).thenReturn(user);
    service = DirectoryService(firestore: db, auth: auth);
  });

  test(
    'registers farmers with stable IDs and a valid centre relationship',
    () async {
      final centerId = await service.addCenter(
        name: ' Rampur Centre ',
        village: ' Rampur ',
      );
      final first = await service.addFarmer(
        name: ' Rajesh Kumar ',
        village: 'Rampur',
        phone: '+91 9876543210',
        centerId: centerId,
      );
      final second = await service.addFarmer(
        name: 'Rajesh Kumar',
        village: 'Rampur',
        phone: '+91 9876543211',
        centerId: centerId,
      );
      expect(first, isNot(second));
      final data = (await db.collection('farmers').doc(first).get()).data()!;
      expect(data['name'], 'Rajesh Kumar');
      expect(data['centerId'], centerId);
      expect(data['createdBy'], 'operator-a');
      expect(data['createdAt'], isNotNull);
    },
  );

  test(
    'rejects missing, inactive, or another operator’s centre without writes',
    () async {
      for (final id in ['missing', 'inactive', 'other']) {
        if (id != 'missing') {
          await db.collection('collectionCenters').doc(id).set({
            'createdBy': id == 'other' ? 'operator-b' : 'operator-a',
            'status': id == 'inactive' ? 'INACTIVE' : 'ACTIVE',
          });
        }
        await expectLater(
          service.addFarmer(
            name: 'Rajesh',
            village: 'Rampur',
            phone: '9876543210',
            centerId: id,
          ),
          throwsStateError,
        );
      }
      expect((await db.collection('farmers').get()).docs, isEmpty);
    },
  );

  test('only lists the current operator’s records', () async {
    await service.addCenter(name: 'My Centre', village: 'Rampur');
    await db.collection('collectionCenters').add({
      'name': 'Other Centre',
      'createdBy': 'operator-b',
    });
    expect((await service.watchCenters().first).map((record) => record.name), [
      'My Centre',
    ]);
  });

  test('rejects invalid registration and unauthenticated writes', () async {
    await expectLater(
      service.addCenter(name: ' ', village: 'Rampur'),
      throwsArgumentError,
    );
    await expectLater(
      service.addFarmer(
        name: 'Rajesh',
        village: 'Rampur',
        phone: 'abc',
        centerId: 'center',
      ),
      throwsArgumentError,
    );
    when(() => auth.currentUser).thenReturn(null);
    await expectLater(
      service.addCenter(name: 'Centre', village: 'Rampur'),
      throwsStateError,
    );
    expect((await db.collection('collectionCenters').get()).docs, isEmpty);
    expect((await db.collection('farmers').get()).docs, isEmpty);
  });
}
