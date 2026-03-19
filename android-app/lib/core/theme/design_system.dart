import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystem {
  // --- Colors ---
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color secondary = Color(0xFFEC4899); // Pink 500
  static const Color secondaryDark = Color(0xFFDB2777); // Pink 600
  
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const String currency = '₹';

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Glassmorphism ---
  static BoxDecoration glassDecoration({
    required BuildContext context,
    double opacity = 0.1,
    double blur = 10,
    double borderRadius = 20,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? Colors.black : Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        width: 1.5,
      ),
    );
  }

  // --- Helpers ---
  static bool get isWeb => kIsWeb;

  // --- Shadows ---
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: primary.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // --- Input Decoration ---
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    );
  }

  // --- Text Styles (Built on Outfit) ---
  static TextStyle heading1({Color? color}) => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color,
  );

  static TextStyle heading2({Color? color}) => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle heading3({Color? color}) => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: color,
  );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color?.withOpacity(0.7) ?? Colors.grey,
  );

  static String getInitial(String? name, [String fallback = 'U']) {
    if (name == null || name.trim().isEmpty) return fallback;
    return name.trim()[0].toUpperCase();
  }
}
