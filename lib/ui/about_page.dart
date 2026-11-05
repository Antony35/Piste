import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piste/models/app_version.dart';

/// Version, privacy and licenses (F24).
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  /// `pubspec.yaml` is bundled as an asset (see its `assets` section), so the
  /// version shown is always the one that was built, with no extra package.
  late final Future<AppVersion?> _version = rootBundle
      .loadString('pubspec.yaml')
      .then(AppVersion.parse);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: FutureBuilder<AppVersion?>(
        future: _version,
        builder: (context, snapshot) {
          final version = snapshot.data;
          final versionText = switch (snapshot.connectionState) {
            ConnectionState.done when version != null =>
              'Version ${version.label}',
            ConnectionState.done => 'Version inconnue',
            _ => 'Version…',
          };

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Piste',
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        versionText,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Suivi de candidatures hors ligne pour Android.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.lock_outline_rounded),
                  title: Text('Vos données restent sur cet appareil'),
                  subtitle: Text(
                    "Piste fonctionne sans compte ni connexion à Internet : "
                    "rien n'est envoyé ailleurs.",
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Licences'),
                  subtitle: const Text('Logiciels libres utilisés par Piste'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Piste',
                    applicationVersion: version?.label,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
