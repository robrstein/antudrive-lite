import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _themes = [
    (label: 'Ámbar oscuro',  seed: Color(0xFFFFBF00), dark: true),
    (label: 'Azul moderno',  seed: Color(0xFF1E88E5), dark: true),
    (label: 'Naranja claro', seed: Color(0xFFFF6D00), dark: false),
  ];

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Theme selector ────────────────────────────────────────────
          Text('Tema', style: theme.textTheme.labelLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _themes.length; i++) ...[
                Expanded(child: _ThemeCard(
                  label: _themes[i].label,
                  seed: _themes[i].seed,
                  dark: _themes[i].dark,
                  selected: sp.themeIndex == i,
                  onTap: () => sp.setThemeIndex(i),
                )),
                if (i < _themes.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 28),

          // ── Vehicle name ──────────────────────────────────────────────
          Text('Nombre del vehículo', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _VehicleNameField(
              initial: sp.vehicleName, onSubmit: sp.setVehicleName),
          const SizedBox(height: 28),

          // ── Scan timeout ──────────────────────────────────────────────
          Text('Tiempo de búsqueda BLE: ${sp.scanTimeoutSeconds}s',
              style: theme.textTheme.labelLarge),
          Slider(
            value: sp.scanTimeoutSeconds.toDouble(),
            min: 5,
            max: 30,
            divisions: 5,
            label: '${sp.scanTimeoutSeconds}s',
            onChanged: (v) => sp.setScanTimeout(v.round()),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final Color seed;
  final bool dark;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeCard({
    required this.label,
    required this.seed,
    required this.dark,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: dark ? Brightness.dark : Brightness.light);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? seed : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: seed.withValues(alpha: 0.4), blurRadius: 8)]
              : [],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(height: 24, color: cs.primary),
            const SizedBox(height: 4),
            Container(height: 12, color: cs.secondaryContainer),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface)),
            if (selected) Icon(Icons.check_circle, size: 16, color: seed),
          ],
        ),
      ),
    );
  }
}

class _VehicleNameField extends StatefulWidget {
  final String initial;
  final Future<void> Function(String) onSubmit;
  const _VehicleNameField({required this.initial, required this.onSubmit});

  @override
  State<_VehicleNameField> createState() => _VehicleNameFieldState();
}

class _VehicleNameFieldState extends State<_VehicleNameField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            widget.onSubmit(_ctrl.text.trim());
            FocusScope.of(context).unfocus();
          },
        ),
      ),
      onSubmitted: (v) => widget.onSubmit(v.trim()),
    );
  }
}
