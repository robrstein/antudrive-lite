import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/icon_options.dart';
import '../models/lamp_group.dart';
import '../providers/ble_provider.dart';
import '../providers/groups_provider.dart';

class GroupEditorScreen extends StatefulWidget {
  final LampGroup? group;
  const GroupEditorScreen({super.key, this.group});

  @override
  State<GroupEditorScreen> createState() => _GroupEditorScreenState();
}

class _GroupEditorScreenState extends State<GroupEditorScreen> {
  late TextEditingController _nameCtrl;
  late int _selectedIcon;
  late Set<String> _selectedDevices;
  bool _showAllDevices = false;
  bool get _isNew => widget.group == null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.group?.name ?? '');
    _selectedIcon = widget.group?.iconIndex ?? 0;
    _selectedDevices = Set.of(widget.group?.deviceIds ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre no puede estar vacío')));
      return;
    }
    final groups = context.read<GroupsProvider>();
    if (_isNew) {
      groups.addGroup(LampGroup(
        id: groups.generateId(),
        name: name,
        iconIndex: _selectedIcon,
        deviceIds: _selectedDevices.toList(),
      ));
    } else {
      groups.updateGroup(widget.group!.copyWith(
        name: name,
        iconIndex: _selectedIcon,
        deviceIds: _selectedDevices.toList(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final groups = context.watch<GroupsProvider>();
    final theme = Theme.of(context);

    // Icons already used by other groups
    final usedIconIndices = groups.groups
        .where((g) => g.id != widget.group?.id)
        .map((g) => g.iconIndex)
        .toSet();

    // Filter devices:
    // - Always show devices already in THIS group (checked or not, regardless of BT status)
    // - Show other known devices only if currently BT-connected
    // - "Mostrar todos" bypasses all filters
    final filteredDevices = _showAllDevices
        ? ble.knownDevices
        : ble.knownDevices
            .where((d) =>
                _selectedDevices.contains(d.id) || ble.isConnected(d.id))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Nuevo Grupo' : 'Editar Grupo'),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar grupo',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Eliminar grupo'),
                    content: Text('¿Eliminar "${widget.group!.name}"?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar')),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  // ignore: use_build_context_synchronously
                  context.read<GroupsProvider>().deleteGroup(widget.group!.id);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            ),
          TextButton(onPressed: _save, child: const Text('Guardar')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Name ────────────────────────────────────────────────────
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Icon picker ─────────────────────────────────────────────
          Text('Icono', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            'Los iconos ya usados en otros grupos están ocultos.',
            style: TextStyle(
                fontSize: 11, color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(kIconOptions.length, (i) {
              // Hide icons used by other groups (unless it's the selected one)
              if (usedIconIndices.contains(i) && i != _selectedIcon) {
                return const SizedBox.shrink();
              }
              final opt = kIconOptions[i];
              final selected = i == _selectedIcon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 64,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: selected
                        ? Border.all(
                            color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(opt.icon,
                          size: 26,
                          color: selected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 4),
                      Text(
                        opt.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // ── Device selection ─────────────────────────────────────────
          Row(
            children: [
              Text('Dispositivos', style: theme.textTheme.labelLarge),
              const Spacer(),
              const Text('Mostrar todos', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Switch(
                value: _showAllDevices,
                onChanged: (v) => setState(() => _showAllDevices = v),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (filteredDevices.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _showAllDevices
                    ? 'No hay dispositivos conocidos.\nBusca desde el menú lateral.'
                    : 'No hay dispositivos conectados.\nConecta un dispositivo desde el menú lateral o activa "Mostrar todos".',
                style: TextStyle(
                    color: theme.colorScheme.outline, fontSize: 13),
              ),
            )
          else
            ...filteredDevices.map((dev) => CheckboxListTile(
                  value: _selectedDevices.contains(dev.id),
                  title: Text(dev.displayName),
                  subtitle: Text(dev.id,
                      style: const TextStyle(fontSize: 11)),
                  secondary: Icon(
                    ble.isConnected(dev.id)
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    size: 18,
                    color: ble.isConnected(dev.id)
                        ? Colors.greenAccent
                        : Colors.grey,
                  ),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selectedDevices.add(dev.id);
                    } else {
                      _selectedDevices.remove(dev.id);
                    }
                  }),
                )),
        ],
      ),
    );
  }
}
