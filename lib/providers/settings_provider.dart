import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  late AppSettings _settings;

  SettingsProvider(this._storage) {
    _settings = _storage.loadSettings();
  }

  int    get themeIndex          => _settings.themeIndex;
  String get vehicleName         => _settings.vehicleName;
  int    get scanTimeoutSeconds  => _settings.scanTimeoutSeconds;

  Future<void> setThemeIndex(int v)   => _update(_settings.copyWith(themeIndex: v));
  Future<void> setVehicleName(String v) => _update(_settings.copyWith(vehicleName: v));
  Future<void> setScanTimeout(int v)  => _update(_settings.copyWith(scanTimeoutSeconds: v));

  Future<void> _update(AppSettings s) async {
    _settings = s;
    notifyListeners();
    await _storage.saveSettings(s);
  }
}
