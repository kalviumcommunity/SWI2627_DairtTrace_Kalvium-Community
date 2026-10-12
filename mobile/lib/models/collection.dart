
import 'package:cloud_firestore/cloud_firestore.dart';

class Collection {
  final String id;
  final String farmerName;
  final double quantityLitres;
  final DateTime? collectionDate;
  final String createdBy;

  const Collection({
    required this.id,
    required this.farmerName,
    required this.quantityLitres,
    required this.collectionDate,
    required this.createdBy,
  });

  factory Collection.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw FormatException(
        'Collection document ${document.id} has no data.',
      );
    }

    final farmerName = data['farmerName'];
    final quantity = data['quantityLitres'];
    final createdBy = data['createdBy'];
    final rawDate = data['collectionDate'];

    if (farmerName is! String ||
        quantity is! num ||
        createdBy is! String) {
      throw FormatException(
        'Collection document ${document.id} has invalid fields.',
      );
    }

    return Collection(
      id: document.id,
      farmerName: farmerName,
      quantityLitres: quantity.toDouble(),
      collectionDate: rawDate is Timestamp
          ? rawDate.toDate()
          : null,
      createdBy: createdBy,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'farmerName': farmerName.trim(),
      'quantityLitres': quantityLitres,
      'collectionDate': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }
}
