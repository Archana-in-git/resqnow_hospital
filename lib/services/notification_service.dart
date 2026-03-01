import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a notification for appointment approval
  static Future<void> createAppointmentNotification({
    required String userId,
    required String appointmentId,
    required String status, // 'approved' or 'rejected'
    String? doctorName,
    String? appointmentDate,
  }) async {
    try {
      final isApproved = status == 'approved';
      final title = isApproved
          ? 'Appointment Approved'
          : 'Appointment Rejected';
      final message = isApproved
          ? 'Your appointment request has been approved${doctorName != null ? ' with Dr. $doctorName' : ''}.'
          : 'Unfortunately, your appointment request has been rejected.';

      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type':
            'appointment_${status}', // appointment_approved or appointment_rejected
        'appointmentId': appointmentId,
        'status': status,
        'doctorName': doctorName,
        'appointmentDate': appointmentDate,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      print('✓ Appointment notification created for user $userId');
    } catch (e) {
      print('Error creating appointment notification: $e');
      throw Exception('Failed to create appointment notification: $e');
    }
  }

  /// Get all notifications for a specific user (mainly for admin reference)
  static Future<List<Map<String, dynamic>>> getUserNotifications(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
}
