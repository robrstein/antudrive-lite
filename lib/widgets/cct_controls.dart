import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lamp_group.dart';
import '../providers/ble_provider.dart';
import '../providers/groups_provider.dart';

const _kMin = 2500;
const _kMax = 8000;

int _kToWarmth(int k) =>
    (100 - (k - _kMin) * 100 ~/ (_kMax - _kMin)).clamp(0, 100);

class CctControls extends StatelessWidget {
  final LampGroup group;
  const CctControls({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final ble    = context.watch<BleProvider>();
    final groups = context.read<GroupsProvider>();
    final theme  = Theme.of(context);

    final connectedDevs =
        group.deviceIds.where((id) => ble.isConnected(id)).toList();

    void sendCct() {
      unawaited(ble.sendCctToDevices(connectedDevs,
          ww: group.warmth, br: group.brightness));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Group header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(group.icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(group.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Wrap(
                spacing: 4,
                children: group.deviceIds.map((id) {
                  final connected = ble.isConnected(id);
                  return Chip(
                    label: Text(id.substring(id.length - 5),
                        style: const TextStyle(fontSize: 10)),
                    backgroundColor: connected
                        ? Colors.greenAccent.withValues(alpha: 0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                        color: connected
                            ? Colors.greenAccent
                            : Colors.transparent),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (connectedDevs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Sin dispositivos conectados en este grupo.',
                style:
                    TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
          ),

        // ── Temperature slider ────────────────────────────────────────────
        _SliderRow(
          icon: Icons.wb_sunny_outlined,
          leftLabel: '🟡 Cálido',
          rightLabel: 'Frío ❄️',
          value: (100 - group.warmth).toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: Color.lerp(
              const Color(0xFFFFBF00),
              const Color(0xFFB3E5FC),
              (100 - group.warmth) / 100.0)!,
          onChanged: (v) => groups.setGroupWarmth(group.id, 100 - v.round()),
          onChangeEnd: (_) => sendCct(),
        ),

        // ── Brightness slider ─────────────────────────────────────────────
        _SliderRow(
          icon: Icons.brightness_6_outlined,
          leftLabel: '5%',
          rightLabel: '100%',
          value: group.brightness.toDouble(),
          min: 5,
          max: 100,
          divisions: 95,
          activeColor: theme.colorScheme.primary,
          onChanged: (v) => groups.setGroupBrightness(group.id, v.round()),
          onChangeEnd: (_) => sendCct(),
        ),

        // ── CCT presets ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              for (final k in [3000, 4300, 5000, 6000, 8000]) ...[
                Expanded(
                  child: _PresetButton(
                    label: '${k}K',
                    onPressed: connectedDevs.isEmpty
                        ? null
                        : () {
                            final w = _kToWarmth(k);
                            unawaited(groups.setGroupWarmth(group.id, w));
                            unawaited(ble.sendCctToDevices(connectedDevs,
                                ww: w, br: group.brightness));
                          },
                  ),
                ),
                if (k != 8000) const SizedBox(width: 4),
              ],
            ],
          ),
        ),

        // ── Brightness presets ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              for (final pct in [100, 75, 50, 25]) ...[
                Expanded(
                  child: _PresetButton(
                    label: '$pct%',
                    onPressed: connectedDevs.isEmpty
                        ? null
                        : () {
                            unawaited(
                                groups.setGroupBrightness(group.id, pct));
                            unawaited(ble.sendCctToDevices(connectedDevs,
                                ww: group.warmth, br: pct));
                          },
                  ),
                ),
                if (pct != 25) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String leftLabel;
  final String rightLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _SliderRow({
    required this.icon,
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.activeColor,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 4),
          Text(leftLabel,
              style:
                  TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: activeColor,
                thumbColor: activeColor,
                overlayColor: activeColor.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
              ),
            ),
          ),
          Text(rightLabel,
              style:
                  TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _PresetButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 36),
          textStyle: const TextStyle(fontSize: 12)),
      child: Text(label),
    );
  }
}
