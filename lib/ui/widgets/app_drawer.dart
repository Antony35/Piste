import 'package:flutter/material.dart';

/// The secondary screens, reached from the side menu.
enum DrawerEntry {
  profile('Profil', Icons.person_outline_rounded),
  settings('Paramètres', Icons.settings_outlined),
  about('À propos', Icons.info_outline_rounded);

  const DrawerEntry(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Side menu. It holds only the secondary screens: the main ones are in the
/// bottom bar, so nothing is offered twice (N1).
///
/// Built with [ListTile]s rather than `NavigationDrawer`, whose entries have
/// a fixed height: with large text, « Paramètres » overflowed on a small
/// screen.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onSelected});

  /// Called after the menu starts closing, so going back from the opened
  /// screen lands on the tab, not on an open menu.
  final ValueChanged<DrawerEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Piste',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Suivi de candidatures',
                    style: text.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            for (final entry in DrawerEntry.values)
              ListTile(
                leading: Icon(entry.icon),
                title: Text(entry.label),
                shape: const StadiumBorder(),
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                  onSelected(entry);
                },
              ),
          ],
        ),
      ),
    );
  }
}
