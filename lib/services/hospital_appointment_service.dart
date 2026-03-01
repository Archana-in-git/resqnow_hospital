import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_appointment_model.dart';
import 'notification_service.dart';

class HospitalAppointmentService {
  final FirebaseFirestore _firestore;

  HospitalAppointmentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<HospitalAppointmentModel>> getPendingAppointments(
    String hospitalId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('hospitalId', isEqualTo: hospitalId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HospitalAppointmentModel.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending appointments: $e');
    }
  }

  Future<void> approveAppointment(String appointmentId) async {
    try {
      // Get appointment details before updating
      final appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!appointmentDoc.exists) {
        throw Exception('Appointment not found');
      }

      final appointmentData =
          appointmentDoc.data() as Map<String, dynamic>? ?? {};
      final userId = appointmentData['userId'] as String?;
      final doctorName = appointmentData['doctorName'] as String?;
      final appointmentDate = appointmentData['preferredDate'] as String?;

      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for user
      if (userId != null) {
        await NotificationService.createAppointmentNotification(
          userId: userId,
          appointmentId: appointmentId,
          status: 'approved',
          doctorName: doctorName,
          appointmentDate: appointmentDate,
        );
      }
    } catch (e) {
      throw Exception('Failed to approve appointment: $e');
    }
  }

  Future<void> rejectAppointment(String appointmentId) async {
    try {
      // Get appointment details before updating
      final appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!appointmentDoc.exists) {
        throw Exception('Appointment not found');
      }

      final appointmentData =
          appointmentDoc.data() as Map<String, dynamic>? ?? {};
      final userId = appointmentData['userId'] as String?;
      final doctorName = appointmentData['doctorName'] as String?;
      final appointmentDate = appointmentData['preferredDate'] as String?;

      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for user
      if (userId != null) {
        await NotificationService.createAppointmentNotification(
          userId: userId,
          appointmentId: appointmentId,
          status: 'rejected',
          doctorName: doctorName,
          appointmentDate: appointmentDate,
        );
      }
    } catch (e) {
      throw Exception('Failed to reject appointment: $e');
    }
  }

  Stream<List<HospitalAppointmentModel>> streamPendingAppointments(
    String hospitalId,
  ) {
    return _firestore
        .collection('appointments')
        .where('hospitalId', isEqualTo: hospitalId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HospitalAppointmentModel.fromFirestore(doc, null))
              .toList();
        });
  }
}
