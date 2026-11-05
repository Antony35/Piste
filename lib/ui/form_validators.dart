/// Error message for an empty required field, or `null` when filled.
String? requiredText(String? value, String message) =>
    value == null || value.trim().isEmpty ? message : null;

String? validateCompany(String? value) =>
    requiredText(value, "Indiquez le nom de l'entreprise.");

String? validatePosition(String? value) =>
    requiredText(value, "Indiquez l'intitulé du poste.");

/// Optional field: empty is fine, otherwise it must be a full http(s)
/// address, with a site name after the scheme.
String? validateUrl(String? value) {
  final url = value?.trim() ?? '';
  if (url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return "L'adresse doit commencer par http:// ou https://";
  }
  // `Uri` accepts « https:// » alone and percent-encodes inner spaces.
  if (uri.host.isEmpty || url.contains(' ')) {
    return 'Indiquez une adresse complète, par exemple https://exemple.fr';
  }
  return null;
}
