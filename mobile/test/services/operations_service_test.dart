import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/services/operations_service.dart';
import 'package:mobile/services/collection_service.dart';

class TestAuth extends Mock implements FirebaseAuth {}

class TestUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late TestAuth auth;
  late OperationsService operations;
  late CollectionService collections;
  final date = DateTime(2026, 10, 25, 9);
  setUp(() async {
    db = FakeFirebaseFirestore();
    auth = TestAuth();
    final user = TestUser();
    when(() => user.uid).thenReturn('owner');
    when(() => auth.currentUser).thenReturn(user);
    operations = OperationsService(firestore: db, auth: auth);
    collections = CollectionService(firestore: db, auth: auth);
    await db.collection('collectionCenters').doc('center').set({
      'createdBy': 'owner',
      'name': 'Green Valley',
      'status': 'ACTIVE',
    });
    await db.collection('farmers').doc('farmer').set({
      'createdBy': 'owner',
      'name': 'Rajesh Kumar',
      'status': 'ACTIVE',
      'centerId': 'center',
    });
  });
  Future<String> add({
    String session = 'MORNING',
    DateTime? at,
    double litres = 12,
    double fat = 4,
    String farmer = 'farmer',
  }) => collections.addCollection(
    farmerName: 'Rajesh Kumar',
    quantityLitres: litres,
    fat: fat,
    snf: 8.5,
    temperature: 6,
    farmerId: farmer,
    centerId: 'center',
    session: session,
    occurredAt: at ?? date,
    notes: 'Collected',
  );
  test(
    'linked collection snapshots real farmer and centre, date and session',
    () async {
      final id = await add();
      final data = (await db.collection('collections').doc(id).get()).data()!;
      expect(data['farmerId'], 'farmer');
      expect(data['centerId'], 'center');
      expect(data['centerName'], 'Green Valley');
      expect(data['collectionDate'], Timestamp.fromDate(date));
      expect(data['dayKey'], '2026-10-25');
      expect(data['session'], 'MORNING');
      expect(data['notes'], 'Collected');
    },
  );
  test(
    'inactive and foreign farmers, future dates and invalid sessions rejected',
    () async {
      await db.collection('farmers').doc('foreign').set({
        'createdBy': 'other',
        'status': 'ACTIVE',
        'centerId': 'center',
      });
      await expectLater(add(farmer: 'foreign'), throwsStateError);
      await expectLater(
        add(at: DateTime.now().add(const Duration(days: 1))),
        throwsArgumentError,
      );
      await expectLater(add(session: 'NIGHT'), throwsArgumentError);
      await db.collection('farmers').doc('farmer').update({
        'status': 'INACTIVE',
      });
      await expectLater(add(), throwsStateError);
      expect((await db.collection('collections').get()).docs, isEmpty);
    },
  );
  test(
    'batch assignment atomically retains sources and rejects reuse',
    () async {
      final a = await add(), b = await add(fat: 2);
      final id = await operations.createBatch([a, b]);
      final batch = (await db.collection('batches').doc(id).get()).data()!;
      expect(batch['collectionIds'], [a, b]);
      expect(batch['status'], 'PENDING');
      expect(
        (await db.collection('collections').doc(a).get()).data()!['batchId'],
        id,
      );
      expect(
        (await db.collection('collections').doc(b).get())
            .data()!['qualityStatus'],
        'ALERT',
      );
      await expectLater(operations.createBatch([a]), throwsStateError);
      expect((await db.collection('batches').get()).docs, hasLength(1));
    },
  );
  test(
    'batches reject mixed dates, sessions, duplicate IDs and excess size',
    () async {
      final a = await add(),
          b = await add(session: 'EVENING'),
          c = await add(at: DateTime(2026, 10, 24));
      await expectLater(operations.createBatch([a, b]), throwsStateError);
      await expectLater(operations.createBatch([a, c]), throwsStateError);
      await expectLater(operations.createBatch([a, a]), throwsArgumentError);
      await expectLater(operations.createBatch([]), throwsArgumentError);
      await expectLater(
        operations.createBatch(List.generate(9, (i) => '$i')),
        throwsArgumentError,
      );
      expect((await db.collection('batches').get()).docs, isEmpty);
      expect(
        (await db.collection('collections').doc(a).get()).data()!.containsKey(
          'batchId',
        ),
        isFalse,
      );
    },
  );
  test('legacy and foreign records cannot enter a batch', () async {
    await db.collection('collections').doc('legacy').set({
      'createdBy': 'owner',
      'farmerName': 'Rajesh Kumar',
    });
    final a = await add();
    await db.collection('collections').doc(a).update({'createdBy': 'other'});
    await expectLater(operations.createBatch(['legacy']), throwsStateError);
    await expectLater(operations.createBatch([a]), throwsStateError);
  });
  test(
    'batch quality result records tester and cannot be overwritten',
    () async {
      final batch = await operations.createBatch([await add()]);
      await operations.recordBatchResult(
        batch,
        'FAILED',
        'Temperature test failed',
      );
      final record = (await db.collection('batches').doc(batch).get()).data()!;
      expect(record['status'], 'FAILED');
      expect(record['testedBy'], 'owner');
      expect(record['testedAt'], isA<Timestamp>());
      await expectLater(
        operations.recordBatchResult(batch, 'PASSED', 'Rewritten result'),
        throwsStateError,
      );
    },
  );
  test('dispute records source and closure is immutable', () async {
    final source = await add();
    final id = await operations.raiseDispute(
      source,
      'Quantity',
      'Please verify weighing',
    );
    await operations.resolveDispute(id, 'UNDER_REVIEW', 'Checking scale');
    await operations.resolveDispute(id, 'RESOLVED', 'Scale record verified');
    final data = (await db.collection('disputes').doc(id).get()).data()!;
    expect(data['collectionId'], source);
    expect(data['status'], 'RESOLVED');
    expect(data['reviewedBy'], 'owner');
    await expectLater(
      operations.resolveDispute(id, 'REJECTED', 'Changing decision'),
      throwsStateError,
    );
    expect(
      (await db.collection('collections').doc(source).get())
          .data()!['quantityLitres'],
      12,
    );
  });
  test(
    'disputes reject missing source, foreign source and empty notes',
    () async {
      await expectLater(
        operations.raiseDispute('missing', 'Quantity', 'Check weight'),
        throwsStateError,
      );
      final id = await add();
      await db.collection('collections').doc(id).update({'createdBy': 'other'});
      await expectLater(
        operations.raiseDispute(id, 'Quantity', 'Check weight'),
        throwsStateError,
      );
      await expectLater(
        operations.raiseDispute(id, 'Quantity', ''),
        throwsArgumentError,
      );
    },
  );
  test('owner queries and sign in checks stay enforced', () async {
    await operations.createBatch([await add()]);
    await db.collection('batches').add({
      'createdBy': 'other',
      'createdAt': Timestamp.now(),
    });
    expect(await operations.watch('batches').first, hasLength(1));
    when(() => auth.currentUser).thenReturn(null);
    expect(() => operations.watch('batches'), throwsStateError);
    await expectLater(operations.createBatch(['id']), throwsStateError);
  });
  test('reconciliation separates identical names by ID and excludes legacy and other periods', () {
    OperationalRecord r(
      String id,
      String? farmer,
      double litres,
      double fat,
      DateTime at,
    ) => OperationalRecord(id, {
      'farmerId': farmer,
      'farmerName': 'Same Name',
      'quantityLitres': litres,
      'fat': fat,
      'snf': 8.5,
      'qualityStatus': 'ACCEPTED',
      'collectionDate': Timestamp.fromDate(at),
    });
    final rows = [
      r('a', 'f1', 10, 3, date),
      r('b', 'f1', 30, 5, date),
      r('c', 'f2', 20, 4, date),
      r('d', null, 99, 4, date),
      r('e', 'f1', 100, 9, DateTime(2026, 9, 30)),
    ];
    final totals = reconcile(rows, DateTime(2026, 10));
    expect(totals, hasLength(2));
    final first = totals.firstWhere((r) => r.id == 'f1');
    expect(first.litres, 40);
    expect(first.count, 2);
    expect(first.averageFat, 4.5);
    expect(totals.firstWhere((r) => r.id == 'f2').litres, 20);
  });
  test('CSV quotes cells and neutralizes spreadsheet formula names', () {
    final csv = collectionCsv([
      OperationalRecord('id', {
        'farmerName': '=SUM(A1),"x"',
        'quantityLitres': 12,
      }),
    ]);
    expect(csv, contains('"\'=SUM(A1),""x"""'));
    expect(csv, contains('Collection ID'));
  });
}
