import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════
//  APP THEME — single source of truth for the dark blackish-green theme
// ═══════════════════════════════════════════════════════════════════════

class AppColors {
  // Primary teal accent
  static const teal = Color(0xFF2EDBB8);
  static const tealDark = Color(0xFF1BC5A0);
  static const tealGlow = Color(0xFF2EDBB8);

  // Background shades
  static const bgBase = Color(0xFF050807);
  static const bgGrad1 = Color(0xFF0A0F0B);
  static const bgGrad2 = Color(0xFF020402);
  static const bgGrad3 = Color(0xFF080C08);

  // Card / glass surface (Black Glassy)
  static const cardGrad1 = Color(0xFF0D120E);
  static const cardGrad2 = Color(0xFF050705);
  static const cardGrad3 = Color(0xFF090C09);
  static const cardBorderTeal = Color(0xFF2EDBB8);

  // Field & text
  static const fieldLine = Color(0xFF2B3D2D);
  static const labelGrey = Color(0xFF7D9080);
  static const subtitleGrey = Color(0xFF8A9E8C);
  static const textPrimary = Colors.white;
  static const buttonText = Color(0xFF0A1A0C);

  // Status colours (adapted for dark theme)
  static const statusPending = Color(0xFFFFB347);
  static const statusInProgress = Color(0xFF64B5F6);
  static const statusSubmitted = Color(0xFFCE93D8);
  static const statusApproved = Color(0xFF2EDBB8);
  static const statusRejected = Color(0xFFEF5350);
}

// ── Flutter ThemeData ────────────────────────────────────────────────

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.teal,
        secondary: AppColors.tealDark,
        surface: Color(0xFF111A12),
        onSurface: Colors.white,
        error: AppColors.statusRejected,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF0F2214).withOpacity(0.72),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.cardBorderTeal.withOpacity(0.18),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: AppColors.teal,
      ),
      dividerColor: AppColors.fieldLine,
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        labelStyle: const TextStyle(
          color: AppColors.labelGrey,
          fontSize: 14,
        ),
        hintStyle: TextStyle(color: AppColors.labelGrey.withOpacity(0.6)),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.fieldLine),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.fieldLine),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.teal, width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.statusRejected),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.statusRejected, width: 1.5),
        ),
        contentPadding: const EdgeInsets.only(bottom: 10, top: 6),
        errorStyle: const TextStyle(color: AppColors.statusRejected, fontSize: 11),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 36),
        headlineMedium: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 26),
        headlineSmall: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        titleLarge: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.subtitleGrey, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.labelGrey, fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.tealDark,
        foregroundColor: AppColors.buttonText,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A2B1C),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.teal.withOpacity(0.3)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF0A0D0B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.teal.withOpacity(0.15)),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.subtitleGrey,
          fontSize: 14,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.teal),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealDark,
          foregroundColor: AppColors.buttonText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      // keep light theme same as dark for now
      extensions: const [],
    );
  }

  // lightTheme just mirrors dark for this design
  static ThemeData get lightTheme => darkTheme;
}

// ═══════════════════════════════════════════════════════════════════════
//  SHARED UI COMPONENTS
// ═══════════════════════════════════════════════════════════════════════

/// Full-screen dark blackish-green gradient background with radial shine.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Pure black glassy base ─────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgGrad1,
                AppColors.bgGrad2,
                AppColors.bgGrad3,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Subtle top radial glow
        Positioned(
          top: -100,
          left: -80,
          right: -80,
          height: 380,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  const Color(0xFF0F2010).withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Glassmorphism card with dark-green gradient fill + teal rim + blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(22);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardGrad1.withOpacity(0.72),
                AppColors.cardGrad2.withOpacity(0.82),
                AppColors.cardGrad3.withOpacity(0.75),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: br,
            border: Border.all(
              color: AppColors.cardBorderTeal.withOpacity(0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 36,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppColors.teal.withOpacity(0.06),
                blurRadius: 28,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Themed AppBar with consistent style.
PreferredSizeWidget themedAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
  Widget? leading,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: leading,
    automaticallyImplyLeading: showBack,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    actions: actions,
  );
}

/// Teal gradient primary button.
class TealButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;

  const TealButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [
                    AppColors.tealDark.withOpacity(0.45),
                    AppColors.teal.withOpacity(0.45),
                  ]
                : [AppColors.tealDark, AppColors.teal],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.teal.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.white.withOpacity(0.08),
            onTap: isLoading ? null : onTap,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(AppColors.buttonText),
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.buttonText,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A themed list card (replaces plain Card + ListTile pattern).
class ThemedListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isThreeLine;

  const ThemedListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        isThreeLine: isThreeLine,
      ),
    );
  }
}

/// Status colour helper (reusable across task screens).
Color taskStatusColor(dynamic status) {
  final s = status.toString();
  if (s.contains('pending')) return AppColors.statusPending;
  if (s.contains('inProgress') || s.contains('Progress')) {
    return AppColors.statusInProgress;
  }
  if (s.contains('submitted')) return AppColors.statusSubmitted;
  if (s.contains('approved')) return AppColors.statusApproved;
  if (s.contains('rejected')) return AppColors.statusRejected;
  return AppColors.labelGrey;
}

/// Teal/green status chip badge.
Widget statusChip(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.45)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );
}
