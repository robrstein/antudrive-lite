import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lamp_group.dart';
import '../providers/ble_provider.dart';
import '../providers/groups_provider.dart';
import '../screens/group_editor_screen.dart';

class GroupTile extends StatelessWidget {
  final LampGroup group;
  final bool isSelected;

  const GroupTile({super.key, required this.group, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final groups = context.read<GroupsProvider>();
    final theme = Theme.of(context);

    final connectedCount =
        group.deviceIds.where((id) => ble.isConnected(id)).length;
    final total = group.deviceIds.length;

    return GestureDetector(
      onTap: () {
        groups.selectGroup(group.id);
        for (final id in group.deviceIds) {
          ble.connect(id);
        }
      },
      onLongPress: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GroupEditorScreen(group: group)),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                group.icon,
                size: 22,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                group.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (total > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '$connectedCount/$total',
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
