import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalAppointmentModel {
  final String id;
  final String userId;
  final String hospitalId;
  final String doctorId;
  final String patientName;
  final String phone;
  final String description;
  final String preferredDate;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HospitalAppointmentModel({
    required this.id,
    required this.userId,
    required this.hospitalId,
    required this.doctorId,
    required this.patientName,
    required this.phone,
    required this.description,
    required this.preferredDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory HospitalAppointmentModel.fromFirestore(
    DocumentSnapshot doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return HospitalAppointmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      hospitalId: data['hospitalId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientName: data['patientName'] ?? '',
      phone: data['phone'] ?? '',
      description: data['description'] ?? '',
      preferredDate: data['preferredDate'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'hospitalId': hospitalId,
      'doctorId': doctorId,
      'patientName': patientName,
      'phone': phone,
      'description': description,
      'preferredDate': preferredDate,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
