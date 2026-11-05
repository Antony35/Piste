import 'package:flutter/material.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/application_form_page.dart';
import 'package:piste/ui/format.dart';
import 'package:piste/ui/widgets/status_chip.dart';

/// Read-only view of one application, with edit and delete actions.
class ApplicationDetailPage extends StatefulWidget {
  const ApplicationDetailPage({
    super.key,
    required this.controller,
    required this.application,
  });

  final ApplicationsController controller;

  /// The version that was tapped; newer versions are read from [controller].
  final JobApplication application;

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  late JobApplication _application;
  bool _deleting = false;

  int get _id => widget.application.id!;

  @override
  void initState() {
    super.initState();
    _application = widget.application;
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  /// Picks up edits. After a deletion `byId` returns `null`: the last version
  /// stays on screen while the page closes.
  void _refresh() {
    final latest = widget.controller.byId(_id);
    if (latest != null) setState(() => _application = latest);
  }

  void _edit() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ApplicationFormPage(
        controller: widget.controller,
        initial: _application,
      ),
    ),
  );

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(application: _application),
    );
    // `null` when the dialog is dismissed by tapping outside or going back.
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await widget.controller.delete(_id);
      if (mounted) Navigator.of(context).pop();
    } on StorageException {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suppression impossible. Réessayez.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final application = _application;
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Modifier',
            onPressed: _deleting ? null : _edit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Supprimer',
            onPressed: _deleting ? null : _delete,
            icon: const Icon(Icons.delete_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Few rows, known in advance: no need for a lazy ListView.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              application.position,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  application.company,
                  style: text.titleMedium?.copyWith(color: muted),
                ),
                StatusChip(status: application.status),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              rows: [
                _InfoRow(
                  icon: Icons.send_rounded,
                  label: 'Date de candidature',
                  value: _date(application.appliedOn),
                  empty: 'Non renseignée',
                ),
                _InfoRow(
                  icon: Icons.notifications_rounded,
                  label: 'Prochaine relance',
                  value: _date(application.nextFollowUp),
                  empty: 'Aucune',
                ),
                _InfoRow(
                  icon: Icons.link_rounded,
                  label: "Lien vers l'offre",
                  value: application.url,
                  empty: 'Aucun lien',
                ),
                _InfoRow(
                  icon: Icons.notes_rounded,
                  label: 'Notes',
                  value: application.notes,
                  empty: 'Aucune note',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              rows: [
                _InfoRow(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Créée le',
                  value: shortDateTime(application.createdAt),
                ),
                _InfoRow(
                  icon: Icons.update_rounded,
                  label: 'Modifiée le',
                  value: shortDateTime(application.updatedAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String? _date(DateTime? date) => date == null ? null : shortDate(date);
}

/// A card grouping rows, with a divider between them.
class _Section extends StatelessWidget {
  const _Section({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: ListTile.divideTiles(context: context, tiles: rows).toList(),
      ),
    );
  }
}

/// One field: icon, small label, then its value or a placeholder.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.empty = 'Non renseigné',
  });

  final IconData icon;
  final String label;
  final String? value;

  /// Shown when [value] is `null`.
  final String empty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final value = this.value;

    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(
        label,
        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      subtitle: Text(
        value ?? empty,
        style: text.bodyLarge?.copyWith(
          color: value == null ? scheme.onSurfaceVariant : scheme.onSurface,
        ),
      ),
    );
  }
}

/// Asks before deleting; pops `true` to confirm, `false` to cancel.
class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.delete_rounded),
      title: const Text('Supprimer la candidature ?'),
      content: Text(
        'La candidature « ${application.position} » chez '
        '${application.company} sera supprimée définitivement.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
