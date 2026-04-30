import 'dart:typed_data';

final class TrionesProtocol {
  static Uint8List powerOn() => Uint8List.fromList(const [0xCC, 0x23, 0x33]);

  static Uint8List powerOff() => Uint8List.fromList(const [0xCC, 0x24, 0x33]);

  static Uint8List queryState() => Uint8List.fromList(const [0xEF, 0x01, 0x77]);

  /// Handshake inicial para dispositivos con clave (Drive Light APK, PwdFLActivity).
  /// Respuesta esperada del dispositivo: 2F 00 00 00 00 00 00 00 00 00 00 F2
  static Uint8List handshake() => Uint8List.fromList(const [
    0xF2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2F,
  ]);

  /// Protocolo CCT real descubierto via ingenieria inversa de Drive Light.apk.
  /// Clase: com.fl.light.utils.a  metodo: n(int WW, int brightness, int mode)
  ///
  /// [ww] porcentaje de blanco calido: 0–100 (0=frio puro, 100=calido puro).
  ///      CW se calcula automaticamente como 100–WW.
  /// [br] brillo porcentaje: 5–100 (valores 0–4 no producen luz visible;
  ///      la APK usa rango 5–100 de uno en uno).
  ///
  /// Formato: 56 [WW] [CW=100-WW] [BR] 00 00 AA
  static Uint8List cct({required int ww, required int br}) {
    final wwSafe = _clamp(ww, 0, 100);
    final brSafe = _clamp(br, 0, 100);
    final cw = 100 - wwSafe;
    return Uint8List.fromList([0x56, wwSafe, cw, brSafe, 0x00, 0x00, 0xAA]);
  }

  static String formatHex(List<int> bytes) {
    if (bytes.isEmpty) {
      return '<vacio>';
    }
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  static String summarizeNotification(List<int> bytes) {
    if (bytes.isEmpty) {
      return 'Notificacion vacia';
    }
    if (bytes.length >= 3 && bytes.first == 0x66) {
      final powerByte = bytes[2];
      if (powerByte == 0x23) {
        return 'Estado reportado: encendido';
      }
      if (powerByte == 0x24) {
        return 'Estado reportado: apagado';
      }
    }
    return 'Notificacion recibida';
  }

  static int _clamp(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
