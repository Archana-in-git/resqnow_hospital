import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department_model.dart';

class DepartmentService {
  static final _firestore = FirebaseFirestore.instance;
  static const _collection = 'departments';

  // Get all departments
  static Future<List<DepartmentModel>> getDepartments() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      final departments = snapshot.docs
          .map((doc) => DepartmentModel.fromJson(doc.data(), doc.id))
          .toList();

      // Sort by name
      departments.sort((a, b) => a.name.compareTo(b.name));
      return departments;
    } catch (e) {
      throw Exception('Error fetching departments: $e');
    }
  }

  // Get a specific department
  static Future<DepartmentModel?> getDepartmentById(String departmentId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(departmentId)
          .get();
      if (doc.exists) {
        return DepartmentModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching department: $e');
    }
  }
}
