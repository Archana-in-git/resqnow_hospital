class DoctorModel {
  final String id;
  final String hospitalId;
  final String name;
  final String department;
  final String consultationStart;
  final String consultationEnd;
  final int experienceYears;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorModel({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.department,
    required this.consultationStart,
    required this.consultationEnd,
    required this.experienceYears,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json, String docId) {
    return DoctorModel(
      id: docId,
      hospitalId: json['hospitalId'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      consultationStart: json['consultationStart'] ?? '09:00',
      consultationEnd: json['consultationEnd'] ?? '17:00',
      experienceYears: json['experienceYears'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'name': name,
      'department': department,
      'consultationStart': consultationStart,
      'consultationEnd': consultationEnd,
      'experienceYears': experienceYears,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
