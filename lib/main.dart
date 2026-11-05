import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:piste/data/job_application_repository.dart';
import 'package:piste/data/shared_preferences_repository.dart';
import 'package:piste/data/sqlite_job_application_repository.dart';
import 'package:piste/models/preferences.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/state/preferences_controller.dart';
import 'package:piste/ui/home_shell.dart';
import 'package:piste/ui/theme/app_theme.dart';

Future<void> main() async {
  // Plugins can only be used once the binding exists.
  WidgetsFlutterBinding.ensureInitialized();
  // Read before the first frame, so a saved dark theme never flashes light.
  final preferences = PreferencesController(SharedPreferencesRepository());
  await preferences.load();
  runApp(
    PisteApp(
      repository: SqliteJobApplicationRepository(),
      preferences: preferences,
    ),
  );
}

class PisteApp extends StatefulWidget {
  const PisteApp({
    super.key,
    required this.repository,
    required this.preferences,
  });

  /// Owned by the app from now on: it is closed in `dispose()`.
  final JobApplicationRepository repository;

  /// Already loaded by `main()`. Owned by the app from now on: it is disposed
  /// in `dispose()`.
  final PreferencesController preferences;

  @override
  State<PisteApp> createState() => _PisteAppState();
}

class _PisteAppState extends State<PisteApp> {
  late final ApplicationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ApplicationsController(widget.repository)..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.preferences.dispose();
    unawaited(widget.repository.close());
    super.dispose();
  }

  ThemeMode get _themeMode => switch (widget.preferences.theme) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    // Rebuilt when the theme changes, which applies it at once (F23).
    return ListenableBuilder(
      listenable: widget.preferences,
      builder: (context, _) => MaterialApp(
        title: 'Piste',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: HomeShell(
          controller: _controller,
          preferences: widget.preferences,
        ),
      ),
    );
  }
}
