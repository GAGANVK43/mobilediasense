import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Health Teal & Emerald)
  static const Color primary = Color(0xFF0D9488);        // Teal 600
  static const Color primaryDark = Color(0xFF0F766E);    // Teal 700
  static const Color primaryLight = Color(0xFF2DD4BF);   // Teal 400
  static const Color primarySurface = Color(0xFFF0FDFA); // Teal 50
  
  // Secondary / Accent Palette (Indigo)
  static const Color secondary = Color(0xFF4F46E5);      // Indigo 600
  static const Color secondaryLight = Color(0xFF818CF8); // Indigo 400
  
  // Health & Risk Indicators
  static const Color riskLow = Color(0xFF10B981);        // Emerald 500
  static const Color riskLowBg = Color(0xFFECFDF5);
  static const Color riskModerate = Color(0xFFF59E0B);   // Amber 500
  static const Color riskModerateBg = Color(0xFFFFFBEB);
  static const Color riskHigh = Color(0xFFEF4444);       // Red 500
  static const Color riskHighBg = Color(0xFFFEF2F2);
  
  // Neutral / Backgrounds - Light
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);
  
  // Neutral / Backgrounds - Dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);
  
  // States
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
