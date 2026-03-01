import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';

class HospitalRegisterScreen extends StatefulWidget {
  const HospitalRegisterScreen({super.key});

  @override
  State<HospitalRegisterScreen> createState() => _HospitalRegisterScreenState();
}

class _HospitalRegisterScreenState extends State<HospitalRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // First, create the auth account
      final authResult = await AuthService.registerHospital(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (authResult != null) {
        // Then, save hospital details to Firestore
        await FirebaseFirestore.instance
            .collection('hospitals')
            .doc(authResult.user!.uid)
            .set({
              'id': authResult.user!.uid,
              'name': _hospitalNameController.text.trim(),
              'email': _emailController.text.trim(),
              'phone': _phoneController.text.trim(),
              'address': _addressController.text.trim(),
              'status': 'pending',
              'createdAt': Timestamp.now(),
              'updatedAt': Timestamp.now(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! Add doctors in your dashboard.',
              ),
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Registration'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.local_hospital, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Register Your Hospital',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join ResqNow and manage appointments efficiently',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Hospital Name
              CustomTextField(
                label: 'Hospital Name',
                hint: 'Enter your hospital name',
                controller: _hospitalNameController,
                validator: Validators.validateHospitalName,
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                label: 'Email Address',
                hint: 'Enter hospital email',
                controller: _emailController,
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 16),

              // Password
              CustomTextField(
                label: 'Password',
                hint: 'Enter a secure password',
                controller: _passwordController,
                validator: Validators.validatePassword,
                obscureText: true,
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 16),

              // Phone
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter 10-digit phone number',
                controller: _phoneController,
                validator: Validators.validatePhoneNumber,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter hospital address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
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
                    : const Text(
                        'Register Hospital',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),

              // Login Link
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Already registered? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
