import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';
import '../providers/groups_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/about_screen.dart';

class DeviceDrawer extends StatefulWidget {
  const DeviceDrawer({super.key});

  @override
  State<DeviceDrawer> createState() => _DeviceDrawerState();
}

class _DeviceDrawerState extends State<DeviceDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BleProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ble      = context.watch<BleProvider>();
    final settings = context.watch<SettingsProvider>();
    final groups   = context.watch<GroupsProvider>();
    final theme    = Theme.of(context);

    final devicesInGroups = <String>{};
    for (final g in groups.groups) {
      devicesInGroups.addAll(g.deviceIds);
    }

    final devicesToShow = ble.filterQstar
        ? ble.knownDevices
            .where((d) => d.displayName.toLowerCase().startsWith('qstar'))
            .toList()
        : ble.knownDevices;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(vehicleName: settings.vehicleName),

            // ── BLE status warning ──────────────────────────────────────
            if (!ble.bleReady || !ble.permissionsGranted)
              Container(
                color: theme.colorScheme.errorContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16,
                        color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        !ble.permissionsGranted
                            ? 'Faltan permisos BLE'
                            : 'Bluetooth inactivo',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                    if (!ble.permissionsGranted)
                      TextButton(
                        onPressed: () => ble.requestPermissions(),
                        child: const Text('Conceder',
                            style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),

            // ── Scan row ────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Dispositivos BLE',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (ble.scanning)
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: ble.scanning
                        ? ble.stopScan
                        : () => ble.startScan(
                            context
                                .read<SettingsProvider>()
                                .scanTimeoutSeconds),
                    icon: Icon(
                        ble.scanning ? Icons.stop : Icons.search, size: 16),
                    label: Text(ble.scanning ? 'Detener' : 'Buscar',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            // ── QStar filter toggle ─────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: [
                  const Text('Solo QStar*',
                      style: TextStyle(fontSize: 12)),
                  const Spacer(),
                  Switch(
                    value: ble.filterQstar,
                    onChanged: (v) => ble.setFilterQstar(v),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),

            // ── Status message ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(ble.statusMessage,
                  style: TextStyle(
                      fontSize: 11, color: theme.colorScheme.outline)),
            ),

            const Divider(height: 12),

            // ── Device list ─────────────────────────────────────────────
            Expanded(
              child: devicesToShow.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bluetooth_searching,
                              size: 40, color: theme.colorScheme.outline),
                          const SizedBox(height: 8),
                          Text(
                            ble.knownDevices.isEmpty
                                ? 'Sin dispositivos.\nPresiona Buscar.'
                                : 'Sin dispositivos QStar*.\nDesactiva el filtro o busca.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: devicesToShow.length,
                      itemBuilder: (ctx, i) {
                        final dev = devicesToShow[i];
                        final status = ble.statusOf(dev.id);
                        return _DeviceTile(
                          name: dev.displayName,
                          status: status,
                          inGroup: devicesInGroups.contains(dev.id),
                          onTap: () => ble.toggleConnection(dev.id),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline, size: 20),
              title:
                  const Text('Acerca de', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String vehicleName;
  const _DrawerHeader({required this.vehicleName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.directions_car_filled,
              color: theme.colorScheme.onPrimary, size: 32),
          const SizedBox(height: 8),
          Text(vehicleName,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold)),
          Text('AntuDrive Lite',
              style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onPrimary.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final String name;
  final DevStatus status;
  final bool inGroup;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.name,
    required this.status,
    required this.inGroup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (status) {
      DevStatus.connected    => (Icons.bluetooth_connected, Colors.greenAccent),
      DevStatus.connecting   => (Icons.bluetooth_searching, Colors.orangeAccent),
      DevStatus.error        => (Icons.bluetooth_disabled, Colors.redAccent),
      DevStatus.disconnected => (Icons.bluetooth, Colors.grey),
    };

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: color),
      title: Text(name, style: const TextStyle(fontSize: 13)),
      trailing: inGroup
          ? Icon(Icons.group_outlined,
              size: 16,
              color: Colors.blueAccent.withValues(alpha: 0.8))
          : null,
      onTap: onTap,
    );
  }
}
