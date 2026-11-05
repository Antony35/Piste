import 'package:flutter/material.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/application_detail_page.dart';
import 'package:piste/ui/application_form_page.dart';
import 'package:piste/ui/applications_page.dart';
import 'package:piste/ui/home_page.dart';

/// Scaffold shared by the three main tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  /// Listened to, not owned: `PisteApp` creates and disposes it.
  final ApplicationsController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  void _openDetail(JobApplication application) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ApplicationDetailPage(
        controller: widget.controller,
        application: application,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piste')),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final applications = widget.controller.applications;
          return switch (_tab) {
            1 => ApplicationsPage(
              applications: applications,
              onOpen: _openDetail,
            ),
            2 => const _Placeholder(icon: Icons.donut_large_rounded),
            _ => HomePage(
              applications: applications,
              onSeeAll: () => setState(() => _tab = 1),
              onOpen: _openDetail,
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter une candidature',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ApplicationFormPage(controller: widget.controller),
          ),
        ),
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
