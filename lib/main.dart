import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tablet_login_screen.dart';
import 'member_app.dart';
import 'kiosk_screen.dart';
import 'admin_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app(); // Zaten başlatılmışsa olanı kullan
  }

  // 🌟 KURAL 3: İnternet kesilse bile sistemin durmaması için Çevrimdışı Kalıcılık aktif!
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TurniGymApp(),
    ),
  );
}

// YENİ GEÇİCİ TEST EKRANI WIDGET'I (BİRLEŞTİRİLMİŞ)
class TurniGymMergedScreen extends StatefulWidget {
  const TurniGymMergedScreen({super.key});

  @override
  State<TurniGymMergedScreen> createState() => _TurniGymMergedScreenState();
}

class _TurniGymMergedScreenState extends State<TurniGymMergedScreen> {
  String dynamicToken = "TRN-WAIT";
  int secondsLeft = 60;
  Timer? timer;
  bool _isProcessing = false; // İşlem yapılıyor mu kontrolü

  @override
  void initState() {
    super.initState();
    generateNewToken();
    startTimer();
  }

  void generateNewToken() {
    setState(() {
      dynamicToken =
          "TRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
      secondsLeft = 60;
    });
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
      // --- TAMİR: TÜM EKRANI KAYDIRILABİLİR YAPARAK OVERFLOW'U ÇÖZDÜK ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // --- KREDİSİ: EN BAŞTA DEVAZA VE MERKEZİ TURNIGYM LOGOSU ---
            Center(
              child: Image.asset(
                'assets/images/turnigym.png', // Doğru yerel logo
                width: 350,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionDivider("GİRİŞ KODUNUZ"),

            // --- SEFA AVCILAR PROFİL BÖLÜMÜ ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://placehold.co/100x100/1E293B/FFFFFF?text=SA',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sefa Avcılar",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    "Üye, ID: 10243",
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- QR KOD VE GERİ SAYIM ---
            _buildQrCard(dynamicToken, secondsLeft),
            const SizedBox(height: 40),

            _buildSectionDivider("SALON KİOSK TERMİNALİ"),

            // --- KİOSK BÖLÜMÜ (KAMERA VE TALİMATLAR) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Kamera Görüntüsü Çerçevesi (Yeşil)
                  _buildKioskScannerView(),
                  const SizedBox(height: 40),
                  // Talimatlar ve Durum
                  _buildInstructionHub(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ORTAK BİLEŞENLER ---

  Widget _buildSectionDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  Widget _buildQrCard(String data, int timeLeft) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 25),
        ],
        border: Border.all(
          color: const Color(0xFF00B894),
          width: 3,
        ), // Daha belirgin yeşil çerçeve
      ),
      child: Column(
        children: [
          // QR Kod
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 260.0,
            gapless:
                true, // Piksellerin birleşmesini sağlar, okumayı kolaylaştırır
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black, // Tam siyah kontrast
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black, // Tam siyah kontrast
            ),
          ),
          const SizedBox(height: 30),
          // Progress Bar (Yeşil/Turuncu)
          SizedBox(
            width: 260,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: timeLeft / 60, // 60 saniyeye göre uyarlandı
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: timeLeft < 10
                      ? Colors.orange
                      : const Color(0xFF00B894),
                  minHeight: 6,
                ),
                const SizedBox(height: 10),
                Text(
                  "Kod yenileniyor: $timeLeft sn",
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKioskScannerView() {
    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        // Kurumsal Yeşil Çerçeve (Kamera Çerçevesi)
        border: Border.all(color: const Color(0xFF00B894), width: 5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 25),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      // mobile_scanner kamerasını Mac kamerasından açacak
      child: MobileScanner(
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
                    await FirebaseFirestore.instance
                        .collection('members')
                        .doc(memberDoc.id)
                        .update({
                          'credit': currentCredit - 1,
                          'isInside': !isInside,
                        });

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

  Widget _buildInstructionHub() {
    return Column(
      children: [
        const Icon(Icons.qr_code_scanner, size: 70, color: Color(0xFFF59E0B)),
        const SizedBox(height: 25),
        const Text(
          "KODUNUZU TARATIN",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Lütfen telefonunuzdaki anlık kodu kameraya yaklaştırın.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 40),
        // Durum Butonu (Turuncu)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0xFFF59E0B), width: 2),
          ),
          child: const Text(
            "DURUM: KOD BEKLENİYOR...",
            style: TextStyle(
              color: Color(0xFFF59E0B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
              setState(() {
                _isProcessing = false;
              });
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

class TurniGymApp extends StatelessWidget {
  const TurniGymApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor:
            Colors.white, // Tüm o siyah/koyu yerleri beyaz yapar
        cardColor:
            Colors.grey[100], // Kartları hafif gri yaparak derinlik katar
        primaryColor: Colors.black, // Yazıları siyah yapar
        textTheme: GoogleFonts.quicksandTextTheme(ThemeData.light().textTheme)
            .copyWith(
              headlineLarge: GoogleFonts.quicksand(fontWeight: FontWeight.w800),
            ),
        primaryTextTheme: GoogleFonts.quicksandTextTheme(
          ThemeData.light().primaryTextTheme,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCard,
        primaryColor: AppColors.neonCyan,
        textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme)
            .copyWith(
              headlineLarge: GoogleFonts.quicksand(fontWeight: FontWeight.w800),
            ),
        primaryTextTheme: GoogleFonts.quicksandTextTheme(
          ThemeData.dark().primaryTextTheme,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return const MainLayout();
          return const LoginView();
        },
      ),
    );
  }
}

// 1. OTURUM KONTROLÜ
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.hasData ? const MainLayout() : const LoginView();
      },
    );
  }
}

// 2. MODERN GİRİŞ EKRANI
// 2. MODERN GİRİŞ EKRANI
class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _salonName = TextEditingController(); // Yeni salon adı controller'ı
  final _salonCapacity = TextEditingController(); // Kapasite controller'ı
  bool _rememberMe = false;
  bool _isLogin = true;
  bool _isLoading = false; // Yüklenme durumu

  String? _selectedCity;
  final List<String> _cities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kilis',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Şanlıurfa',
    'Siirt',
    'Sinop',
    'Şırnak',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak',
  ];

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _salonName.dispose();
    _salonCapacity.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email.text = prefs.getString('saved_email') ?? '';
      _rememberMe = prefs.getBool('remember') ?? false;
    });
  }

  Future<void> _handleAuth() async {
    if (_email.text.trim().isEmpty || _pass.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }
    if (!_isLogin && _salonName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen salon adını girin.")),
      );
      return;
    }
    if (!_isLogin && _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bulunduğunuz şehri seçin.")),
      );
      return;
    }
    if (!_isLogin && _salonCapacity.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen salon kapasitesini girin.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    OverlayEntry? welcomeOverlay;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _email.text.trim());
        await prefs.setBool('remember', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.setBool('remember', false);
      }

      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
      } else {
        // YENİ KAYIT: Geçişi gizlemek ve hoş geldin animasyonu göstermek için Overlay ekliyoruz
        welcomeOverlay = OverlayEntry(
          builder: (context) => Material(
            color: AppColors.primaryColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: const Icon(
                          Icons.check_circle,
                          size: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Hoş Geldin, ${_salonName.text.trim()}!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Yönetim paneliniz hazırlanıyor...",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        );
        Overlay.of(context).insert(welcomeOverlay);

        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );

        // YENİ KAYIT: Firestore'da bu hesaba ait boş bir salon profili oluştur
        await FirebaseFirestore.instance
            .collection('salonlar')
            .doc(cred.user!.uid)
            .set({
              'salonAdi': _salonName.text.trim(),
              'email': _email.text.trim(),
              'aktifUyeSayisi': 0,
              'aylikGelir': 0,
              'city': _selectedCity,
              'kapasite': int.tryParse(_salonCapacity.text.trim()) ?? 100,
              'createdAt': FieldValue.serverTimestamp(),
            });

        // Admin panelindeki "Sistem Ayarları" ve "Akıllı Analiz" için kapasiteyi kaydet
        await FirebaseFirestore.instance
            .collection('salonlar')
            .doc(cred.user!.uid)
            .collection('sistem_ayarları')
            .doc('general')
            .set({
              'salon_capacity': int.tryParse(_salonCapacity.text.trim()) ?? 100,
            });

        // Animasyonu izletebilmek ve hissi artırmak için 2.5 saniye bekle
        await Future.delayed(const Duration(milliseconds: 2500));
      }
    } on FirebaseAuthException catch (e) {
      if (welcomeOverlay != null) {
        welcomeOverlay.remove();
        welcomeOverlay = null;
      }
      String msg = "Bir hata oluştu.";
      if (e.code == 'email-already-in-use')
        msg = "Bu e-posta zaten kullanımda.";
      else if (e.code == 'weak-password')
        msg = "Şifreniz çok zayıf (En az 6 karakter).";
      else if (e.code == 'user-not-found' || e.code == 'invalid-credential')
        msg = "Kullanıcı bulunamadı veya şifre yanlış.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (welcomeOverlay != null) {
        welcomeOverlay.remove();
        welcomeOverlay = null;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (welcomeOverlay != null) {
        welcomeOverlay.remove();
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen önce e-posta adresinizi girin."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 40,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Sıfırlama Bağlantısı Gönderildi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$email adresine şifrenizi sıfırlayabilmeniz için bir bağlantı gönderdik. Lütfen e-posta kutunuzu (ve Spam klasörünü) kontrol edin.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "TAMAM",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        // 🌟 Taşma (RenderFlex overflow) hatasını önlemek için eklendi
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/turnigym.png', width: 240),
                const SizedBox(height: 30),
                if (!_isLogin) ...[
                  TextField(
                    controller: _salonName,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Salon Adı',
                      prefixIcon: Icon(
                        Icons.fitness_center,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    items: _cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(
                          city,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCity = val);
                    },
                    dropdownColor: AppColors.white,
                    decoration: const InputDecoration(
                      labelText: 'Şehir Seçin',
                      prefixIcon: Icon(
                        Icons.location_city,
                        color: AppColors.primaryColor,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _salonCapacity,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Hedef Üye Kapasitesi',
                      prefixIcon: Icon(
                        Icons.groups_outlined,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                TextField(
                  controller: _email,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(
                      Icons.email,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v!),
                      activeColor: AppColors.primaryColor,
                    ),
                    const Text(
                      'Beni Hatırla',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                // Eski metin ve butonun olduğu kısmı bununla değiştir:

                // Kayıt / Giriş geçişi yerine tek buton:
                // 1. Ana aksiyon butonu (Giriş Yap / Kayıt Ol - Buton olarak)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    onPressed: _isLoading ? null : _handleAuth,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? 'GİRİŞ YAP' : 'KAYIT OL',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Mod değiştirme (Sadece yazı tipi link gibi)
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'Hesabınız yok mu? Kayıt Ol'
                        : 'Zaten hesabınız var mı? Giriş Yap',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),

                // 3. Şifremi Unuttum
                TextButton(
                  onPressed: _resetPassword,
                  child: const Text(
                    "Şifremi Unuttum",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
