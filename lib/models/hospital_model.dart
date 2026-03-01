class HospitalModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json, String docId) {
    return HospitalModel(
      id: docId,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
