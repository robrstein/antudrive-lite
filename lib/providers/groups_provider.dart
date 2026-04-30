import 'package:flutter/material.dart';
import '../models/lamp_group.dart';
import '../services/storage_service.dart';

class GroupsProvider extends ChangeNotifier {
  static const maxGroups = 1;

  final StorageService _storage;
  List<LampGroup> _groups = [];
  String? _selectedGroupId;

  GroupsProvider(this._storage) {
    _groups = _storage.loadGroups();
    if (_groups.isNotEmpty) _selectedGroupId = _groups.first.id;
  }

  List<LampGroup> get groups => List.unmodifiable(_groups);
  String? get selectedGroupId => _selectedGroupId;
  bool get canAddGroup => _groups.length < maxGroups;

  LampGroup? get selectedGroup =>
      _selectedGroupId == null
          ? null
          : _groups.where((g) => g.id == _selectedGroupId).firstOrNull;

  void selectGroup(String id) {
    _selectedGroupId = id;
    notifyListeners();
  }

  Future<void> addGroup(LampGroup group) async {
    if (_groups.length >= maxGroups) return;
    _groups.add(group);
    _selectedGroupId ??= group.id;
    notifyListeners();
    await _storage.saveGroups(_groups);
  }

  Future<void> updateGroup(LampGroup updated) async {
    final idx = _groups.indexWhere((g) => g.id == updated.id);
    if (idx == -1) return;
    _groups[idx] = updated;
    notifyListeners();
    await _storage.saveGroups(_groups);
  }

  Future<void> deleteGroup(String id) async {
    _groups.removeWhere((g) => g.id == id);
    if (_selectedGroupId == id) {
      _selectedGroupId = _groups.isNotEmpty ? _groups.first.id : null;
    }
    notifyListeners();
    await _storage.saveGroups(_groups);
  }

  Future<void> setGroupWarmth(String id, int warmth) async {
    final idx = _groups.indexWhere((g) => g.id == id);
    if (idx == -1) return;
    _groups[idx] = _groups[idx].copyWith(warmth: warmth);
    notifyListeners();
    await _storage.saveGroups(_groups);
  }

  Future<void> setGroupBrightness(String id, int brightness) async {
    final idx = _groups.indexWhere((g) => g.id == id);
    if (idx == -1) return;
    _groups[idx] = _groups[idx].copyWith(brightness: brightness);
    notifyListeners();
    await _storage.saveGroups(_groups);
  }

  String generateId() => 'g_${DateTime.now().millisecondsSinceEpoch}';
}
