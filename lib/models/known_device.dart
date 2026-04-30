class KnownDevice {
  final String id;       // BLE device id (MAC address)
  String advertisedName;
  String customName;

  KnownDevice({
    required this.id,
    required this.advertisedName,
    this.customName = '',
  });

  String get displayName =>
      customName.isNotEmpty ? customName : advertisedName;

  KnownDevice copyWith({
    String? id,
    String? advertisedName,
    String? customName,
  }) => KnownDevice(
    id: id ?? this.id,
    advertisedName: advertisedName ?? this.advertisedName,
    customName: customName ?? this.customName,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'advertisedName': advertisedName,
    'customName': customName,
  };

  factory KnownDevice.fromJson(Map<String, dynamic> json) => KnownDevice(
    id: json['id'] as String,
    advertisedName: json['advertisedName'] as String,
    customName: (json['customName'] as String?) ?? '',
  );
}
