import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DirectoryEntry {
  const DirectoryEntry({
    required this.id,
    required this.name,
    this.centerId,
    this.village = '',
    this.status = 'ACTIVE',
  });
  final String id;
  final String name;
  final String? centerId;
  final String village;
  final String status;
}

/// Initial operator-owned directory. Cooperative roles are a separate migration.
class DirectoryService {
  DirectoryService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in first.');
    return user.uid;
  }

  String _text(String value, String label, int max, {bool required = true}) {
    final result = value.trim();
    if ((required && result.length < 2) || result.length > max) {
      throw ArgumentError(
        '$label must contain ${required ? 2 : 0}–$max characters.',
      );
    }
    return result;
  }

  Stream<List<DirectoryEntry>> watchCenters() => _watch('collectionCenters');
  Stream<List<DirectoryEntry>> watchFarmers() => _watch('farmers');

  Stream<List<DirectoryEntry>> _watch(String path) {
    return _db
        .collection(path)
        .where('createdBy', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
          final result = snapshot.docs
              .map(
                (doc) => DirectoryEntry(
                  id: doc.id,
                  name: doc.data()['name'] as String,
                  centerId: doc.data()['centerId'] as String?,
                  village: doc.data()['village'] as String? ?? '',
                  status: doc.data()['status'] as String? ?? 'UNKNOWN',
                ),
              )
              .toList();
          result.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return result;
        });
  }

  Future<String> addCenter({
    required String name,
    required String village,
  }) async {
    final uid = _uid;
    final document = _db.collection('collectionCenters').doc();
    await document.set({
      'name': _text(name, 'Centre name', 100),
      'village': _text(village, 'Village/address', 200),
      'status': 'ACTIVE',
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }

  Future<String> addFarmer({
    required String name,
    required String village,
    required String phone,
    required String centerId,
  }) async {
    final uid = _uid;
    final normalizedName = _text(name, 'Farmer name', 100);
    final normalizedVillage = _text(village, 'Village/address', 200);
    final normalizedPhone = phone.trim();
    if (!RegExp(r'^\+?[0-9][0-9 -]{5,18}[0-9]$').hasMatch(normalizedPhone)) {
      throw ArgumentError('Enter a valid contact number.');
    }
    if (centerId.isEmpty || centerId.contains('/')) {
      throw ArgumentError('Select a collection centre.');
    }
    final document = _db.collection('farmers').doc();
    await _db.runTransaction((transaction) async {
      final center = await transaction.get(
        _db.collection('collectionCenters').doc(centerId),
      );
      if (!center.exists ||
          center.data()?['createdBy'] != uid ||
          center.data()?['status'] != 'ACTIVE') {
        throw StateError('Select an active collection centre you can access.');
      }
      transaction.set(document, {
        'name': normalizedName,
        'village': normalizedVillage,
        'phone': normalizedPhone,
        'centerId': centerId,
        'status': 'ACTIVE',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    return document.id;
  }
}
