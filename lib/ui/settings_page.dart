import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/preferences.dart';
import 'package:piste/state/preferences_controller.dart';

/// First name (F22) and theme (F23), both saved on the device.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.preferences});

  final PreferencesController preferences;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final _firstName = TextEditingController(
    text: widget.preferences.firstName,
  );
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    super.dispose();
  }

  /// Something new to save, and no save already running.
  bool get _canSave =>
      !_saving && _firstName.text.trim() != widget.preferences.firstName;

  Future<void> _saveFirstName() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await widget.preferences.setFirstName(_firstName.text);
      if (!mounted) return;
      // Shows the trimmed value that was actually saved.
      _firstName.text = widget.preferences.firstName;
      _showMessage('Prénom enregistré.');
    } on StorageException {
      if (mounted) _showMessage('Enregistrement impossible. Réessayez.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _setTheme(ThemePreference? theme) async {
    if (theme == null) return;
    try {
      await widget.preferences.setTheme(theme);
    } on StorageException {
      if (mounted) _showMessage('Enregistrement impossible. Réessayez.');
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListenableBuilder(
        // The text too: the button is enabled as soon as the name changes.
        listenable: Listenable.merge([widget.preferences, _firstName]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('Prénom', style: text.titleMedium),
            const SizedBox(height: 4),
            Text(
              "Il sert à vous saluer sur l'accueil et sur votre profil. "
              'Il reste sur cet appareil.',
              style: text.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'Prénom'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.givenName],
              // Long enough for any first name, short enough for the greeting.
              inputFormatters: [LengthLimitingTextInputFormatter(40)],
              onSubmitted: (_) {
                if (_canSave) _saveFirstName();
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: _canSave ? _saveFirstName : null,
                child: const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Thème', style: text.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<ThemePreference>(
                groupValue: widget.preferences.theme,
                onChanged: _setTheme,
                child: Column(
                  children: [
                    for (final theme in ThemePreference.values)
                      RadioListTile<ThemePreference>(
                        value: theme,
                        title: Text(theme.label),
                        subtitle: theme == ThemePreference.system
                            ? const Text("Suit le réglage d'Android")
                            : null,
                        secondary: Icon(_themeIcon(theme)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _themeIcon(ThemePreference theme) => switch (theme) {
    ThemePreference.system => Icons.brightness_auto_rounded,
    ThemePreference.light => Icons.light_mode_rounded,
    ThemePreference.dark => Icons.dark_mode_rounded,
  };
}
