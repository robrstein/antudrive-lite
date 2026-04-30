import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Icon list for lamp groups. Uses both Material Icons and MDI automotive icons.
final kIconOptions = <({IconData icon, String label})>[
  // ── MDI Luces de vehículo (iconos reales de tablero) ──────────────────────
  (icon: MdiIcons.carLightDimmed, label: 'Luces bajas'),
  (icon: MdiIcons.carLightHigh,   label: 'Luces altas'),
  (icon: MdiIcons.carLightFog,    label: 'Neblineros'),
  (icon: MdiIcons.engine,         label: 'Check Engine'),
  (icon: MdiIcons.battery,        label: 'Batería MDI'),
  (icon: MdiIcons.oil,            label: 'Aceite'),
  // ── Luces de vehículo ─────────────────────────────────────────────────────
  (icon: Icons.wb_incandescent, label: 'Bajas'),
  (icon: Icons.brightness_high, label: 'Altas'),
  (icon: Icons.foggy, label: 'Neblineros'),
  (icon: Icons.flashlight_on, label: 'Spot'),
  (icon: Icons.wb_twilight, label: 'Posición'),
  (icon: Icons.wb_sunny_outlined, label: 'DRL'),
  (icon: Icons.nights_stay, label: 'Nocturno'),
  (icon: Icons.brightness_auto, label: 'Auto'),
  (icon: Icons.visibility_outlined, label: 'Visibil.'),
  (icon: Icons.highlight, label: 'Faro'),
  (icon: Icons.lightbulb_outline, label: 'Ampolleta'),
  (icon: Icons.settings_brightness, label: 'Brillo'),
  (icon: Icons.light_mode, label: 'Luz día'),
  (icon: Icons.dark_mode, label: 'Luz noche'),
  (icon: Icons.flare, label: 'Flash'),
  // ── Indicadores de tablero ────────────────────────────────────────────────
  (icon: Icons.warning_amber_rounded, label: 'C. Engine'),
  (icon: Icons.report_problem, label: 'Avería'),
  (icon: Icons.opacity, label: 'Aceite'),
  (icon: Icons.water_drop, label: 'Refriger.'),
  (icon: Icons.device_thermostat, label: 'Temp.'),
  (icon: Icons.battery_alert, label: 'Batería'),
  (icon: Icons.battery_charging_full, label: 'Carga'),
  (icon: Icons.local_gas_station, label: 'Combustib.'),
  (icon: Icons.air, label: 'Presión'),
  (icon: Icons.tire_repair, label: 'Neumático'),
  (icon: Icons.speed, label: 'Velocímet.'),
  (icon: Icons.thermostat, label: 'Climátiz.'),
  // ── Motor / Mecánico ──────────────────────────────────────────────────────
  (icon: Icons.engineering, label: 'Motor'),
  (icon: Icons.car_repair, label: 'Servicio'),
  (icon: Icons.build_circle, label: 'Reparac.'),
  (icon: Icons.tune, label: 'Ajuste'),
  (icon: Icons.sensors, label: 'Sensor'),
  (icon: Icons.electric_bolt, label: 'Eléctrico'),
  (icon: Icons.power_settings_new, label: 'Encendido'),
  // ── Vehículo ──────────────────────────────────────────────────────────────
  (icon: Icons.directions_car, label: 'Auto'),
  (icon: Icons.directions_car_filled, label: 'Auto 2'),
  (icon: Icons.two_wheeler, label: 'Moto'),
  (icon: Icons.airport_shuttle, label: 'Furgón'),
  (icon: Icons.radar, label: 'Radar'),
  (icon: Icons.add_road, label: 'Ruta'),
  (icon: Icons.route, label: 'Camino'),
  // ── Varios ────────────────────────────────────────────────────────────────
  (icon: Icons.star_outline, label: 'Favorito'),
  (icon: Icons.flash_on, label: 'Destello'),
  (icon: Icons.circle, label: 'Círculo'),
  (icon: Icons.grid_on, label: 'Grilla'),
];
