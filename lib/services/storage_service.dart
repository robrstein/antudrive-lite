import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/known_device.dart';
import '../models/lamp_group.dart';

class StorageService {
  static const _keysGroups  = 'groups';
  static const _keyDevices  = 'devices';
  static const _keySettings = 'settings';

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // ── Groups ────────────────────────────────────────────────────────────────

  List<LampGroup> loadGroups() {
    final raw = _prefs.getString(_keysGroups);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>().map(LampGroup.fromJson).toList();
  }

  Future<void> saveGroups(List<LampGroup> groups) =>
      _prefs.setString(_keysGroups, jsonEncode(groups.map((g) => g.toJson()).toList()));

  // ── Devices ───────────────────────────────────────────────────────────────

  List<KnownDevice> loadDevices() {
    final raw = _prefs.getString(_keyDevices);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>().map(KnownDevice.fromJson).toList();
  }

  Future<void> saveDevices(List<KnownDevice> devices) =>
      _prefs.setString(_keyDevices, jsonEncode(devices.map((d) => d.toJson()).toList()));

  // ── Settings ──────────────────────────────────────────────────────────────

  AppSettings loadSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) =>
      _prefs.setString(_keySettings, jsonEncode(settings.toJson()));
}
