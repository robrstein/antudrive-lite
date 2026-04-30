import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/known_device.dart';
import '../protocol/triones_protocol.dart';
import '../services/storage_service.dart';

enum DevStatus { disconnected, connecting, connected, error }

final _serviceUuid   = Uuid.parse('0000ffd5-0000-1000-8000-00805f9b34fb');
final _writeCharUuid = Uuid.parse('0000ffd9-0000-1000-8000-00805f9b34fb');
final _notifyCharUuid = Uuid.parse('0000ffd4-0000-1000-8000-00805f9b34fb');
final _notifySvcUuid = Uuid.parse('0000ffd0-0000-1000-8000-00805f9b34fb');

class BleProvider extends ChangeNotifier {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final StorageService _storage;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  final Map<String, DevStatus> _status = {};
  final Map<String, QualifiedCharacteristic> _writeChars = {};
  final Map<String, StreamSubscription<ConnectionStateUpdate>> _connSubs = {};
  final Map<String, StreamSubscription<List<int>>> _notifySubs = {};

  List<KnownDevice> _knownDevices = [];
  bool _scanning = false;
  bool _permissionsGranted =
      kIsWeb || defaultTargetPlatform != TargetPlatform.android;
  bool _initialized = false;
  BleStatus _bleStatus = BleStatus.unknown;
  String _statusMessage = 'Abre el menú y presiona Buscar.';
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<BleStatus>? _bleStatusSub;
  bool _filterQstar = true;
  Timer? _scanTimer;

  BleProvider(this._storage) {
    _knownDevices = _storage.loadDevices();
  }

  List<KnownDevice> get knownDevices => List.unmodifiable(_knownDevices);
  bool get scanning => _scanning;
  bool get permissionsGranted => _permissionsGranted;
  bool get bleReady => _bleStatus == BleStatus.ready;
  String get statusMessage => _statusMessage;

  DevStatus statusOf(String id) => _status[id] ?? DevStatus.disconnected;
  bool isConnected(String id) => _status[id] == DevStatus.connected;
  bool get filterQstar => _filterQstar;
  void setFilterQstar(bool v) { _filterQstar = v; notifyListeners(); }

