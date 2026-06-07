import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class KioskTerminalScreen extends StatefulWidget {
  const KioskTerminalScreen({super.key});

  @override
  State<KioskTerminalScreen> createState() => _KioskTerminalScreenState();
}

class _KioskTerminalScreenState extends State<KioskTerminalScreen> {
  // Kamera kontrolcüsü
  final MobileScannerController scannerController = MobileScannerController();
  bool _isProcessing = false; // İşlem yapılıyor mu kontrolü

  @override
  Widget build(BuildContext context) {
    // OrientationBuilder: Ekranın dikey mi yatay mı olduğunu anlık dinler
    return Scaffold(
      backgroundColor: Colors.white, // TurniGym Saf Beyaz
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  // --- 1. DİKEY (PORTRAIT) TASARIM ---
  Widget _buildPortraitLayout() {
    return Column(
      children: [
        const SizedBox(height: 60),
        _buildLargeLogo(), // Üstte Kocaman Logo
        const Spacer(),
        _buildScannerView(height: 400, width: 350), // Merkezi Kamera
        const Spacer(),
        _buildInstructionBox(), // Alt Talimatlar
        const SizedBox(height: 40),
      ],
    );
  }

  // --- 2. YATAY (LANDSCAPE) TASARIM ---
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Sol Taraf: Kamera
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSmallLogo(), // Sol üstte kompakt logo
                const SizedBox(height: 20),
                _buildScannerView(height: 350, width: 500),
              ],
            ),
          ),
        ),
        // Sağ Taraf: Bilgi Paneli
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC), // Hafif gri aydınlık ton
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: const EdgeInsets.all(40),
            child: _buildInstructionBox(),
          ),
        ),
      ],
    );
  }

  // --- ORTAK BİLEŞENLER ---

  Widget _buildLargeLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/turnigym.png', // Projenin kendi yerel logosu bağlandı
          width: 300,
        ),
        const Text(
          "TERMİNAL",
          style: TextStyle(
            color: Color(0xFF64748B),
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallLogo() {
    return Image.asset('assets/images/turnigym.png', width: 180);
  }

  Widget _buildScannerView({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF00B894),
          width: 4,
        ), // Kurumsal Yeşil Çerçeve
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      clipBehavior:
          Clip.antiAlias, // overflow: hidden yerine güncel yapı kullanıldı
      child: MobileScanner(
        controller: scannerController,
        onDetect: (capture) async {
          if (_isProcessing) return; // Zaten okuyorsa tekrar tetikleme

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              setState(() => _isProcessing = true); // İşlem başladı, kilitle

              debugPrint('Okunan Kod: $code');

              try {
                final String salonId =
                    FirebaseAuth.instance.currentUser?.uid ?? 'demo_salon';

                // TEST İÇİN: Sistemdeki son eklenen üyeyi bulup kredisini düşelim
                // (Gerçek senaryoda code değişkeni ile Firebase'den üye aranır)
                final memberSnapshot = await FirebaseFirestore.instance
                    .collection('members')
                    .where('tenantId', isEqualTo: salonId)
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .get();

                if (memberSnapshot.docs.isNotEmpty) {
                  final memberDoc = memberSnapshot.docs.first;
                  final data = memberDoc.data() as Map<String, dynamic>;
                  final int currentCredit = data['credit'] ?? 0;
                  final String memberName = data['name'] ?? 'Bilinmeyen Üye';
                  final bool isInside = data['isInside'] ?? false;

                  if (currentCredit > 0) {
                    // Krediyi 1 düşür ve içeride durumunu tersine çevir
                    await FirebaseFirestore.instance
                        .collection('members')
                        .doc(memberDoc.id)
                        .update({
                          'credit': currentCredit - 1,
                          'isInside': !isInside,
                        });

                    // Panele anlık düşmesi için Geçiş Logu ekle
                    final now = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection('salonlar')
                        .doc(salonId)
                        .collection('pass_logs')
                        .add({
                          'memberName': memberName,
                          'memberId': memberDoc.id,
                          'date': DateFormat('dd.MM.yyyy').format(now),
                          'time': DateFormat('HH:mm:ss').format(now),
                          'status': 'Geçiş İzni',
                          'type': !isInside ? 'GİRİŞ' : 'ÇIKIŞ',
                          'timestamp': now.millisecondsSinceEpoch,
                          'scannedCode': code,
                        });

                    if (mounted)
                      _showSuccessDialog(
                        "$memberName\nKalan Kredi: ${currentCredit - 1}",
                      );
                  } else {
                    if (mounted)
                      _showErrorDialog("$memberName\nYetersiz Kredi!");
                  }
                } else {
                  if (mounted) _showErrorDialog("Sistemde üye bulunamadı.");
                }
              } catch (e) {
                if (mounted) _showErrorDialog("Sistem Hatası: $e");
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildInstructionBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.qr_code_scanner,
          size: 64,
          color: Color(0xFFF59E0B),
        ), // Turuncu İkon
        const SizedBox(height: 24),
        const Text(
          "GİRİŞ İÇİN TARATIN",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Lütfen telefonunuzdaki anlık kodu kameraya yaklaştırın.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 40),
        // Durum Butonu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: const Text(
            "KOD BEKLENİYOR...",
            style: TextStyle(
              color: Color(0xFFF59E0B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- BAŞARISIZ MESAJI ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "GİRİŞ REDDEDİLDİ ❌",
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
            },
            child: const Text(
              "TAMAM",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // --- BAŞARILI MESAJI ---
  void _showSuccessDialog(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "GİRİŞ ONAYLANDI ✅",
          style: TextStyle(color: Color(0xFF00B894)),
        ),
        content: Text("Doğrulanan Üye: $text\nİyi antrenmanlar!"),
        actions: [
          TextButton(
            onPressed: () {
              // 1. Önce pencereyi kapat
              Navigator.pop(context);

              // 2. İşlem bitti, kilidi aç ve ekranı güncelle
              setState(() {
                _isProcessing = false;
              });
            },
            child: const Text("TAMAM"),
          ),
        ],
      ),
    );
  }
}
