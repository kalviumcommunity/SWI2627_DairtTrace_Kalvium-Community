import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/collection.dart';
import '../utils/quality_checker.dart';

class CollectionService {
  CollectionService({FirebaseFirestore? firestore})
    : _collections = (firestore ?? FirebaseFirestore.instance).collection(
        'collections',
      );

  final CollectionReference<Map<String, dynamic>> _collections;

  CollectionReference<Map<String, dynamic>> get _collections =>
      _firestore.collection('collections');

  Future<String> addCollection({
    required String farmerName,
    required double quantityLitres,
    required DateTime collectionDate,
    required String session,
    double? fatPercent,
    double? snfPercent,
    double? temperatureC,
    String? notes,
  }) async {
    final user = _auth.currentUser;

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

  Stream<List<Collection>> watchCollections() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to view collections.');
    }

    return _collections
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('collectionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Collection.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Deletes a collection by its Firestore document ID.
  /// Firestore security rules must enforce document ownership.
  Future<void> deleteCollection({required String collectionId}) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in before deleting a collection.');
    }

    final normalizedId = collectionId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Collection ID cannot be empty.');
    }

    await _collections.doc(normalizedId).delete();
  }
}
