import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreSeed {
  static Future<void> seedData() async {
    final firestore = FirebaseFirestore.instance;

    // Create hospital 1
    var hospital1 = await firestore.collection('hospitals').add({
      'name': 'City Care Hospital',
      'address': 'Kochi, Kerala',
      'phone': '9876543210',
      'email': 'citycare@gmail.com',
      'doctors': 'Dr. John (Cardio), Dr. Mary (Ortho)',
      'consultationTime': '9 AM - 5 PM',
      'status': 'approved',
      'createdAt': Timestamp.now(),
    });

    // Create hospital 2
    var hospital2 = await firestore.collection('hospitals').add({
      'name': 'Green Valley Hospital',
      'address': 'Ernakulam, Kerala',
      'phone': '9123456780',
      'email': 'greenvalley@gmail.com',
      'doctors': 'Dr. Rahul (ENT)',
      'consultationTime': '10 AM - 6 PM',
      'status': 'approved',
      'createdAt': Timestamp.now(),
    });

    // Seed appointments
    await firestore.collection('appointments').add({
      'userId': 'sampleUser1',
      'hospitalId': hospital1.id,
      'patientName': 'Arun Kumar',
      'phone': '9000000001',
      'preferredDate': '2026-03-01',
      'description': 'Chest pain consultation',
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    await firestore.collection('appointments').add({
      'userId': 'sampleUser2',
      'hospitalId': hospital1.id,
      'patientName': 'Meera S',
      'phone': '9000000002',
      'preferredDate': '2026-03-02',
      'description': 'Orthopedic review',
      'status': 'approved',
      'createdAt': Timestamp.now(),
    });

    await firestore.collection('appointments').add({
      'userId': 'sampleUser3',
      'hospitalId': hospital2.id,
      'patientName': 'Rahul P',
      'phone': '9000000003',
      'preferredDate': '2026-03-03',
      'description': 'ENT checkup',
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    debugPrint("Hospitals and Appointments Seeded Successfully");
  }
}
