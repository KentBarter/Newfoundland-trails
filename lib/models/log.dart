import 'package:cloud_firestore/cloud_firestore.dart';

class Log {
  final String id;
  final DateTime dateCompleted;
  final String trailName;
  final String description;
  final int rating;
  final String imageUrl;

  Log({required this.id, required this.dateCompleted, required this.trailName, required this.description, required this.rating, required this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "DateCompleted": dateCompleted,
      "TrailName" : trailName,
      "Description" : description,
      "Rating": rating,
      "ImageUrl": imageUrl,
    };
  }

  static Log fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Log(
      id: doc.id,
      dateCompleted: data["DateCompleted"],
      trailName: data["TrailName"] as String? ?? "",
      description: data["Description"] as String? ?? "",
      rating: data["Rating"] as int? ?? 0,
      imageUrl: data["ImageUrl"]as String? ?? "",
    );
  }
}