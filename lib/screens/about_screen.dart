import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _githubUrl =
      'https://github.com/robrstein/antudrive-lite/releases';

  Future<void> _launch(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── App icon ────────────────────────────────────────────────────
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.directions_car_filled,
                      size: 48, color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'AntuDrive Lite',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'v1.0.0  •  Free Edition',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
          const SizedBox(height: 24),

          // ── Links ────────────────────────────────────────────────────────
          _LinkTile(
            icon: Icons.code,
            title: 'GitHub — Releases',
            subtitle: 'github.com/robrstein/antudrive-lite',
            onTap: () => _launch(_githubUrl, context),
          ),
          _LinkTile(
            icon: Icons.android,
            title: 'Android — Próximamente',
            subtitle: 'APK disponible en GitHub por ahora',
            onTap: () => _launch(_githubUrl, context),
            disabled: true,
          ),
          const SizedBox(height: 8),

          // ── Description ──────────────────────────────────────────────────
          _Section(
            title: 'Descripción',
            body:
                'AntuDrive Lite controla luces BLE de vehículo (protocolo QStar CCT) '
                'mediante Bluetooth Low Energy. Permite crear un grupo de dispositivos, '
                'ajustar temperatura de color y brillo, y usar presets rápidos de iluminación.\n\n'
                'Para funciones avanzadas como múltiples grupos, presets personalizados '
                'y Modo Auto inteligente, visita AntuDrive Pro.',
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool disabled;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: disabled
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.primary,
            ),
            color: disabled
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 28,
                  color: disabled
                      ? theme.colorScheme.outline
                      : theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: disabled
                              ? theme.colorScheme.outline
                              : theme.colorScheme.onSurface,
                        )),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11, color: theme.colorScheme.outline)),
                  ],
                ),
              ),
              if (!disabled)
                Icon(Icons.open_in_new,
                    size: 16, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.5)),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
