import '../demo_backend.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/collection.dart';
import '../utils/quality_checker.dart';

class CollectionService {
  CollectionService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? AppBackend.firestore,
      _auth = auth ?? AppBackend.auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collections =>
      _firestore.collection('collections');

  Future<String> addCollection({
    required String farmerName,
    required double quantityLitres,
    required double fat,
    required double snf,
    required double temperature,
    String? farmerId,
    String? centerId,
    String? session,
    DateTime? occurredAt,
    String notes = '',
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

    final quality = QualityChecker.check(
      fat: fat,
      snf: snf,
      temperature: temperature,
    );
    final collection = Collection(
      id: '',
      farmerName: normalizedName,
      quantityLitres: quantityLitres,
      collectionDate: null,
      createdBy: user.uid,
      fat: fat,
      snf: snf,
      temperature: temperature,
      qualityStatus: quality.status,
    );

    if (farmerId == null) {
      final document = await _collections.add(collection.toFirestore());
      return document.id;
    }
    if (centerId == null ||
        !['MORNING', 'EVENING'].contains(session) ||
        occurredAt == null ||
        occurredAt.isAfter(DateTime.now().add(const Duration(minutes: 1))) ||
        occurredAt.year < 2020 ||
        notes.trim().length > 1000) {
      throw ArgumentError(
        'Check the collection centre, date, session and notes.',
      );
    }
    final ref = _collections.doc();
    await _firestore.runTransaction((tx) async {
      final farmer = await tx.get(
        _firestore.collection('farmers').doc(farmerId),
      );
      final center = await tx.get(
        _firestore.collection('collectionCenters').doc(centerId),
      );
      if (farmer.data()?['createdBy'] != user.uid ||
          farmer.data()?['status'] != 'ACTIVE' ||
          farmer.data()?['centerId'] != centerId ||
          center.data()?['createdBy'] != user.uid ||
          center.data()?['status'] != 'ACTIVE') {
        throw StateError('Select an active farmer and centre you can access.');
      }
      tx.set(ref, {
        ...collection.toFirestore(),
        'farmerId': farmerId,
        'centerId': centerId,
        'farmerName': farmer.data()!['name'],
        'centerName': center.data()!['name'],
        'session': session,
        'collectionDate': Timestamp.fromDate(occurredAt),
        'dayKey':
            '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}-${occurredAt.day.toString().padLeft(2, '0')}',
        'notes': notes.trim(),
      });
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDocuments() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in to view collections.');
    return _collections
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('collectionDate', descending: true)
        .snapshots();
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
