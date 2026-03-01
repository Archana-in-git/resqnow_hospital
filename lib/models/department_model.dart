import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id;
  final String name;
  final Timestamp createdAt;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return DepartmentModel(
      id: docId,
      name: json['name'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'createdAt': createdAt};
  }
}
