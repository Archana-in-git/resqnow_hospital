import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../services/auth_service.dart';
import '../../services/doctor_service.dart';
import '../../widgets/custom_textfield.dart';

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});

  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  late Future<List<DoctorModel>> _doctorsFuture;
  bool _isSaving = false;
  bool _showAddDoctor = false;
  bool _isEditingDoctor = false;
  String? _editingDoctorId;
  String _searchQuery = '';

  late TextEditingController _doctorNameController;
  late TextEditingController _departmentController;
  late TextEditingController _consultationStartController;
  late TextEditingController _consultationEndController;
  late TextEditingController _experienceYearsController;
  late TextEditingController _searchController;

  final _doctorFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _refreshDoctors();
  }

  void _initializeControllers() {
    _doctorNameController = TextEditingController();
    _departmentController = TextEditingController();
    _consultationStartController = TextEditingController();
    _consultationEndController = TextEditingController();
    _experienceYearsController = TextEditingController();
    _searchController = TextEditingController();
  }

  Future<void> _pickTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final formattedTime = time.format(context);
      setState(() {
        if (isStartTime) {
          _consultationStartController.text = formattedTime;
        } else {
          _consultationEndController.text = formattedTime;
        }
      });
    }
  }

  void _clearForm() {
    _doctorNameController.clear();
    _departmentController.clear();
    _consultationStartController.clear();
    _consultationEndController.clear();
    _experienceYearsController.clear();
    setState(() {
      _isEditingDoctor = false;
      _editingDoctorId = null;
      _showAddDoctor = false;
    });
  }

  void _startEditDoctor(DoctorModel doctor) {
    _doctorNameController.text = doctor.name;
    _departmentController.text = doctor.department;
    _consultationStartController.text = doctor.consultationStart;
    _consultationEndController.text = doctor.consultationEnd;
    _experienceYearsController.text = doctor.experienceYears.toString();
    setState(() {
      _isEditingDoctor = true;
      _editingDoctorId = doctor.id;
      _showAddDoctor = true;
    });
  }

  void _refreshDoctors() {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        _doctorsFuture = DoctorService.getDoctorsByHospital(user.uid);
      });
    }
  }

  Future<void> _addDoctor() async {
    if (!_doctorFormKey.currentState!.validate()) return;

    if (_departmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a department')),
      );
      return;
    }

    if (_consultationStartController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select consultation start time')),
      );
      return;
    }

    if (_consultationEndController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select consultation end time')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not found');

      if (_isEditingDoctor && _editingDoctorId != null) {
        // Update existing doctor
        await DoctorService.updateDoctor(
          _editingDoctorId!,
          name: _doctorNameController.text.trim(),
          department: _departmentController.text.trim(),
          consultationStart: _consultationStartController.text.trim(),
          consultationEnd: _consultationEndController.text.trim(),
          experienceYears: int.tryParse(_experienceYearsController.text) ?? 0,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor updated successfully!')),
          );
          _clearForm();
          _refreshDoctors();
        }
      } else {
        // Create new doctor
        await DoctorService.createDoctor(
          user.uid,
          _doctorNameController.text.trim(),
          _departmentController.text.trim(),
          _consultationStartController.text.trim(),
          _consultationEndController.text.trim(),
          int.tryParse(_experienceYearsController.text) ?? 0,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor added successfully!')),
          );
          _clearForm();
          _refreshDoctors();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    setState(() => _isSaving = false);
  }

  Future<void> _deleteDoctor(String doctorId) async {
    try {
      await DoctorService.deleteDoctor(doctorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor deleted successfully!')),
        );
        _refreshDoctors();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting doctor: $e')));
      }
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _consultationStartController.dispose();
    _consultationEndController.dispose();
    _experienceYearsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manage Doctors'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<List<DoctorModel>>(
          future: _doctorsFuture,
          builder: (context, snapshot) {
            final allDoctors = snapshot.data ?? [];
            final totalDoctors = allDoctors.length;

            // Filter doctors by search query
            final filteredDoctors = allDoctors.where((doctor) {
              return doctor.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header with Gradient Background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hospital Doctors',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your hospital doctors and schedules',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Doctors',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalDoctors.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Add Doctor Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_showAddDoctor) {
                        _clearForm();
                      } else {
                        setState(() => _showAddDoctor = !_showAddDoctor);
                      }
                    },
                    icon: Icon(_showAddDoctor ? Icons.close : Icons.add),
                    label: Text(_showAddDoctor ? 'Cancel' : '+ Add Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showAddDoctor
                          ? Colors.grey.shade400
                          : const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Add Doctor Form
                if (_showAddDoctor) ...[
                  _buildAddDoctorForm(),
                  const SizedBox(height: 32),
                ],

                // Search and Filter
                if (totalDoctors > 0) ...[
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Search Doctor',
                        hintText: 'Search by name',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF3B82F6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                ],

                // Doctors List
                if (snapshot.connectionState == ConnectionState.waiting) ...{
                  const Center(child: CircularProgressIndicator()),
                } else if (snapshot.hasError) ...{
                  Center(child: Text('Error: ${snapshot.error}')),
                } else if (filteredDoctors.isEmpty && totalDoctors == 0) ...{
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No doctors yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first doctor to get started',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                } else if (filteredDoctors.isEmpty) ...{
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No doctors match your search',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                } else ...{
                  Column(
                    children: filteredDoctors
                        .map((doctor) => _buildDoctorCard(doctor))
                        .toList(),
                  ),
                },
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddDoctorForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditingDoctor
              ? const Color(0xFF3B82F6)
              : Colors.orange.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _doctorFormKey,
        child: Column(
          children: [
            Text(
              _isEditingDoctor ? '✏️ Edit Doctor' : '➕ Add New Doctor',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Doctor Name',
              hint: 'Enter doctor name',
              controller: _doctorNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Doctor name is required';
                }
                return null;
              },
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Department',
              hint: 'Enter department name',
              controller: _departmentController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Department is required';
                }
                return null;
              },
              prefixIcon: Icons.business_center_outlined,
            ),
            const SizedBox(height: 16),
            // Time picker buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _pickTime(true),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Start Time',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1E3A8A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _consultationStartController.text.isEmpty
                                    ? 'e.g., 09:00'
                                    : _consultationStartController.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _consultationStartController.text.isEmpty
                                      ? Colors.grey.shade500
                                      : const Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _pickTime(false),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'End Time',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1E3A8A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _consultationEndController.text.isEmpty
                                    ? 'e.g., 17:00'
                                    : _consultationEndController.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _consultationEndController.text.isEmpty
                                      ? Colors.grey.shade500
                                      : const Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Experience (Years)',
              hint: 'e.g., 5',
              controller: _experienceYearsController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Experience is required';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              prefixIcon: Icons.school_outlined,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _addDoctor,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _isEditingDoctor
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _isEditingDoctor ? 'Update Doctor' : 'Save Doctor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: doctor.isAvailable
              ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
              : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: doctor.isAvailable
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doctor.isAvailable ? '✓ Available' : '✗ Unavailable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: doctor.isAvailable
                              ? const Color(0xFF10B981)
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Switch(
                    value: doctor.isAvailable,
                    onChanged: (value) {
                      DoctorService.updateDoctor(doctor.id, isAvailable: value)
                          .then((_) {
                            _refreshDoctors();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? '${doctor.name} is now available'
                                      : '${doctor.name} is now unavailable',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          })
                          .catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          });
                    },
                    activeColor: const Color(0xFF10B981),
                    inactiveTrackColor: Colors.red.shade200,
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => _startEditDoctor(doctor),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                          tooltip: 'Edit doctor',
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Doctor'),
                                content: Text(
                                  'Remove ${doctor.name} from the hospital?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteDoctor(doctor.id);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          tooltip: 'Delete doctor',
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE5E7EB)),

          // Department Info
          Row(
            children: [
              const Icon(
                Icons.local_hospital_outlined,
                size: 18,
                color: Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Text(
                doctor.department,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Consultation Hours and Experience
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 18,
                      color: Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${doctor.consultationStart} - ${doctor.consultationEnd}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 18,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${doctor.experienceYears} yrs',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
