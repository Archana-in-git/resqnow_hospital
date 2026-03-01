import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_model.dart';

class HospitalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<HospitalModel>> getHospitals() async {
    try {
      final snapshot = await _firestore
          .collection('hospitals')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HospitalModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching hospitals: $e');
      return [];
    }
  }

  static Future<HospitalModel?> getHospitalById(String hospitalId) async {
    try {
      final doc = await _firestore
          .collection('hospitals')
          .doc(hospitalId)
          .get();
      if (doc.exists) {
        return HospitalModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching hospital: $e');
      return null;
    }
  }
}
