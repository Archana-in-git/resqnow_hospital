import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<AppointmentModel>> _appointments;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _appointments = AppointmentService.getAppointmentsByHospital(user.uid);
    });
  }

  void _updateStatus(String appointmentId, String newStatus) async {
    await AppointmentService.updateAppointmentStatus(appointmentId, newStatus);
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: FutureBuilder<List<AppointmentModel>>(
        future: _appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No appointments found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final appointment = snapshot.data![index];
              return AppointmentCard(
                appointment: appointment,
                onApprove: () => _updateStatus(appointment.id, 'approved'),
                onReject: () => _updateStatus(appointment.id, 'rejected'),
              );
            },
          );
        },
      ),
    );
  }
}
