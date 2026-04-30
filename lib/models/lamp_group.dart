import 'package:flutter/material.dart';
import '../constants/icon_options.dart';

class LampGroup {
  final String id;
  String name;
  int iconIndex; // index into kIconOptions
  List<String> deviceIds;
  int warmth;    // 0–100  (0=frío, 100=cálido)
  int brightness; // 5–100

  LampGroup({
    required this.id,
    required this.name,
    this.iconIndex = 0,
    List<String>? deviceIds,
    this.warmth = 50,
    this.brightness = 50,
  }) : deviceIds = deviceIds ?? [];

  IconData get icon =>
      kIconOptions[iconIndex.clamp(0, kIconOptions.length - 1)].icon;

  LampGroup copyWith({
    String? id,
    String? name,
    int? iconIndex,
    List<String>? deviceIds,
    int? warmth,
    int? brightness,
  }) {
    return LampGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      deviceIds: deviceIds ?? List.of(this.deviceIds),
      warmth: warmth ?? this.warmth,
      brightness: brightness ?? this.brightness,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconIndex': iconIndex,
    'deviceIds': deviceIds,
    'warmth': warmth,
    'brightness': brightness,
  };

  factory LampGroup.fromJson(Map<String, dynamic> json) => LampGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    iconIndex: (json['iconIndex'] as int?) ?? 0,
    deviceIds: (json['deviceIds'] as List<dynamic>).cast<String>(),
    warmth: (json['warmth'] as int?) ?? 50,
    brightness: (json['brightness'] as int?) ?? 50,
  );
}
