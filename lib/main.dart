import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:piste/data/job_application_repository.dart';
import 'package:piste/data/sqlite_job_application_repository.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/home_shell.dart';
import 'package:piste/ui/theme/app_theme.dart';

void main() => runApp(PisteApp(repository: SqliteJobApplicationRepository()));

class PisteApp extends StatefulWidget {
  const PisteApp({super.key, required this.repository});

  /// Owned by the app from now on: it is closed in `dispose()`.
  final JobApplicationRepository repository;

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
    unawaited(widget.repository.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: HomeShell(controller: _controller),
    );
  }
}
