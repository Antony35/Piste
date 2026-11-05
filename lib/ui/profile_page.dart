import 'package:flutter/material.dart';
import 'package:piste/models/applications_summary.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/state/preferences_controller.dart';
import 'package:piste/ui/format.dart';
import 'package:piste/ui/settings_page.dart';
import 'package:piste/ui/widgets/counter_card.dart';

/// Local profile: first name, personal figures and a future account slot.
/// It shows nothing invented: no fake name, email or sign-out (F21).
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.applications,
    required this.preferences,
  });

  final ApplicationsController applications;
  final PreferencesController preferences;

  void _openSettings(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SettingsPage(preferences: preferences),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListenableBuilder(
        listenable: Listenable.merge([applications, preferences]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Identity(
              firstName: preferences.firstName,
              onEdit: () => _openSettings(context),
            ),
            const SizedBox(height: 12),
            _Figures(controller: applications),
            const SizedBox(height: 12),
            const _AccountSlot(),
          ],
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.firstName, required this.onEdit});

  final String firstName;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasName = firstName.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // The name is written just below: the avatar adds nothing to read.
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
                child: hasName
                    ? Text(initials(firstName), style: text.headlineSmall)
                    : const Icon(Icons.person_rounded, size: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasName ? firstName : 'Prénom non renseigné',
              textAlign: TextAlign.center,
              style: hasName
                  ? text.titleLarge?.copyWith(fontWeight: FontWeight.w600)
                  : text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Profil local, enregistré sur cet appareil',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: Text(
                hasName ? 'Modifier le prénom' : 'Renseigner votre prénom',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Personal figures (F20), only once the applications are known: a zero
/// during loading or after a read error would be false (rule S1).
class _Figures extends StatelessWidget {
  const _Figures({required this.controller});

  final ApplicationsController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    if (state == LoadState.loading || state == LoadState.error) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.hourglass_empty_rounded),
          title: Text(
            state == LoadState.loading
                ? 'Chiffres en cours de chargement'
                : "Chiffres indisponibles : les candidatures n'ont pas pu "
                      'être chargées.',
          ),
        ),
      );
    }

    final summary = ApplicationsSummary.from(
      controller.applications,
      DateTime.now(),
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CounterCard(
              icon: Icons.work_rounded,
              value: summary.total,
              label: 'Candidatures',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CounterCard(
              icon: Icons.workspace_premium_rounded,
              value: summary.count(ApplicationStatus.offer),
              label: 'Offres',
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder for a future account. Disabled, and says so (F21).
class _AccountSlot extends StatelessWidget {
  const _AccountSlot();

  @override
  Widget build(BuildContext context) => const Card(
    child: ListTile(
      enabled: false,
      leading: Icon(Icons.cloud_sync_rounded),
      title: Text('Compte (bientôt disponible)'),
      subtitle: Text(
        'Une prochaine version permettra de sauvegarder vos candidatures et '
        'de les retrouver sur un autre appareil.',
      ),
    ),
  );
}
