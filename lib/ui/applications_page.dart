import 'package:flutter/material.dart';
import 'package:piste/models/application_filter.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/widgets/application_tile.dart';
import 'package:piste/ui/widgets/state_views.dart';

/// Applications tab: search field, status chips and the matching list.
class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({
    super.key,
    required this.applications,
    required this.filter,
    required this.searchController,
    required this.searchFocus,
    required this.onQueryChanged,
    required this.onStatusChanged,
    required this.onClearFilter,
    required this.onOpen,
  });

  /// Already filtered and sorted.
  final List<JobApplication> applications;
  final ApplicationFilter filter;

  /// Owned by the shell, so the text survives a tab change.
  final TextEditingController searchController;
  final FocusNode searchFocus;

  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ApplicationStatus?> onStatusChanged;
  final VoidCallback onClearFilter;

  /// Called with the tapped application.
  final ValueChanged<JobApplication> onOpen;

  void _clearAll() {
    searchController.clear();
    onClearFilter();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: SearchBar(
            controller: searchController,
            focusNode: searchFocus,
            hintText: 'Entreprise ou poste',
            leading: const Icon(Icons.search_rounded),
            trailing: [
              if (filter.query.isNotEmpty)
                IconButton(
                  tooltip: 'Effacer la recherche',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    searchController.clear();
                    onQueryChanged('');
                  },
                ),
            ],
            onChanged: onQueryChanged,
          ),
        ),
        _StatusChips(selected: filter.status, onChanged: onStatusChanged),
        Expanded(
          child: applications.isEmpty
              ? NoResultsView(onClear: _clearAll)
              : ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  // Extra bottom space keeps the last card clear of the
                  // floating button.
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                  itemCount: applications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    return ApplicationTile(
                      key: ValueKey(application.id),
                      application: application,
                      now: now,
                      onTap: () => onOpen(application),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// « Toutes » or one status, scrolling sideways on narrow screens.
class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.selected, required this.onChanged});

  final ApplicationStatus? selected;
  final ValueChanged<ApplicationStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('Toutes'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          for (final status in ApplicationStatus.values)
            FilterChip(
              label: Text(status.label),
              selected: selected == status,
              // Tapping the selected chip again goes back to « Toutes ».
              onSelected: (isSelected) => onChanged(isSelected ? status : null),
            ),
        ],
      ),
    );
  }
}
