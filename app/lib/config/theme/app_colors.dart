import 'package:flutter/material.dart';

/// Centralized color palette for Doctor Booking App
/// Inspired by Practo, Halodoc, Doctolib — medical premium, trust & calm
class AppColors {
  AppColors._();

  // ──────────── Brand Colors ────────────
  static const Color primary = Color(0xFF0D9488);       // Teal 600 — Trust, Health
  static const Color primaryLight = Color(0xFF5EEAD4);  // Teal 300
  static const Color primaryDark = Color(0xFF0F766E);   // Teal 700
  static const Color primarySurface = Color(0xFFE6FAF7); // Teal 50

  static const Color secondary = Color(0xFF6366F1);     // Indigo 500 — Modern, Tech
  static const Color secondaryLight = Color(0xFFA5B4FC); // Indigo 300
  static const Color secondaryDark = Color(0xFF4338CA);  // Indigo 700
  static const Color secondarySurface = Color(0xFFEEF2FF); // Indigo 50

  static const Color accent = Color(0xFFF59E0B);        // Amber 500 — Energy, Attention
  static const Color accentLight = Color(0xFFFCD34D);   // Amber 300
  static const Color accentSurface = Color(0xFFFFFBEB); // Amber 50

  // ──────────── Semantic Colors ────────────
  static const Color success = Color(0xFF10B981);       // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5);  // Emerald 100
  static const Color warning = Color(0xFFF59E0B);       // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7);  // Amber 100
  static const Color error = Color(0xFFEF4444);         // Red 500
  static const Color errorLight = Color(0xFFFEE2E2);    // Red 100
  static const Color info = Color(0xFF3B82F6);          // Blue 500
  static const Color infoLight = Color(0xFFDBEAFE);     // Blue 100

  // ──────────── Neutral Colors (Light Mode) ────────────
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);  // Slate 100
  static const Color border = Color(0xFFE2E8F0);          // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9);     // Slate 100
  static const Color divider = Color(0xFFE2E8F0);

  // ──────────── Text Colors (Light Mode) ────────────
  static const Color textPrimary = Color(0xFF0F172A);     // Slate 900
  static const Color textSecondary = Color(0xFF475569);   // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8);    // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ──────────── Dark Mode Colors ────────────
  static const Color darkBackground = Color(0xFF0F172A);   // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);      // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155);        // Slate 700
  static const Color darkTextPrimary = Color(0xFFF1F5F9);  // Slate 100
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextTertiary = Color(0xFF64748B);  // Slate 500

  // ──────────── Gradients ────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF0891B2)], // Teal → Cyan
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo → Violet
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)], // Amber → Orange
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF6366F1)], // Teal → Indigo
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF4338CA)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
  );

  // ──────────── Appointment Status Colors ────────────
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusCompleted = Color(0xFF3B82F6);
  static const Color statusNoShow = Color(0xFF6B7280);

  static Color statusColor(String status) => switch (status) {
    'pending' => statusPending,
    'confirmed' => statusConfirmed,
    'cancelled' => statusCancelled,
    'completed' => statusCompleted,
    'no_show' => statusNoShow,
    _ => textTertiary,
  };

  static Color statusBgColor(String status) => switch (status) {
    'pending' => warningLight,
    'confirmed' => successLight,
    'cancelled' => errorLight,
    'completed' => infoLight,
    'no_show' => const Color(0xFFF3F4F6),
    _ => surfaceVariant,
  };

  // ──────────── Notification Type Colors ────────────
  static Color notificationColor(String type) => switch (type) {
    'appointment' => info,
    'chat' => success,
    'reminder' => accent,
    'payment' => secondary,
    'review' => accent,
    'cancellation' => error,
    _ => textTertiary,
  };

  // ──────────── Speciality Colors (for category chips) ────────────
  static const List<Color> categoryColors = [
    Color(0xFF0D9488), // Teal
    Color(0xFF6366F1), // Indigo
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Violet
    Color(0xFFF97316), // Orange
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal 500
    Color(0xFF3B82F6), // Blue
    Color(0xFFA855F7), // Purple
  ];

  static Color categoryColor(int index) => categoryColors[index % categoryColors.length];
}
