import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fuel_entry.dart';

class PendingStorage {
  static const String _key = 'pending_fuel_entries';

  static Future<void> savePendingEntry(FuelEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? existing = prefs.getStringList(_key);
    final List<String> updated = existing ?? [];
    updated.add(json.encode(entry.toMap()));
    await prefs.setStringList(_key, updated);
    print('✅ Pending entry saved to SharedPreferences: ${entry.id}');
  }

  static Future<List<FuelEntry>> getPendingEntriesByUnit(String unitCode) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? entries = prefs.getStringList(_key);
    if (entries == null) return [];

    final List<FuelEntry> result = [];
    for (var entryJson in entries) {
      try {
        final map = json.decode(entryJson);
        final entry = FuelEntry.fromMap(map);
        if (entry.unitCode == unitCode && entry.status == 'pending' && entry.fuelmanId == null) {
          result.add(entry);
        }
      } catch (e) {
        print('Error parsing entry: $e');
      }
    }
    return result;
  }

  static Future<List<FuelEntry>> getAllPendingEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? entries = prefs.getStringList(_key);
    if (entries == null) return [];

    final List<FuelEntry> result = [];
    for (var entryJson in entries) {
      try {
        final map = json.decode(entryJson);
        final entry = FuelEntry.fromMap(map);
        if (entry.status == 'pending' && entry.fuelmanId == null) {
          result.add(entry);
        }
      } catch (e) {
        print('Error parsing entry: $e');
      }
    }
    return result;
  }

  static Future<void> updatePendingEntry(FuelEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? entries = prefs.getStringList(_key);
    if (entries == null) return;

    final List<String> updated = [];
    for (var entryJson in entries) {
      final map = json.decode(entryJson);
      if (map['id'] == entry.id) {
        updated.add(json.encode(entry.toMap()));
      } else {
        updated.add(entryJson);
      }
    }
    await prefs.setStringList(_key, updated);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}