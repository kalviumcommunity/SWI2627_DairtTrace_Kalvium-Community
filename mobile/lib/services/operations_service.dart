import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Owner-scoped operational records. Money and role provisioning are separate.
class OperationsService {
  OperationsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : db = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  String get uid {
    final user = auth.currentUser;
    if (user == null) throw StateError('Please sign in first.');
    return user.uid;
  }

  Stream<List<OperationalRecord>> watch(String path) {
    return db
        .collection(path)
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((s) {
          final records = s.docs
              .map((d) => OperationalRecord(d.id, d.data()))
              .toList();
          records.sort((a, b) => b.date.compareTo(a.date));
          return records;
        });
  }

  Future<String> createBatch(List<String> collectionIds) async {
    final owner = uid;
    if (collectionIds.isEmpty ||
        collectionIds.length > 8 ||
        collectionIds.toSet().length != collectionIds.length) {
      throw ArgumentError('Select between 1 and 8 different collections.');
    }
    final ref = db.collection('batches').doc();
    await db.runTransaction((tx) async {
      final sources = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final id in collectionIds) {
        sources.add(await tx.get(db.collection('collections').doc(id)));
      }
      String? center, session, day;
      for (final source in sources) {
        final data = source.data();
        if (data == null ||
            data['createdBy'] != owner ||
            data['farmerId'] == null ||
            data['centerId'] == null ||
            data['session'] == null ||
            data['dayKey'] == null ||
            data['batchId'] != null) {
          throw StateError('Select unbatched, registered collections you own.');
        }
        center ??= data['centerId'] as String;
        session ??= data['session'] as String;
        day ??= data['dayKey'] as String;
        if (center != data['centerId'] ||
            session != data['session'] ||
            day != data['dayKey']) {
          throw StateError('A batch must use one centre, date and session.');
        }
      }
      tx.set(ref, {
        'createdBy': owner,
        'createdAt': FieldValue.serverTimestamp(),
        'collectionIds': collectionIds,
        'centerId': center,
        'session': session,
        'dayKey': day,
        'status': 'PENDING',
      });
      for (final source in sources) {
        tx.update(source.reference, {'batchId': ref.id});
      }
    });
    return ref.id;
  }

  Future<void> recordBatchResult(String id, String status, String notes) async {
    final owner = uid;
    if (!['PASSED', 'FAILED'].contains(status) ||
        notes.trim().length < 3 ||
        notes.trim().length > 1000) {
      throw ArgumentError(
        'Choose a result and add 3–1000 characters of test notes.',
      );
    }
    final ref = db.collection('batches').doc(id);
    await db.runTransaction((tx) async {
      final record = await tx.get(ref);
      if (record.data()?['createdBy'] != owner ||
          record.data()?['status'] != 'PENDING') {
        throw StateError('Only pending batches you own can receive a result.');
      }
      tx.update(ref, {
        'status': status,
        'testNotes': notes.trim(),
        'testedBy': owner,
        'testedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<String> raiseDispute(
    String collectionId,
    String type,
    String description,
  ) async {
    final owner = uid;
    if (!['Quantity', 'Quality', 'Other'].contains(type) ||
        description.trim().length < 5 ||
        description.trim().length > 1000) {
      throw ArgumentError(
        'Choose a type and describe the issue in 5–1000 characters.',
      );
    }
    final ref = db.collection('disputes').doc();
    await db.runTransaction((tx) async {
      final source = await tx.get(
        db.collection('collections').doc(collectionId),
      );
      if (source.data()?['createdBy'] != owner) {
        throw StateError('Collection is unavailable.');
      }
      tx.set(ref, {
        'collectionId': collectionId,
        'type': type,
        'description': description.trim(),
        'status': 'OPEN',
        'createdBy': owner,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    return ref.id;
  }

  Future<void> resolveDispute(String id, String status, String notes) async {
    final owner = uid;
    if (!['UNDER_REVIEW', 'RESOLVED', 'REJECTED'].contains(status) ||
        notes.trim().length < 3 ||
        notes.trim().length > 1000) {
      throw ArgumentError('Add review notes (3–1000 characters).');
    }
    final ref = db.collection('disputes').doc(id);
    await db.runTransaction((tx) async {
      final record = await tx.get(ref);
      final old = record.data();
      if (old?['createdBy'] != owner ||
          !['OPEN', 'UNDER_REVIEW'].contains(old?['status']) ||
          old?['status'] == status) {
        throw StateError('This dispute is already reviewed or closed.');
      }
      tx.update(ref, {
        'status': status,
        'resolution': notes.trim(),
        'reviewedBy': owner,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

class OperationalRecord {
  const OperationalRecord(this.id, this.data);
  final String id;
  final Map<String, dynamic> data;
  String text(String key, [String fallback = '']) =>
      data[key] is String ? data[key] as String : fallback;
  double number(String key) => (data[key] as num?)?.toDouble() ?? 0;
  DateTime get date =>
      (data['collectionDate'] as Timestamp? ?? data['createdAt'] as Timestamp?)
          ?.toDate() ??
      DateTime(1970);
}

class FarmerTotal {
  FarmerTotal(this.id, this.name);
  final String id, name;
  int count = 0;
  double litres = 0, fatWeight = 0, snfWeight = 0, qualityLitres = 0;
  int alerts = 0;
  void add(OperationalRecord record) {
    count++;
    final amount = record.number('quantityLitres');
    litres += amount;
    if (record.data['fat'] is num && record.data['snf'] is num) {
      fatWeight += record.number('fat') * amount;
      snfWeight += record.number('snf') * amount;
      qualityLitres += amount;
    }
    if (record.text('qualityStatus') == 'ALERT') alerts++;
  }

  double? get averageFat =>
      qualityLitres == 0 ? null : fatWeight / qualityLitres;
  double? get averageSnf =>
      qualityLitres == 0 ? null : snfWeight / qualityLitres;
}

List<FarmerTotal> reconcile(List<OperationalRecord> records, DateTime month) {
  final totals = <String, FarmerTotal>{};
  for (final r in records) {
    if (r.date.year != month.year ||
        r.date.month != month.month ||
        r.text('farmerId').isEmpty) {
      continue;
    }
    final id = r.text('farmerId');
    (totals[id] ??= FarmerTotal(id, r.text('farmerName'))).add(r);
  }
  return totals.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

String collectionCsv(List<OperationalRecord> records) {
  String cell(Object? value) {
    var text = value?.toString() ?? '';
    if (RegExp(r'^[=+@\-\t\r]').hasMatch(text)) text = "'$text";
    return '"${text.replaceAll('"', '""')}"';
  }

  final rows = <List<Object?>>[
    [
      'Collection ID',
      'Farmer ID',
      'Farmer',
      'Date',
      'Litres',
      'Fat %',
      'SNF %',
      'Temperature C',
      'Quality',
      'Batch ID',
    ],
    ...records.map(
      (r) => [
        r.id,
        r.data['farmerId'],
        r.data['farmerName'],
        r.date.toIso8601String(),
        r.data['quantityLitres'],
        r.data['fat'],
        r.data['snf'],
        r.data['temperature'],
        r.data['qualityStatus'],
        r.data['batchId'],
      ],
    ),
  ];
  return rows.map((row) => row.map(cell).join(',')).join('\r\n');
}
