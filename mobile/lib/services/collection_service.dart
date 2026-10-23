import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/collection.dart';

class CollectionService {
  CollectionService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collections =>
      _firestore.collection('collections');

  Future<String> addCollection({
    required String farmerName,
    required double quantityLitres,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in before recording a collection.');
    }

    final normalizedName = farmerName.trim();

    if (normalizedName.length < 2) {
      throw ArgumentError('Farmer name must contain at least 2 characters.');
    }

    if (!quantityLitres.isFinite || quantityLitres <= 0) {
      throw ArgumentError('Milk quantity must be greater than zero.');
    }

    final collection = Collection(
      id: '',
      farmerName: normalizedName,
      quantityLitres: quantityLitres,
      collectionDate: null,
      createdBy: user.uid,
    );

    final document = await _collections.add(collection.toFirestore());
    return document.id;
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
