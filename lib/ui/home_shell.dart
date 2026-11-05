import 'package:flutter/material.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/state/preferences_controller.dart';
import 'package:piste/ui/about_page.dart';
import 'package:piste/ui/application_detail_page.dart';
import 'package:piste/ui/application_form_page.dart';
import 'package:piste/ui/applications_page.dart';
import 'package:piste/ui/home_page.dart';
import 'package:piste/ui/profile_page.dart';
import 'package:piste/ui/settings_page.dart';
import 'package:piste/ui/statistics_page.dart';
import 'package:piste/ui/widgets/app_drawer.dart';
import 'package:piste/ui/widgets/state_views.dart';

/// Scaffold shared by the three main tabs, with the side menu.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.controller,
    required this.preferences,
  });

  /// Listened to, not owned: `PisteApp` creates and disposes both.
  final ApplicationsController controller;
  final PreferencesController preferences;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  /// Kept here, not in the applications tab, so the typed text survives a
  /// tab change.
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// F5: the field only exists once the tab is built, hence after the frame.
  void _openSearch() {
    setState(() => _tab = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _openDetail(JobApplication application) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ApplicationDetailPage(
        controller: widget.controller,
        application: application,
      ),
    ),
  );

  void _openForm() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ApplicationFormPage(controller: widget.controller),
    ),
  );

  void _openSecondary(DrawerEntry entry) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => switch (entry) {
        DrawerEntry.profile => ProfilePage(
          applications: widget.controller,
          preferences: widget.preferences,
        ),
        DrawerEntry.settings => SettingsPage(preferences: widget.preferences),
        DrawerEntry.about => const AboutPage(),
      },
    ),
  );

  /// The current tab, or the state view that replaces it (spec section 5).
  Widget _body(ApplicationsController controller) {
    return switch (controller.state) {
      LoadState.loading => const LoadingView(),
      LoadState.error => ErrorView(
        message: controller.errorMessage!,
        onRetry: controller.load,
      ),
      // Statistics show zeros instead (F19).
      LoadState.empty when _tab != 2 => EmptyView(onAdd: _openForm),
      _ => switch (_tab) {
        1 => ApplicationsPage(
          applications: controller.visibleApplications,
          filter: controller.filter,
          searchController: _search,
          searchFocus: _searchFocus,
          onQueryChanged: controller.setQuery,
          onStatusChanged: controller.setStatus,
          onClearFilter: controller.clearFilter,
          onOpen: _openDetail,
        ),
        2 => StatisticsPage(applications: controller.applications),
        _ => HomePage(
          applications: controller.applications,
          firstName: widget.preferences.firstName,
          onSeeAll: () => setState(() => _tab = 1),
          onSearch: _openSearch,
          onOpen: _openDetail,
        ),
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      // The preferences too: the greeting shows the first name (F1).
      listenable: Listenable.merge([controller, widget.preferences]),
      builder: (context, _) {
        final state = controller.state;
        // Adding is only offered once the stored data is known.
        final canAdd = state == LoadState.success || state == LoadState.empty;
        return Scaffold(
          appBar: AppBar(title: const Text('Piste')),
          drawer: AppDrawer(onSelected: _openSecondary),
          body: _body(controller),
          floatingActionButton: canAdd
              ? FloatingActionButton(
                  tooltip: 'Ajouter une candidature',
                  onPressed: _openForm,
                  child: const Icon(Icons.add_rounded),
                )
              : null,
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
      },
    );
  }
}
