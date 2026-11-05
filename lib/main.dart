import 'package:flutter/material.dart';
import 'package:piste/data/demo_applications.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/home_shell.dart';
import 'package:piste/ui/theme/app_theme.dart';

void main() => runApp(PisteApp(applications: demoApplications(DateTime.now())));

class PisteApp extends StatelessWidget {
  const PisteApp({super.key, required this.applications});

  final List<JobApplication> applications;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: HomeShell(applications: applications),
    );
  }
}
