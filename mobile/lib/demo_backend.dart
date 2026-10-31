import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Demo records exist only in memory and never use the live Firebase client.
class AppBackend {
  static FakeFirebaseFirestore? _demo;
  static final _auth = DemoAuth();
  static bool get isDemo => _demo != null;
  static FirebaseFirestore get firestore => _demo ?? FirebaseFirestore.instance;
  static FirebaseAuth get auth => isDemo ? _auth : FirebaseAuth.instance;
  static void closeDemo() {
    _demo = null;
  }

  static Future<void> startDemo() async {
    final db = FakeFirebaseFirestore();
    await db.collection('collectionCenters').doc('center').set({
      'name': 'Green Valley Centre',
      'village': 'Rampur',
      'createdBy': 'owner',
      'status': 'ACTIVE',
    });
    for (final item in [
      ('farmer', 'Rajesh Kumar'),
      ('farmer2', 'Suresh Patel'),
      ('farmer3', 'Meena Devi'),
    ]) {
      await db.collection('farmers').doc(item.$1).set({
        'name': item.$2,
        'phone': '+91 9876543210',
        'village': 'Rampur',
        'centerId': 'center',
        'status': 'ACTIVE',
        'createdBy': 'owner',
      });
    }
    final today = DateTime.now();
    for (var i = 0; i < 6; i++) {
      await db.collection('collections').doc('collection-$i').set({
        'farmerId': i % 2 == 0 ? 'farmer' : 'farmer2',
        'farmerName': i % 2 == 0 ? 'Rajesh Kumar' : 'Suresh Patel',
        'centerId': 'center',
        'centerName': 'Green Valley Centre',
        'createdBy': 'owner',
        'quantityLitres': 120.0 + i * 5,
        'fat': i == 3 ? 2.5 : 4.2,
        'snf': 8.6,
        'temperature': 4.0,
        'qualityStatus': i == 3 ? 'ALERT' : 'ACCEPTED',
        'collectionDate': Timestamp.fromDate(today),
        'session': 'MORNING',
        'dayKey':
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      });
    }
    await db.collection('batches').doc('batch-1').set({
      'createdBy': 'owner',
      'createdAt': Timestamp.now(),
      'collectionIds': ['collection-0', 'collection-1'],
      'centerId': 'center',
      'session': 'MORNING',
      'dayKey':
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      'status': 'PENDING',
    });
    await db.collection('disputes').doc('dispute-1').set({
      'createdBy': 'owner',
      'createdAt': Timestamp.now(),
      'collectionId': 'collection-3',
      'type': 'Quality',
      'description': 'Please verify the fat reading',
      'status': 'OPEN',
    });

    for (final id in ['collection-0', 'collection-1']) {
      await db.collection('collections').doc(id).update({'batchId': 'batch-1'});
    }
    for (var i = 2; i < 4; i++) {
      final id = 'collection-${i + 2}';
      await db.collection('collections').doc(id).update({
        'batchId': 'batch-$i',
      });
      await db.collection('batches').doc('batch-$i').set({
        'createdBy': 'owner',
        'createdAt': Timestamp.now(),
        'collectionIds': [id],
        'centerId': 'center',
        'session': 'MORNING',
        'dayKey':
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
        'status': i == 2 ? 'PASSED' : 'FAILED',
        'testedBy': 'owner',
        'testedAt': Timestamp.now(),
        'testNotes': 'Sample laboratory result',
      });
    }
    for (final status in ['UNDER_REVIEW', 'RESOLVED']) {
      await db.collection('disputes').doc('demo-$status').set({
        'createdBy': 'owner',
        'createdAt': Timestamp.now(),
        'collectionId': 'collection-2',
        'type': 'Quantity',
        'description': 'Sample quantity verification',
        'status': status,
        'reviewNotes': 'Sample review notes',
        'reviewedBy': 'owner',
        'reviewedAt': Timestamp.now(),
      });
    }
    _demo = db;
  }
}

class DemoAuth implements FirebaseAuth {
  @override
  User get currentUser => DemoUser();
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    throw StateError('Password reset is unavailable in isolated demo mode.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unavailable in demo mode');
}

class DemoUser implements User {
  @override
  String get uid => 'owner';
  @override
  String get email => 'demo@dairytrace.test';
  @override
  String get displayName => 'Demo Operator';
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unavailable in demo mode');
}
