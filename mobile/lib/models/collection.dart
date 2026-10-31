import 'package:cloud_firestore/cloud_firestore.dart';

class Collection {
  final String id;
  final String farmerName;
  final double quantityLitres;
  final DateTime? collectionDate;
  final String createdBy;
  final double? fat;
  final double? snf;
  final double? temperature;
  final String qualityStatus;

  const Collection({
    required this.id,
    required this.farmerName,
    required this.quantityLitres,
    required this.collectionDate,
    required this.createdBy,
    this.fat,
    this.snf,
    this.temperature,
    this.qualityStatus = 'UNKNOWN',
  });

  factory Collection.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw FormatException('Collection document ${document.id} has no data.');
    }

    final farmerName = data['farmerName'];
    final quantity = data['quantityLitres'];
    final createdBy = data['createdBy'];
    final rawDate = data['collectionDate'];

    if (farmerName is! String || quantity is! num || createdBy is! String) {
      throw FormatException(
        'Collection document ${document.id} has invalid fields.',
      );
    }

    return Collection(
      id: document.id,
      farmerName: farmerName,
      quantityLitres: quantity.toDouble(),
      collectionDate: rawDate is Timestamp ? rawDate.toDate() : null,
      createdBy: createdBy,
      fat: _reading(data['fat']),
      snf: _reading(data['snf']),
      temperature: _reading(data['temperature']),
      qualityStatus:
          ['ACCEPTED', 'ALERT'].contains(data['qualityStatus']) &&
              _reading(data['fat']) != null &&
              _reading(data['snf']) != null &&
              _reading(data['temperature']) != null
          ? data['qualityStatus'] as String
          : 'UNKNOWN',
    );
  }

  static double? _reading(Object? value) =>
      value is num && value.isFinite ? value.toDouble() : null;

  Map<String, dynamic> toFirestore() {
    return {
      'farmerName': farmerName.trim(),
      'quantityLitres': quantityLitres,
      'collectionDate': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      if (fat != null) 'fat': fat,
      if (snf != null) 'snf': snf,
      if (temperature != null) 'temperature': temperature,
      if (fat != null || snf != null || temperature != null)
        'qualityStatus': qualityStatus,
    };
  }
}
