import 'package:flutter/material.dart';

/// Color palette derived from the BUMDESMA Podo Rukun LKD mobile mockups:
/// deep green header/brand, white cards, and traffic-light status colors
/// for absensi results (hijau = tepat waktu/diterima, kuning = terlambat/lembur,
/// merah = ditolak).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF16423C); // deep green header
  static const Color primaryLight = Color(0xFF2E7D5B);
  static const Color primaryDark = Color(0xFF0D2B26);
  static const Color accent = Color(0xFF3AA679);

  static const Color background = Color(0xFFF5F7F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFF3F1);

  static const Color textPrimary = Color(0xFF102A25);
  static const Color textSecondary = Color(0xFF6B7B77);
  static const Color textMuted = Color(0xFF9AA8A4);

  static const Color success = Color(0xFF2ECC71); // Tepat Waktu / Diterima
  static const Color warning = Color(0xFFF5A623); // Terlambat / Lembur
  static const Color danger = Color(0xFFE74C3C); // Ditolak
  static const Color info = Color(0xFF3498DB);

  static const Color divider = Color(0xFFE3E8E6);
  static const Color shadow = Color(0x14102A25);

  /// Shared header gradient so Dashboard/Profile/Riwayat/Izin/Absen Dulu
  /// all read as the same app instead of Dashboard being the only screen
  /// with a "designed" header.
  static const List<Color> headerGradient = [primary, primaryLight];
}

/// 4px-based spacing scale so paddings/gaps stay consistent across screens
/// instead of every widget picking its own magic numbers.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 36;
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double round = 100;
}

/// Shared text styles so headings/captions look identical everywhere
/// rather than each screen redeclaring similar-but-slightly-different
/// TextStyle literals.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        actionTextColor: AppColors.accent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }
}
