import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollectionService {
  CollectionService({FirebaseFirestore? firestore})
    : _collections = (firestore ?? FirebaseFirestore.instance).collection(
        'collections',
      );

  final CollectionReference<Map<String, dynamic>> _collections;

  Future<void> addCollection({
    required String farmerName,
    required double quantityLitres,
    required DateTime collectionDate,
    required String session,
    double? fatPercent,
    double? snfPercent,
    double? temperatureC,
    String? notes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please sign in before recording a collection.');
    }

    final data = <String, dynamic>{
      'farmerName': farmerName.trim(),
      'quantityLitres': quantityLitres,
      'collectionDate': Timestamp.fromDate(collectionDate),
      'session': session,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
    };

    if (fatPercent != null) data['fatPercent'] = fatPercent;
    if (snfPercent != null) data['snfPercent'] = snfPercent;
    if (temperatureC != null) data['temperatureC'] = temperatureC;
    if (notes != null && notes.trim().isNotEmpty) {
      data['notes'] = notes.trim();
    }

    await _collections.add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollections() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please sign in to view collections.');
    }

    return _collections
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('collectionDate', descending: true)
        .snapshots();
  }
}
