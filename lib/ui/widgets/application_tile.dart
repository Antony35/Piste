import 'package:flutter/material.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/format.dart';
import 'package:piste/ui/theme/app_theme.dart';
import 'package:piste/ui/widgets/status_chip.dart';

/// One application in a list.
class ApplicationTile extends StatelessWidget {
  const ApplicationTile({
    super.key,
    required this.application,
    required this.now,
    this.onTap,
  });

  final JobApplication application;

  /// Reference date for « il y a 2 j », passed in to keep tests stable.
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.piste.of(application.status);
    final company = application.company;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            company.isEmpty ? '?' : company.characters.first.toUpperCase(),
            style: TextStyle(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          application.position,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$company · ${relativeAge(application.updatedAt, now)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: StatusChip(status: application.status),
      ),
    );
  }
}
