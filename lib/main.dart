import 'package:flutter/material.dart';
import 'package:piste/data/demo_applications.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/home_shell.dart';
import 'package:piste/ui/theme/app_theme.dart';

void main() =>
    runApp(PisteApp(initialApplications: demoApplications(DateTime.now())));

class PisteApp extends StatefulWidget {
  const PisteApp({super.key, this.initialApplications = const []});

  final List<JobApplication> initialApplications;

  @override
  State<PisteApp> createState() => _PisteAppState();
}

class _PisteAppState extends State<PisteApp> {
  late final ApplicationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ApplicationsController(widget.initialApplications);
  }

  @override
  void dispose() {
    _controller.dispose();
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
      home: HomeShell(controller: _controller),
    );
  }
}
