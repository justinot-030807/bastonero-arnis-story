import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaveSlotInfo {
  final int slotIndex;
  final bool hasData;
  final int year;
  final int month;
  final int week;
  final int pesos;
  final String fighterName;
  final int gradeLevel;
  final String savedAt;

  const SaveSlotInfo({
    required this.slotIndex,
    required this.hasData,
    this.year = 1,
    this.month = 6,
    this.week = 1,
    this.pesos = 0,
    this.fighterName = '',
    this.gradeLevel = 5,
    this.savedAt = '',
  });

  String get summaryText {
    if (!hasData) return 'Bakante (Empty Slot)';
    return 'Y$year M$month W$week | $fighterName (G$gradeLevel) | P$pesos';
  }
}

class StorageService {
  static const String _defaultSlotKey = 'bastonero_active_slot';
  static const String _slotPrefix = 'bastonero_save_slot_';

  static Future<int> getActiveSlotIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_defaultSlotKey) ?? 1;
    } catch (_) {
      return 1;
    }
  }

  static Future<void> setActiveSlotIndex(int slotIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_defaultSlotKey, slotIndex);
    } catch (_) {}
  }

  static Future<bool> saveGameToSlot(int slotIndex, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      data['savedAtTimestamp'] = DateTime.now().toIso8601String();
      final jsonString = jsonEncode(data);
      return await prefs.setString('$_slotPrefix$slotIndex', jsonString);
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loadGameFromSlot(int slotIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_slotPrefix$slotIndex');
      if (jsonString == null || jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<List<SaveSlotInfo>> getAllSlotsInfo() async {
    final list = <SaveSlotInfo>[];
    for (int i = 1; i <= 3; i++) {
      final data = await loadGameFromSlot(i);
      if (data != null) {
        final fighter = data['fighter'] as Map<String, dynamic>?;
        list.add(SaveSlotInfo(
          slotIndex: i,
          hasData: true,
          year: data['year'] as int? ?? 1,
          month: data['month'] as int? ?? 6,
          week: data['week'] as int? ?? 1,
          pesos: data['pesos'] as int? ?? 0,
          fighterName: fighter?['name'] as String? ?? 'Bayani',
          gradeLevel: fighter?['gradeLevel'] as int? ?? 5,
          savedAt: data['savedAtTimestamp'] as String? ?? '',
        ));
      } else {
        list.add(SaveSlotInfo(slotIndex: i, hasData: false));
      }
    }
    return list;
  }

  static Future<bool> clearSlot(int slotIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('$_slotPrefix$slotIndex');
    } catch (e) {
      return false;
    }
  }

  static Future<String> exportActiveSaveJson(int slotIndex) async {
    final data = await loadGameFromSlot(slotIndex);
    if (data == null) return '';
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<bool> importSaveJson(int slotIndex, String jsonString) async {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (!map.containsKey('fighter') || !map.containsKey('year')) {
        return false;
      }
      return await saveGameToSlot(slotIndex, map);
    } catch (e) {
      return false;
    }
  }
}
