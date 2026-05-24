import 'package:flutter/material.dart';

enum BeeThemeId {
  command,
  graphite,
  daylight,
  amberOps,
  arctic,
  terminal,
  ember,
}

class BeeTheme {
  const BeeTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.isDark,
  });

  final BeeThemeId id;
  final String name;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color text;
  final Color muted;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;
  final bool isDark;

  ThemeData materialTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: accent,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      fontFamily: 'Menlo',
      textTheme: TextTheme(
        displaySmall: TextStyle(color: text, fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(color: text, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(color: text, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: text, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: text),
        bodyMedium: TextStyle(color: muted),
        labelLarge: TextStyle(color: text, fontWeight: FontWeight.w700),
      ),
      dividerColor: border,
      extensions: [BeeThemeToken(this)],
    );
  }
}

class BeeThemeToken extends ThemeExtension<BeeThemeToken> {
  const BeeThemeToken(this.theme);

  final BeeTheme theme;

  @override
  ThemeExtension<BeeThemeToken> copyWith({BeeTheme? theme}) {
    return BeeThemeToken(theme ?? this.theme);
  }

  @override
  ThemeExtension<BeeThemeToken> lerp(
    ThemeExtension<BeeThemeToken>? other,
    double t,
  ) {
    return this;
  }
}

class BeeThemes {
  static const command = BeeTheme(
    id: BeeThemeId.command,
    name: 'Command',
    background: Color(0xFF090A0C),
    surface: Color(0xFF17181B),
    surfaceAlt: Color(0xFF101113),
    border: Color(0xFF303238),
    text: Color(0xFFF5F5F5),
    muted: Color(0xFF8D8E94),
    accent: Color(0xFFFFB94E),
    success: Color(0xFF58E37A),
    warning: Color(0xFFFFD166),
    danger: Color(0xFFFF5C66),
    isDark: true,
  );

  static const graphite = BeeTheme(
    id: BeeThemeId.graphite,
    name: 'Graphite',
    background: Color(0xFF111827),
    surface: Color(0xFF1F2937),
    surfaceAlt: Color(0xFF172033),
    border: Color(0xFF374151),
    text: Color(0xFFF9FAFB),
    muted: Color(0xFF9CA3AF),
    accent: Color(0xFF38BDF8),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFFB7185),
    isDark: true,
  );

  static const daylight = BeeTheme(
    id: BeeThemeId.daylight,
    name: 'Daylight',
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEFF3F8),
    border: Color(0xFFD7DEE8),
    text: Color(0xFF172033),
    muted: Color(0xFF687487),
    accent: Color(0xFFCA7A14),
    success: Color(0xFF168A45),
    warning: Color(0xFFB7791F),
    danger: Color(0xFFC2414B),
    isDark: false,
  );

  static const amberOps = BeeTheme(
    id: BeeThemeId.amberOps,
    name: 'Amber Ops',
    background: Color(0xFF15110A),
    surface: Color(0xFF211A0F),
    surfaceAlt: Color(0xFF0F0D09),
    border: Color(0xFF493722),
    text: Color(0xFFFFF8E8),
    muted: Color(0xFFB99F72),
    accent: Color(0xFFFFC247),
    success: Color(0xFF7CE083),
    warning: Color(0xFFFFA537),
    danger: Color(0xFFFF6B6B),
    isDark: true,
  );

  static const arctic = BeeTheme(
    id: BeeThemeId.arctic,
    name: 'Arctic',
    background: Color(0xFFEAF1F8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFDDE8F2),
    border: Color(0xFFB9C8D8),
    text: Color(0xFF102033),
    muted: Color(0xFF5E7188),
    accent: Color(0xFF087EA4),
    success: Color(0xFF148A66),
    warning: Color(0xFFB06A00),
    danger: Color(0xFFB42335),
    isDark: false,
  );

  static const terminal = BeeTheme(
    id: BeeThemeId.terminal,
    name: 'Terminal',
    background: Color(0xFF06100B),
    surface: Color(0xFF0D1C13),
    surfaceAlt: Color(0xFF07140D),
    border: Color(0xFF244331),
    text: Color(0xFFE9FFF0),
    muted: Color(0xFF7FA48D),
    accent: Color(0xFF52F28B),
    success: Color(0xFF52F28B),
    warning: Color(0xFFE6D45A),
    danger: Color(0xFFFF6F7D),
    isDark: true,
  );

  static const ember = BeeTheme(
    id: BeeThemeId.ember,
    name: 'Ember',
    background: Color(0xFF160E12),
    surface: Color(0xFF24171D),
    surfaceAlt: Color(0xFF100A0D),
    border: Color(0xFF4B2E37),
    text: Color(0xFFFFF1F4),
    muted: Color(0xFFC08F9E),
    accent: Color(0xFFFF7A45),
    success: Color(0xFF6EE7A1),
    warning: Color(0xFFFFC857),
    danger: Color(0xFFFF4D6D),
    isDark: true,
  );

  static const all = [
    command,
    amberOps,
    graphite,
    terminal,
    ember,
    daylight,
    arctic,
  ];

  static BeeTheme byId(BeeThemeId id) {
    return all.firstWhere((theme) => theme.id == id, orElse: () => command);
  }
}
