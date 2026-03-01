import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/hospital_login_screen.dart';
import 'screens/auth/hospital_register_screen.dart';
import 'screens/dashboard/hospital_dashboard.dart';
import 'screens/dashboard/manage_doctors_screen.dart';
import 'screens/dashboard/appointments_screen.dart';
import 'screens/dashboard/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1E3A8A), // Deep indigo
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const HospitalLoginScreen(),
        '/register': (context) => const HospitalRegisterScreen(),
        '/dashboard': (context) => const HospitalDashboard(),
        '/manage-doctors': (context) => const ManageDoctorsScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any unknown routes
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}
