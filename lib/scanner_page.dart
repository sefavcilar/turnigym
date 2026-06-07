import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isFlashGreen = false;
  bool _isProcessing = false;
  String _lastScannedCode = "";
  DateTime? _lastScanTime;

  // Geçerli salon kimliğini (Tenant ID) alıyoruz
  String get salonId => FirebaseAuth.instance.currentUser?.uid ?? 'demo_salon';

  // 🌟 KURAL 2: Sürekli Dinleme ve İşlem Tetikleme
  void _handleScan(BarcodeCapture capture) async {
    if (_isProcessing) return; // Aynı anda birden fazla QR okutmayı engelle

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String code = barcodes.first.rawValue ?? "";
    if (code.isEmpty) return;

    // Aynı kodu peş peşe defalarca okumayı engelle (3 Saniye Cooldown)
    if (code == _lastScannedCode &&
        _lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!).inSeconds < 3) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
      _lastScanTime = DateTime.now();
    });

    // 1. GÖRSEL TEPKİ: Ekranı anlık olarak yeşil parlat! (İşlem tamam hissiyatı)
    _flashSuccess();

    // 2. VERİTABANI İŞLEMİ (Offline Persistence aktif olduğu için internet kopsa da kuyruğa alınır)
    try {
      // Şimdilik sadece geçiş logu atıyoruz (Krediden düşme vs. işlemleri burada Firebase Cloud Functions ile tetiklenebilir)
      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('salonlar')
          .doc(salonId)
          .collection('pass_logs')
          .add({
            'scannedCode': code,
            'status': 'Kayıt Alındı',
            'type': 'GİRİŞ',
            'timestamp': now.millisecondsSinceEpoch,
            'date': "${now.day}.${now.month}.${now.year}",
            'time': "${now.hour}:${now.minute}",
          });
    } catch (e) {
      debugPrint("Tarama Loglama Hatası: $e");
    } finally {
      // Bir saniye sonra yeni bir okuma için kilidi aç
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  // Ekranı yeşil parlatma fonksiyonu
  void _flashSuccess() {
    if (!mounted) return;
    setState(() => _isFlashGreen = true);

    // Yarım saniye sonra yeşil ekranı kapat
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isFlashGreen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 🌟 KURAL 1: Tam Ekran! AppBar veya Navigation bar yok.
      body: Stack(
        children: [
          // 1. Kamera Katmanı
          MobileScanner(
            onDetect: _handleScan, // Kod yakalandığında anında tetiklenir
          ),

          // 2. Şık Bir Okuma Çerçevesi Katmanı (Ortadaki kutu)
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // 3. Üst Bilgi Yazısı Katmanı
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "LÜTFEN KAREKODUNUZU OKUTUN",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [Shadow(color: Colors.black, blurRadius: 15)],
                ),
              ),
            ),
          ),

          // 4. Görsel Onay Katmanı (Başarı anında ekran yeşil olur)
          if (_isFlashGreen)
            Positioned.fill(
              child: Container(
                color: const Color(
                  0xFF00FF66,
                ).withOpacity(0.4), // TurniGym fosforlu yeşili
              ),
            ),

          // 5. Gizli Çıkış Butonu (Yöneticiler acil durumda çıkabilsin diye sağ altta)
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white24,
                size: 30,
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ),
        ],
      ),
    );
  }
}
