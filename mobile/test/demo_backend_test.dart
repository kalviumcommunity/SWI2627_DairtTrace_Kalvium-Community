import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/demo_backend.dart';
import 'package:mobile/services/operations_service.dart';

void main() {
  tearDown(AppBackend.closeDemo);
  test('demo samples are linked and leave eligible collections', () async {
    await AppBackend.startDemo();
    final db = AppBackend.firestore;
    final sources = await db.collection('collections').get();
    expect(sources.docs.length, 6);
    expect(sources.docs.where((d) => d.data()['batchId'] == null).length, 2);
    final batches = await db.collection('batches').get();
    expect(batches.docs.map((d) => d.data()['status']).toSet(), {
      'PENDING',
      'PASSED',
      'FAILED',
    });
    for (final b in batches.docs) {
      for (final id in b.data()['collectionIds'] as List) {
        final source = await db
            .collection('collections')
            .doc(id as String)
            .get();
        expect(source.data()!['batchId'], b.id);
        expect(source.data()!['dayKey'], b.data()['dayKey']);
      }
    }
    final ops = OperationsService();
    final id = await ops.createBatch(['collection-2', 'collection-3']);
    expect((await db.collection('batches').doc(id).get()).exists, isTrue);
    expect((await db.collection('disputes').get()).docs.length, 3);
  });
  test(
    'reopening demo resets samples without retaining session mutations',
    () async {
      await AppBackend.startDemo();
      final first = AppBackend.firestore;
      await first.collection('farmers').doc('temporary').set({
        'name': 'Temporary',
      });
      AppBackend.closeDemo();
      expect(AppBackend.isDemo, isFalse);
      await AppBackend.startDemo();
      expect(identical(first, AppBackend.firestore), isFalse);
      expect(
        (await AppBackend.firestore
                .collection('farmers')
                .doc('temporary')
                .get())
            .exists,
        isFalse,
      );
    },
  );
}
