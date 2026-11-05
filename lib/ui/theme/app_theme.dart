import 'package:flutter/material.dart';
import 'package:piste/models/job_application.dart';

typedef StatusColors = ({Color background, Color foreground});

/// Colors specific to Piste that Material's [ColorScheme] has no slot for.
@immutable
class PisteColors extends ThemeExtension<PisteColors> {
  const PisteColors({
    required this.summaryCard,
    required this.onSummaryCard,
    required this.statuses,
  });

  final Color summaryCard;
  final Color onSummaryCard;

  /// Must contain every [ApplicationStatus]; a test checks both themes.
  final Map<ApplicationStatus, StatusColors> statuses;

  StatusColors of(ApplicationStatus status) => statuses[status]!;

  static const light = PisteColors(
    summaryCard: Color(0xFF2A4BA8),
    onSummaryCard: Color(0xFFFFFFFF),
    statuses: {
      ApplicationStatus.sent: (
        background: Color(0xFFE8ECF5),
        foreground: Color(0xFF3D4670),
      ),
      ApplicationStatus.inProgress: (
        background: Color(0xFFDCEAFB),
        foreground: Color(0xFF1F4E99),
      ),
      ApplicationStatus.interview: (
        background: Color(0xFFFBE3F0),
        foreground: Color(0xFFA0006D),
      ),
      ApplicationStatus.offer: (
        background: Color(0xFFDDF4EA),
        foreground: Color(0xFF17603F),
      ),
      ApplicationStatus.rejected: (
        background: Color(0xFFECECEF),
        foreground: Color(0xFF55586A),
      ),
    },
  );

  static const dark = PisteColors(
    summaryCard: Color(0xFF1A3F8A),
    onSummaryCard: Color(0xFFFFFFFF),
    statuses: {
      ApplicationStatus.sent: (
        background: Color(0xFF232B55),
        foreground: Color(0xFFC3CAE8),
      ),
      ApplicationStatus.inProgress: (
        background: Color(0xFF1E3A6E),
        foreground: Color(0xFFBFD6FA),
      ),
      ApplicationStatus.interview: (
        background: Color(0xFF4A1238),
        foreground: Color(0xFFF6B3D9),
      ),
      ApplicationStatus.offer: (
        background: Color(0xFF123D2C),
        foreground: Color(0xFFA8EBCB),
      ),
      ApplicationStatus.rejected: (
        background: Color(0xFF2A2D3E),
        foreground: Color(0xFFB5B8C8),
      ),
    },
  );

  @override
  PisteColors copyWith({
    Color? summaryCard,
    Color? onSummaryCard,
    Map<ApplicationStatus, StatusColors>? statuses,
  }) => PisteColors(
    summaryCard: summaryCard ?? this.summaryCard,
    onSummaryCard: onSummaryCard ?? this.onSummaryCard,
    statuses: statuses ?? this.statuses,
  );

  @override
  PisteColors lerp(PisteColors? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

/// Shortcut: `context.piste.of(status)` instead of
/// `Theme.of(context).extension<PisteColors>()!.of(status)`.
extension PisteThemeContext on BuildContext {
  PisteColors get piste => Theme.of(this).extension<PisteColors>()!;
}

/// Light and dark themes of the app.
abstract final class AppTheme {
  static final light = _build(
    brightness: Brightness.light,
    background: const Color(0xFFF5F6F8),
    surface: const Color(0xFFFFFFFF),
    ink: const Color(0xFF0D1150),
    muted: const Color(0xFF5B6390),
    border: const Color(0xFFE3E5EA),
    primary: const Color(0xFF2F6FC9),
    onPrimary: const Color(0xFFFFFFFF),
    indicator: const Color(0xFFDCEAFB),
    onIndicator: const Color(0xFF1F4E99),
    action: const Color(0xFFA0006D),
    onAction: const Color(0xFFFFFFFF),
    piste: PisteColors.light,
  );

  static final dark = _build(
    brightness: Brightness.dark,
    background: const Color(0xFF0A0F2E),
    surface: const Color(0xFF131A42),
    ink: const Color(0xFFEAF2FF),
    muted: const Color(0xFF8A94C2),
    border: const Color(0xFF1E2754),
    primary: const Color(0xFF7FB0F0),
    onPrimary: const Color(0xFF0A0F2E),
    indicator: const Color(0xFF1E3A6E),
    onIndicator: const Color(0xFFBFD6FA),
    action: const Color(0xFFE0569F),
    onAction: const Color(0xFF0A0F2E),
    piste: PisteColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color ink,
    required Color muted,
    required Color border,
    required Color primary,
    required Color onPrimary,
    required Color indicator,
    required Color onIndicator,
    required Color action,
    required Color onAction,
    required PisteColors piste,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: action,
          onSecondary: onAction,
          surface: background,
          onSurface: ink,
          onSurfaceVariant: muted,
          outlineVariant: border,
          secondaryContainer: indicator,
          onSecondaryContainer: onIndicator,
        );

    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: action,
        foregroundColor: onAction,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: indicator,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: border, space: 1),
      extensions: [piste],
    );
  }
}
