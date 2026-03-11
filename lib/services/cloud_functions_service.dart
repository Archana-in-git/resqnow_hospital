import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CloudFunctionsService {
  // Replace with your project ID
  static const String projectId = 'resqnow-12e6c'; // Update this
  static const String region = 'us-central1';

  static final String seedDatabaseUrl =
      'https://$region-$projectId.cloudfunctions.net/seedDatabase';

  static Future<Map<String, dynamic>> callSeedDatabase() async {
    try {
      final response = await http
          .get(
            Uri.parse(seedDatabaseUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('Seed response: $data');
        return data;
      } else {
        throw Exception('Failed to seed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error calling seedDatabase: $e');
      rethrow;
    }
  }
}
