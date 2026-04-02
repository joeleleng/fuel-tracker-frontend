import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<bool> syncFuelEntry(Map<String, dynamic> fuelEntry) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/fuel/entries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fuelEntry),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getUnits() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/units'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}