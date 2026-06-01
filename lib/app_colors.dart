import 'package:flutter/material.dart';

class AppColors {
  // Ortak Neon & Marka Renkleri
  static const Color neonGreen = Color(0xFF00FF66);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonPink = Color(0xFFFF00F0);

  // Karanlık Tema (Dark Mode) Renkleri
  static const Color darkBackground = Color(0xFF030E11);
  static const Color darkSidebar = Color(0xFF02090B);
  static const Color darkCard = Color(0xFF04171A);
  static const Color darkBorder = Color(0xFF13363B);
  static const Color darkText = Colors.white;
  static const Color darkTextMuted = Color(0xFF627E82);

  // Aydınlık Tema (Light Mode) Renkleri (TurniGym'e Özel Ayarlandı)
  static const Color lightBackground = Color(0xFFF4F7F6);
  static const Color lightSidebar = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF1A202C);
  static const Color lightTextMuted = Color(0xFF718096);

  // Temaya Göre Dinamik Renk Döndüren Yardımcı Metotlar
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : lightBackground;
  static Color sidebar(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkSidebar
      : lightSidebar;
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBorder
      : lightBorder;
  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : lightText;
  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextMuted
      : lightTextMuted;
}
