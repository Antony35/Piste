/// Error message for an empty required field, or `null` when filled.
String? requiredText(String? value, String message) =>
    value == null || value.trim().isEmpty ? message : null;

String? validateCompany(String? value) =>
    requiredText(value, "Indiquez le nom de l'entreprise.");

String? validatePosition(String? value) =>
    requiredText(value, "Indiquez l'intitulé du poste.");

/// Optional field: empty is fine, otherwise it must be an http(s) address.
String? validateUrl(String? value) {
  final url = value?.trim() ?? '';
  if (url.isEmpty) return null;
  final valid = url.startsWith('http://') || url.startsWith('https://');
  return valid ? null : "L'adresse doit commencer par http:// ou https://";
}
