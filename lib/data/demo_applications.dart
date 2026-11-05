import 'package:piste/models/job_application.dart';

/// Temporary sample data until the database exists. Delete at step 5.
List<JobApplication> demoApplications(DateTime now) => [
  JobApplication(
    id: 1,
    company: 'Nexora',
    position: 'Développeur Flutter',
    status: ApplicationStatus.interview,
    createdAt: now.subtract(const Duration(days: 12)),
    updatedAt: now.subtract(const Duration(days: 2)),
  ),
  JobApplication(
    id: 2,
    company: 'Asteria',
    position: 'Mobile developer',
    status: ApplicationStatus.inProgress,
    createdAt: now.subtract(const Duration(days: 9)),
    updatedAt: now.subtract(const Duration(days: 4)),
  ),
  JobApplication(
    id: 3,
    company: 'Kaleo',
    position: 'Ingénieur logiciel',
    status: ApplicationStatus.offer,
    createdAt: now.subtract(const Duration(days: 20)),
    updatedAt: now.subtract(const Duration(days: 8)),
  ),
];
