import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/groups_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/group_editor_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/cct_controls.dart';
import '../widgets/device_drawer.dart';
import '../widgets/group_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups   = context.watch<GroupsProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme    = Theme.of(context);
    final selected = groups.selectedGroup;

    return Scaffold(
      drawer: const DeviceDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(settings.vehicleName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Group tiles row ─────────────────────────────────────────
            SizedBox(
              height: 96,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                // Show "add" button only when no group exists yet
                itemCount: groups.groups.length + (groups.canAddGroup ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == groups.groups.length) {
                    return _AddGroupTile(onTap: () => Navigator.push(ctx,
                        MaterialPageRoute(
                            builder: (_) => const GroupEditorScreen())));
                  }
                  final g = groups.groups[i];
                  return GroupTile(
                    group: g,
                    isSelected: g.id == groups.selectedGroupId,
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // ── CCT controls for selected group ─────────────────────────
            if (selected != null)
              CctControls(key: ValueKey(selected.id), group: selected)
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 12),
                    Text('Crea un grupo para comenzar',
                        style: TextStyle(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddGroupTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddGroupTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 26, color: theme.colorScheme.outline),
            const SizedBox(height: 4),
            Text('Nuevo',
                style: TextStyle(
                    fontSize: 11, color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}
