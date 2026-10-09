
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollectionService {
  final CollectionReference<Map<String, dynamic>> _collections =
      FirebaseFirestore.instance.collection('collections');

  Future<void> addCollection({
    required String farmerName,
    required double quantityLitres,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please sign in before recording a collection.');
    }

    await _collections.add({
      'farmerName': farmerName.trim(),
      'quantityLitres': quantityLitres,
      'collectionDate': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
    });
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
