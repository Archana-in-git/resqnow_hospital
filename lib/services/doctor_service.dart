import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorService {
  static final _firestore = FirebaseFirestore.instance;
  static const _collection = 'doctors';

  // Get all doctors for a hospital
  static Future<List<DoctorModel>> getDoctorsByHospital(
    String hospitalId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('hospitalId', isEqualTo: hospitalId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }

  // Get a specific doctor
  static Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(doctorId).get();
      if (doc.exists) {
        return DoctorModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching doctor: $e');
    }
  }

  // Create a new doctor
  static Future<String> createDoctor(
    String hospitalId,
    String name,
    String department,
    String consultationStart,
    String consultationEnd,
    int experienceYears,
  ) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'hospitalId': hospitalId,
        'name': name,
        'department': department,
        'consultationStart': consultationStart,
        'consultationEnd': consultationEnd,
        'experienceYears': experienceYears,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating doctor: $e');
    }
  }

  // Update doctor
  static Future<void> updateDoctor(
    String doctorId, {
    String? name,
    String? department,
    String? consultationStart,
    String? consultationEnd,
    int? experienceYears,
    bool? isAvailable,
  }) async {
    try {
      final updates = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (name != null) {
        updates['name'] = name;
      }
      if (department != null) {
        updates['department'] = department;
      }
      if (consultationStart != null) {
        updates['consultationStart'] = consultationStart;
      }
      if (consultationEnd != null) {
        updates['consultationEnd'] = consultationEnd;
      }
      if (experienceYears != null) {
        updates['experienceYears'] = experienceYears;
      }
      if (isAvailable != null) {
        updates['isAvailable'] = isAvailable;
      }

      await _firestore.collection(_collection).doc(doctorId).update(updates);
    } catch (e) {
      throw Exception('Error updating doctor: $e');
    }
  }

  // Delete doctor
  static Future<void> deleteDoctor(String doctorId) async {
    try {
      await _firestore.collection(_collection).doc(doctorId).delete();
    } catch (e) {
      throw Exception('Error deleting doctor: $e');
    }
  }
}