  // ── Init & Permissions ────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _bleStatus = _ble.status;
    _bleStatusSub = _ble.statusStream.listen((s) {
      _bleStatus = s;
      notifyListeners();
    });

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _permissionsGranted = true;
      notifyListeners();
      return;
    }

    final sdkInt = (await _deviceInfo.androidInfo).version.sdkInt;
    final perms = <Permission>[
      if (sdkInt >= 31) Permission.bluetoothScan,
      if (sdkInt >= 31) Permission.bluetoothConnect,
      if (sdkInt <= 30) Permission.locationWhenInUse,
    ];

    if (perms.isEmpty) {
      _permissionsGranted = true;
      notifyListeners();
      return;
    }

    final statuses = await perms.request();
    _permissionsGranted =
        statuses.values.every((s) => s.isGranted || s.isLimited);
    _statusMessage = _permissionsGranted
        ? 'Permisos BLE concedidos.'
        : 'Faltan permisos BLE. Revisa los ajustes de la app.';
    notifyListeners();
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> startScan(int timeoutSeconds) async {
    if (_scanning) return;

    if (!_permissionsGranted) {
      await requestPermissions();
      if (!_permissionsGranted) return;
    }

    if (!bleReady) {
      _statusMessage = 'Activa el Bluetooth antes de escanear.';
      notifyListeners();
      return;
    }

    await _scanSub?.cancel();
    _scanning = true;
    _statusMessage = 'Escaneando dispositivos BLE…';
    notifyListeners();

    _scanSub = _ble
        .scanForDevices(
          withServices: const <Uuid>[],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          _onDeviceFound,
          onError: (Object e) {
            _statusMessage = 'Error al escanear: $e';
            stopScan();
          },
        );

    _scanTimer?.cancel();
    _scanTimer = Timer(Duration(seconds: timeoutSeconds), stopScan);
  }

  void stopScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
    _scanSub?.cancel();
    _scanSub = null;
    if (_scanning) {
      _scanning = false;
      _statusMessage = _knownDevices.isEmpty
          ? 'Escaneo finalizado: sin resultados.'
          : 'Escaneo finalizado.';
      notifyListeners();
    }
  }

  void _onDeviceFound(DiscoveredDevice dev) {
    final isKnown = _knownDevices.any((d) => d.id == dev.id);
    if (!isKnown) {
      if (_filterQstar && !dev.name.toLowerCase().startsWith('qstar')) return;
      _knownDevices.add(KnownDevice(
        id: dev.id,
        advertisedName: dev.name.isNotEmpty ? dev.name : dev.id,
      ));
      _storage.saveDevices(_knownDevices);
      notifyListeners();
    }
  }

  // ── Connect / Disconnect ──────────────────────────────────────────────────

  void toggleConnection(String deviceId) {
    if (isConnected(deviceId)) {
      disconnect(deviceId);
    } else {
      connect(deviceId);
    }
  }

  void connect(String deviceId) {
    final s = _status[deviceId];
    if (s == DevStatus.connecting || s == DevStatus.connected) return;

    _setStatus(deviceId, DevStatus.connecting);

    _connSubs[deviceId]?.cancel();
    _connSubs[deviceId] = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 15),
        )
        .listen(
          (update) => _onConnectionUpdate(deviceId, update),
          onError: (_) => _setStatus(deviceId, DevStatus.error),
        );
  }

  void _onConnectionUpdate(String deviceId, ConnectionStateUpdate update) {
    switch (update.connectionState) {
      case DeviceConnectionState.connected:
        _writeChars[deviceId] = QualifiedCharacteristic(
          serviceId: _serviceUuid,
          characteristicId: _writeCharUuid,
          deviceId: deviceId,
        );
        _subscribeNotifications(deviceId);
        _setStatus(deviceId, DevStatus.connected);
      case DeviceConnectionState.disconnected:
        _writeChars.remove(deviceId);
        _notifySubs[deviceId]?.cancel();
        _notifySubs.remove(deviceId);
        _setStatus(deviceId, DevStatus.disconnected);
      default:
        break;
    }
  }

  void _subscribeNotifications(String deviceId) {
    final char = QualifiedCharacteristic(
      serviceId: _notifySvcUuid,
      characteristicId: _notifyCharUuid,
      deviceId: deviceId,
    );
    _notifySubs[deviceId]?.cancel();
    _notifySubs[deviceId] = _ble.subscribeToCharacteristic(char).listen((_) {});
  }

  void disconnect(String deviceId) {
    _connSubs[deviceId]?.cancel();
    _connSubs.remove(deviceId);
    _notifySubs[deviceId]?.cancel();
    _notifySubs.remove(deviceId);
    _writeChars.remove(deviceId);
    _setStatus(deviceId, DevStatus.disconnected);
  }

  // ── BLE Commands ──────────────────────────────────────────────────────────

  Future<void> sendCct(String deviceId, {required int ww, required int br}) =>
      _write(deviceId, TrionesProtocol.cct(ww: ww, br: br));

  Future<void> sendCctToDevices(List<String> deviceIds,
          {required int ww, required int br}) =>
      Future.wait(deviceIds.map((id) => sendCct(id, ww: ww, br: br)));

  Future<void> _write(String deviceId, List<int> bytes) async {
    final char = _writeChars[deviceId];
    if (char == null) return;
    try {
      await _ble.writeCharacteristicWithoutResponse(char, value: bytes);
    } catch (_) {}
  }

  void _setStatus(String deviceId, DevStatus status) {
    _status[deviceId] = status;
    notifyListeners();
  }

  void renameDevice(String deviceId, String name) {
    final idx = _knownDevices.indexWhere((d) => d.id == deviceId);
    if (idx == -1) return;
    _knownDevices[idx] = _knownDevices[idx].copyWith(customName: name);
    _storage.saveDevices(_knownDevices);
    notifyListeners();
  }

  void removeDevice(String deviceId) {
    disconnect(deviceId);
    _knownDevices.removeWhere((d) => d.id == deviceId);
    _storage.saveDevices(_knownDevices);
    notifyListeners();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _bleStatusSub?.cancel();
    stopScan();
    for (final id in List.of(_connSubs.keys)) {
      disconnect(id);
    }
    super.dispose();
  }
}
