class AppointmentModel {
  final String id;
  final String userId;
  final String hospitalId;
  final String patientName;
  final String phone;
  final String preferredDate;
  final String description;
  final String status;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.hospitalId,
    required this.patientName,
    required this.phone,
    required this.preferredDate,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return AppointmentModel(
      id: docId,
      userId: json['userId'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      patientName: json['patientName'] ?? '',
      phone: json['phone'] ?? '',
      preferredDate: json['preferredDate'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'hospitalId': hospitalId,
      'patientName': patientName,
      'phone': phone,
      'preferredDate': preferredDate,
      'description': description,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
