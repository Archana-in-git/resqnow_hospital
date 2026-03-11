import 'package:flutter/material.dart';

class HospitalSidebar extends StatelessWidget {
  final String hospitalName;
  final VoidCallback onLogout;

  const HospitalSidebar({
    super.key,
    required this.hospitalName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Modern Gradient Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3B82F6),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      size: 40,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospitalName,
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hospital Admin',
                        style: TextStyle(
                          color: Colors.grey.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Dashboard Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.dashboard_outlined,
                color: Color(0xFF3B82F6),
              ),
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/dashboard');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Manage Doctors Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.people_outlined,
                color: Color(0xFF3B82F6),
              ),
              title: const Text(
                'Manage Doctors',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/manage-doctors');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Appointments Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF3B82F6),
              ),
              title: const Text(
                'Appointments',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/appointments');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Profile Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.person_outlined,
                color: Color(0xFF3B82F6),
              ),
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/profile');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Divider with more style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Logout Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
            ),
            child: ListTile(
              leading: Icon(Icons.logout_outlined, color: Colors.red.shade700),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: onLogout,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
