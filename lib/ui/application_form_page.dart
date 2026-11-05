import 'package:flutter/material.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/form_validators.dart';
import 'package:piste/ui/format.dart';

/// Creates an application, or edits [initial] when given.
class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({
    super.key,
    required this.controller,
    this.initial,
  });

  final ApplicationsController controller;

  /// The application being edited; `null` to create a new one.
  final JobApplication? initial;

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _company;
  late final TextEditingController _position;
  late final TextEditingController _url;
  late final TextEditingController _notes;

  late ApplicationStatus _status;
  DateTime? _appliedOn;
  DateTime? _nextFollowUp;

  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _company = TextEditingController(text: initial?.company ?? '');
    _position = TextEditingController(text: initial?.position ?? '');
    _url = TextEditingController(text: initial?.url ?? '');
    _notes = TextEditingController(text: initial?.notes ?? '');
    _status = initial?.status ?? ApplicationStatus.sent;
    _appliedOn = initial?.appliedOn;
    _nextFollowUp = initial?.nextFollowUp;
  }

  @override
  void dispose() {
    _company.dispose();
    _position.dispose();
    _url.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // `_saving` also stops a second tap that lands before the rebuild.
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final application = JobApplication(
      id: widget.initial?.id,
      company: _company.text.trim(),
      position: _position.text.trim(),
      status: _status,
      appliedOn: _appliedOn,
      nextFollowUp: _nextFollowUp,
      url: _optional(_url.text),
      notes: _optional(_notes.text),
      createdAt: widget.initial?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await widget.controller.save(application);
      if (mounted) Navigator.of(context).pop();
    } on StorageException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enregistrement impossible. Réessayez.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Trimmed text, or `null` when the field is left empty.
  static String? _optional(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la candidature' : 'Nouvelle candidature',
        ),
      ),
      body: Form(
        key: _formKey,
        // Not a ListView: it builds visible fields only, and validate() would
        // skip the off-screen ones.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _company,
                decoration: const InputDecoration(
                  labelText: 'Entreprise *',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: validateCompany,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _position,
                decoration: const InputDecoration(
                  labelText: 'Intitulé du poste *',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: validatePosition,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ApplicationStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                items: [
                  for (final status in ApplicationStatus.values)
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: (status) {
                  if (status != null) setState(() => _status = status);
                },
              ),
              const SizedBox(height: 16),
              _DateField(
                label: 'Date de candidature',
                icon: Icons.send_rounded,
                value: _appliedOn,
                onChanged: (date) => setState(() => _appliedOn = date),
              ),
              const SizedBox(height: 16),
              _DateField(
                label: 'Prochaine relance',
                icon: Icons.notifications_rounded,
                value: _nextFollowUp,
                onChanged: (date) => setState(() => _nextFollowUp = date),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _url,
                decoration: const InputDecoration(
                  labelText: "Lien vers l'offre",
                  hintText: 'https://…',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: validateUrl,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isEditing ? 'Enregistrer les modifications' : 'Enregistrer',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Read-only field that opens a date picker, with a button to clear it.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final date = value;
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: date == null
              ? const Icon(Icons.calendar_month_rounded)
              : IconButton(
                  tooltip: 'Effacer la date',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => onChanged(null),
                ),
        ),
        isEmpty: date == null,
        child: Text(date == null ? '' : shortDate(date)),
      ),
    );
  }
}
