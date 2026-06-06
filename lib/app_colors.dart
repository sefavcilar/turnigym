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

  // =========================================
  // AYDINLIK KURUMSAL PALET (Yeni Eklenenler)
  // =========================================
  static const Color scaffoldBg = Color(
    0xFFF8FAFC,
  ); // Sayfa arka planı (hafif gri-beyaz)
  static const Color white = Color(
    0xFFFFFFFF,
  ); // Saf beyaz (Kartlar ve Login için)
  static const Color textPrimary = Color(
    0xFF1E293B,
  ); // Koyu Lacivert-Siyah (Başlıklar)
  static const Color textSecondary = Color(0xFF64748B); // Gri (Alt başlıklar)
  static const Color primaryColor = Color(0xFF00B894); // TurniGym Yeşili (Mint)
  static const Color accent = Color(0xFFF59E0B); // Turuncu (Uyarı/Vurgu)
  static const Color borderColor = Color(0xFFE2E8F0);
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
  ];

  // Aydınlık Tema (Light Mode) Renkleri (TurniGym'e Özel Ayarlandı)
  static const Color lightBackground = scaffoldBg; // Çok hafif gri-beyaz
  static const Color lightSidebar = Colors.white;
  static const Color lightCard = white; // Saf beyaz kutular
  static const Color lightBorder = borderColor;
  static const Color lightText = textPrimary; // Koyu gri yazı
  static const Color lightTextMuted = textSecondary;
  static const Color lightPrimary =
      primaryColor; // Enerjik yeşil (Vurgular için)

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
  static Color primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? neonCyan : lightPrimary;
}
