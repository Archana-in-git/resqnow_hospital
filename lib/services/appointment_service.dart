import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<AppointmentModel>> getAppointmentsByHospital(
    String hospitalId, {
    String? status,
  }) async {
    try {
      Query query = _firestore
          .collection('appointments')
          .where('hospitalId', isEqualTo: hospitalId)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => AppointmentModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      return [];
    }
  }

  static Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint('Error updating appointment: $e');
    }
  }

  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
    }
  }
}
