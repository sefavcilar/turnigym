import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MemberQrScreen extends StatefulWidget {
  const MemberQrScreen({super.key});

  @override
  State<MemberQrScreen> createState() => _MemberQrScreenState();
}

class _MemberQrScreenState extends State<MemberQrScreen> {
  String dynamicToken = "";
  int secondsLeft = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    generateNewToken();
    startTimer();
  }

  // 10 saniyede bir yeni kod üreten fonksiyon
  void generateNewToken() {
    setState(() {
      // Burada gerçek bir TOTP algoritması veya Firebase ID kullanılacak
      // Şimdilik test için rastgele bir hash üretiyoruz
      dynamicToken =
          "TRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
      secondsLeft = 60;
    });
    // TODO: Üretilen kodu Firebase'e "aktif geçiş anahtarı" olarak kaydet
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 1) {
        generateNewToken();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Giriş Kodum",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (Yerel projeden çekildi)
            Image.asset('assets/images/turnigym.png', width: 150),
            const SizedBox(height: 40),

            // QR Kod Çerçevesi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: QrImageView(
                data: dynamicToken,
                version: QrVersions.auto,
                size: 250.0,
                gapless: true,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Progress Bar (Geri Sayım)
            SizedBox(
              width: 250,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: secondsLeft / 60,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: secondsLeft < 10
                        ? Colors.orange
                        : const Color(0xFF00B894),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Kod yenileniyor: $secondsLeft sn",
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Kodun metin hali (Alternatif)
            Text(
              dynamicToken,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
