class AppSettings {
  final int themeIndex;
  final String vehicleName;
  final int scanTimeoutSeconds;

  const AppSettings({
    this.themeIndex = 0,
    this.vehicleName = 'Mi Vehículo',
    this.scanTimeoutSeconds = 10,
  });

  AppSettings copyWith({
    int? themeIndex,
    String? vehicleName,
    int? scanTimeoutSeconds,
  }) => AppSettings(
    themeIndex: themeIndex ?? this.themeIndex,
    vehicleName: vehicleName ?? this.vehicleName,
    scanTimeoutSeconds: scanTimeoutSeconds ?? this.scanTimeoutSeconds,
  );

  Map<String, dynamic> toJson() => {
    'themeIndex': themeIndex,
    'vehicleName': vehicleName,
    'scanTimeoutSeconds': scanTimeoutSeconds,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeIndex: (json['themeIndex'] as int?) ?? 0,
    vehicleName: (json['vehicleName'] as String?) ?? 'Mi Vehículo',
    scanTimeoutSeconds: (json['scanTimeoutSeconds'] as int?) ?? 10,
  );
}
