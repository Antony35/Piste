import 'package:flutter/material.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/applications_page.dart';
import 'package:piste/ui/home_page.dart';

/// Scaffold shared by the three main tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.applications});

  final List<JobApplication> applications;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piste')),
      body: switch (_tab) {
        1 => ApplicationsPage(applications: widget.applications),
        2 => const _Placeholder(icon: Icons.donut_large_rounded),
        _ => HomePage(
          applications: widget.applications,
          onSeeAll: () => setState(() => _tab = 1),
        ),
      },
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter une candidature',
        // TODO(step 4): open the application form.
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Candidatures',
          ),
          NavigationDestination(
            icon: Icon(Icons.donut_large_rounded),
            selectedIcon: Icon(Icons.donut_large_rounded),
            label: 'Statistiques',
          ),
        ],
      ),
    );
  }
}

/// Temporary tab content until the real screen exists.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: muted),
          const SizedBox(height: 12),
          Text('Écran en construction', style: TextStyle(color: muted)),
        ],
      ),
    );
  }
}
