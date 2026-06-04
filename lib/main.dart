import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tablet_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app(); // Zaten başlatılmışsa olanı kullan
  }
  runApp(const TurniGymMobile());
}

class TurniGymMobile extends StatelessWidget {
  const TurniGymMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.quicksand().fontFamily,
        scaffoldBackgroundColor:
            Colors.black, // Salon tabletleri için koyu tema
        primaryColor: const Color(0xFFFF7F00), // Logonun turuncusu
      ),
      home: const TabletLoginScreen(),
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
          return const LoginScreen();
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
  bool _rememberMe = false;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
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
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030E11),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF04171A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/turnigym.png', width: 240),
              const SizedBox(height: 30),
              TextField(
                controller: _email,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email, color: Color(0xFF00F0FF)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pass,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF00F0FF)),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v!),
                    activeColor: const Color(0xFF00F0FF),
                  ),
                  const Text(
                    'Beni Hatırla',
                    style: TextStyle(color: Colors.white70),
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
                    backgroundColor: const Color(0xFF00F0FF),
                  ),
                  onPressed: _handleAuth,
                  child: Text(
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
                  style: const TextStyle(color: Colors.white70),
                ),
              ),

              // 3. Şifremi Unuttum
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Şifremi Unuttum",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// 3. DASHBOARD (Buraya senin gönderdiğin MainLayout ve diğerlerini yapıştır!)

// 3. SENİN DASHBOARD KODUN (MainLayout)
// Buraya gönderdiğin MainLayout sınıfını yapıştıracaksın (yukarıda verdiğin tüm o detaylı Sidebar ve Tablo kodlarını buraya al).
// Ayrıca Çıkış Yap butonuna şu satırı ekle: () => FirebaseAuth.instance.signOut()
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // --- EKSİK TANIMLAMALAR ---
  bool _showInsideCard = true; // Varsayılan olarak göster
  String _listRowCount =
      '10'; // Varsayılan satır sayısı (Dropdown String beklediği için String tanımlandı)
  String _analyticsViewMode = 'GÜNLÜK';
  final TextEditingController _salonCapacityController =
      TextEditingController();
  int _salonCapacity = 50; // Varsayılan değer
  String? _currentLogoUrl; // Logoyu ekranda tutmak için
  final TextEditingController _logoUrlController =
      TextEditingController(); // URL tabanlı logo giriş kutusu

  String get salonId => FirebaseAuth.instance.currentUser!.uid;
  // ----------------------------------

  @override
  void initState() {
    super.initState();
    _listenForEntries();
    _loadGeneralSettings();
  }

  Future<void> _loadGeneralSettings() async {
    final doc = await FirebaseFirestore.instance
        .collection('salonlar')
        .doc(salonId)
        .collection('sistem_ayarları')
        .doc('general')
        .get();
    if (doc.exists && mounted) {
      setState(() {
        final String? logoUrl = doc.data()?['logo_url'];
        _currentLogoUrl = logoUrl;
        _logoUrlController.text = _currentLogoUrl ?? '';
      });
    }
  }

  void _listenForEntries() {
    FirebaseFirestore.instance
        .collection('salonlar')
        .doc(salonId)
        .collection('pass_logs')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            final data = doc.data();
            final timestamp = data['timestamp'] ?? 0;
            if (DateTime.now().millisecondsSinceEpoch - timestamp < 5000) {
              final memberName = data['memberName'] ?? 'Bilinmeyen Üye';
              final type = data['type'] == 'ÇIKIŞ' ? 'çıkış' : 'giriş';
              _showEntryNotification('$memberName $type yaptı');
            }
          }
        });
  }

  void _showEntryNotification(String statusMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          statusMessage, // "Sefa Avcılar giriş yaptı" veya "çıkış yaptı"
          style: const TextStyle(
            color: Colors.white, // Yazıyı beyaz yap
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: statusMessage.contains('giriş')
            ? Colors
                  .green
                  .shade700 // Girişse yeşil
            : Colors.red.shade700, // Çıkışsa kırmızı
        duration: const Duration(
          seconds: 2,
        ), // Döngüden kurtulmak için süreyi kısıtla
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF04171A),
        title: const Text(
          "Profilim",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(
                "https://raw.githubusercontent.com/flutter/website/main/src/images/flutter-logo-sharing.png",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Admin: Sefa Avcılar", // İleride Firestore'dan çekilebilir
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.white),
              title: const Text(
                "Şifre Değiştir",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Önce profil modalını kapat
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const ChangePasswordDialog(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Oturumu Kapat",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(context); // Önce modalı kapat
                await FirebaseAuth.instance.signOut(); // Sonra çıkış yap
              },
            ),
          ],
        ),
      ),
    );
  }

  int _selectedIndex = 0;
  bool _isProcessing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _packagePriceController = TextEditingController();
  final TextEditingController _packageIconController = TextEditingController();

  final List<String> _menuTitles = [
    'Kontrol Merkezi',
    'Üye & Kredi Yönetimi',
    'Paket & Satış',
    'Satış Raporları',
    'Geçiş Analitiği',
    'Şirket Tanımlama',
    'Donanım Kalibrasyonu',
    'Sistem Ayarları',
  ];

  final List<IconData> _menuIcons = [
    Icons.token_outlined,
    Icons.group_outlined,
    Icons.add_card_outlined,
    Icons.receipt_long_outlined,
    Icons.analytics_outlined,
    Icons.business_outlined,
    Icons.developer_board,
    Icons.tune_outlined,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _packageNameController.dispose();
    _packagePriceController.dispose();
    _packageIconController.dispose();
    _salonCapacityController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Row(
        children: [
          // ================= SOL SIDEBAR =================
          // ================= SOL SIDEBAR =================
          Container(
            width: 260,
            color: const Color(0xFF02090B),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 250, // Tam istediğin genişlik
                  child: Image.asset(
                    'assets/images/turnigym.png',
                    fit: BoxFit.contain, // Logoyu kutunun içine oranlı sığdırır
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuTitles.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedIndex == index;
                      return ListTile(
                        leading: Icon(
                          _menuIcons[index],
                          color: isSelected
                              ? const Color(0xFF00FF66)
                              : const Color(0xFF627E82),
                        ),
                        title: Text(
                          _menuTitles[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF627E82),
                          ),
                        ),
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    },
                  ),
                ),
                // --- ÇIKIŞ BUTONU BURAYA EKLENİYOR ---
                const Divider(color: Color(0xFF13363B)),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  title: const Text(
                    'Çıkış Yap',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'TURNIGYM v1.0.0 Enterprise',
                    style: TextStyle(color: Color(0xFF13363B), fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          // ================= SAĞ ANA İÇERİK ALANI =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ÜST BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yönetim Paneli',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _menuTitles[_selectedIndex],
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // 🌟 SAĞ TARAFTAKİ YENİ YERİ: Dinamik Marka İsmi
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('salonlar')
                                .doc(salonId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const SizedBox(); // Yüklenirken boş bırak

                              String salonAdi = '';
                              if (snapshot.data!.data() != null) {
                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                salonAdi = data['salonAdi'] ?? '';
                              }

                              return Text(
                                salonAdi
                                    .toUpperCase(), // İSMİ BURAYA DEV EKRANDA BASIYORUZ
                                style: GoogleFonts.quicksand(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neonCyan,
                                  letterSpacing: 1.2,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            icon: Icon(
                              themeProvider.themeMode == ThemeMode.dark
                                  ? Icons.wb_sunny
                                  : Icons.nightlight_round,
                              color: AppColors.text(context),
                            ),
                            onPressed: () {
                              themeProvider.toggleTheme();
                            },
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Stack(
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                Positioned(
                                  right: 0,
                                  child: Icon(
                                    Icons.brightness_1,
                                    color: Colors.red,
                                    size: 8,
                                  ), // Bildirim noktası
                                ),
                              ],
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: const Color(0xFF04171A),
                                builder: (context) =>
                                    _buildRecentNotifications(),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          PopupMenuButton<String>(
                            color: const Color(0xFF0B2D33),
                            offset: const Offset(0, 50),
                            icon: const CircleAvatar(
                              backgroundColor: Color(0xFF00F0FF),
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                            onSelected: (value) async {
                              if (value == 'logout') {
                                await FirebaseAuth.instance.signOut();
                              } else if (value == 'profile') {
                                _showProfileModal(context);
                              } else if (value == 'settings') {
                                setState(() {
                                  _selectedIndex = 7; // Sistem Ayarları Sekmesi
                                });
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'profile',
                                child: Text(
                                  "Profilim",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'settings',
                                child: Text(
                                  "Ayarlar",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Text(
                                  "Çıkış Yap",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: _selectedIndex == 0
                        ? _buildDashboardView()
                        : _selectedIndex == 1
                        ? _buildMemberManagementView()
                        : _selectedIndex == 2
                        ? _buildPackageStoreView() // Market görünümünü buraya bağladık
                        : _selectedIndex == 3
                        ? _buildSalesReportsView() // Raporları buraya bağladık!
                        : _selectedIndex == 4
                        ? _buildPassAnalyticsView() // Geçiş Analitiği sayfası
                        : _selectedIndex == 5
                        ? _buildCompanyManagementView() // Şirket Tanımlama
                        : _selectedIndex == 6
                        ? _buildHardwareCalibrationView() // Donanım Kalibrasyonu
                        : _selectedIndex == 7
                        ? _buildSystemSettingsView() // Sistem Ayarları (Paket Tanımlama)
                        : _buildMemberManagementView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyManagementView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business_center, size: 80, color: Colors.cyan),
          const SizedBox(height: 30),
          const Text(
            "Kurumsal Üyelik ve İş Ortağı Yönetimi",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 600, // Sayfanın ortasında şık durması için
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _featureItem(
                  Icons.apartment,
                  "Kurumsal Çatı",
                  "Fabrika veya ofis bazlı grup üyeliklerini tek merkezden tanımlayın.",
                ),
                _featureItem(
                  Icons.bar_chart,
                  "Şirket Raporlaması",
                  "Hangi şirketin üyeleri, günün hangi saatlerinde salonunuzu daha aktif kullanıyor?",
                ),
                _featureItem(
                  Icons.handshake,
                  "Sözleşme Yönetimi",
                  "Kurumsal indirim tanımları ve özel paket sözleşmelerini dijitalleştirin.",
                ),
                _featureItem(
                  Icons.trending_up,
                  "Verimlilik Analizi",
                  "Anlaşmalı firmalarınızın 'Kredi' tüketim ve 'Kullanım' verimliliklerini izleyin.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String description) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildHardwareCalibrationView() {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const Icon(
          Icons.settings_input_component,
          size: 80,
          color: Colors.cyan,
        ),
        const SizedBox(height: 30),
        const Text(
          "Donanım ve Sistem Kalibrasyonu",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        _buildFeatureTile(
          Icons.wifi,
          "Canlı Bağlantı İzleme",
          "Raspberry Pi ve turnike sistemlerinin anlık durumunu takip edin.",
        ),
        _buildFeatureTile(
          Icons.speed,
          "Gecikme Analizi",
          "Komutların iletilme süresini ölçerek performansı optimize edin.",
        ),
        _buildFeatureTile(
          Icons.sync_alt,
          "Senkronizasyon Durumu",
          "Yerel ağdaki cihazların bulut ile veri eşzamanlamasını kontrol edin.",
        ),
      ],
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF04171A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00F0FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00F0FF), size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF627E82), fontSize: 13),
          ),
        ),
      ),
    );
  }

  // ================= 🔒 1. GÖRÜNÜM: KONTROL MERKEZİ =================
  Widget _buildDashboardView() {
    String todayStr = DateFormat('dd.MM.yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salonlar')
                          .doc(salonId)
                          .collection('uyeler')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print("Toplam Üye Hatası: ${snapshot.error}");
                          return _buildStatCard(
                            'TOPLAM AKTİF ÜYE',
                            'Hata',
                            Icons.people,
                            const Color(0xFF00FF66),
                          );
                        }
                        String totalMembers = snapshot.hasData
                            ? '${snapshot.data!.docs.length}'
                            : '...';
                        return _buildStatCard(
                          'TOPLAM AKTİF ÜYE',
                          totalMembers,
                          Icons.people,
                          const Color(0xFF00FF66),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salonlar')
                          .doc(salonId)
                          .collection('pass_logs')
                          .where('date', isEqualTo: todayStr)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print("Bugünkü Geçiş Hatası: ${snapshot.error}");
                          return _buildStatCard(
                            'BUGÜNKÜ GEÇİŞ',
                            'Hata',
                            Icons.swap_horiz,
                            const Color(0xFF00F0FF),
                          );
                        }
                        String todayPass = snapshot.hasData
                            ? '${snapshot.data!.docs.length}'
                            : '...';
                        return _buildStatCard(
                          'BUGÜNKÜ GEÇİŞ',
                          todayPass,
                          Icons.swap_horiz,
                          const Color(0xFF00F0FF),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salonlar')
                          .doc(salonId)
                          .collection('pass_logs')
                          .where('date', isEqualTo: todayStr)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print("Harcanan Kredi Hatası: ${snapshot.error}");
                          return _buildStatCard(
                            'HARCANAN KREDİ',
                            'Hata',
                            Icons.credit_score,
                            const Color(0xFFFF6B00),
                          );
                        }
                        String todayCredit = snapshot.hasData
                            ? '${snapshot.data!.docs.length}'
                            : '...';
                        return _buildStatCard(
                          'HARCANAN KREDİ',
                          todayCredit,
                          Icons.credit_score,
                          const Color(0xFFFF6B00),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'DONANIM SAĞLIĞI',
                      '%100',
                      Icons.speed,
                      const Color(0xFFFF00F0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(flex: 1, child: _buildInsideCard()),
          ],
        ),
        const SizedBox(height: 32),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04171A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HIZLI DONANIM AKSİYONLARI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Giriş turnikesini sunucu üzerinden anlık olarak manuel tetikleyebilirsiniz.',
                        style: TextStyle(
                          color: Color(0xFF627E82),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),

                      Center(
                        child: Container(
                          width: 280,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FF66).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_isProcessing)
                                return; // İşlem bitmeden tekrar basılmasını engelle
                              setState(() => _isProcessing = true);

                              try {
                                // 1. Kapıyı aç (Donanım komutu buraya eklenebilir)
                                // await sendHardwareCommand("OPEN_DOOR");

                                final memberSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('salonlar')
                                    .doc(salonId)
                                    .collection('uyeler')
                                    .orderBy('timestamp', descending: true)
                                    .limit(1)
                                    .get();

                                if (memberSnapshot.docs.isNotEmpty) {
                                  final lastMemberDoc =
                                      memberSnapshot.docs.first;
                                  final data =
                                      lastMemberDoc.data()
                                          as Map<String, dynamic>;
                                  final String memberName =
                                      data['name'] ?? 'Bilinmeyen Üye';
                                  final int currentCredit = data['credit'] ?? 0;
                                  final String docId = lastMemberDoc.id;
                                  // Üyenin mevcut durumunu al
                                  final bool isInside =
                                      data['isInside'] ?? false;

                                  if (currentCredit > 0) {
                                    // 2. Canlı trafiği güncelle (Durumu tersine çevir) ve krediyi düş
                                    await FirebaseFirestore.instance
                                        .collection('salonlar')
                                        .doc(salonId)
                                        .collection('uyeler')
                                        .doc(docId)
                                        .update({
                                          'credit': currentCredit - 1,
                                          'isInside': !isInside,
                                        });

                                    final now = DateTime.now();
                                    // 3. Geçiş günlüğüne yaz (Dashboard'daki sayılar artar)
                                    await FirebaseFirestore.instance
                                        .collection('salonlar')
                                        .doc(salonId)
                                        .collection('pass_logs')
                                        .add({
                                          'memberName': memberName,
                                          'memberId': docId,
                                          'date': DateFormat(
                                            'dd.MM.yyyy',
                                          ).format(now),
                                          'time': DateFormat(
                                            'HH:mm:ss',
                                          ).format(now),
                                          'status': 'Geçiş İzni',
                                          'type': !isInside ? 'GİRİŞ' : 'ÇIKIŞ',
                                          'timestamp':
                                              now.millisecondsSinceEpoch,
                                        });

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '⚡ $memberName turnikeden geçti! Kredisi ${currentCredit - 1}\'e düştü.',
                                          ),
                                          backgroundColor: const Color(
                                            0xFF041E22,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ $memberName isimli üyenin kredisi yetersiz! Geçiş reddedildi.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '⚠️ Sistemde kayıtlı üye bulunamadı! Önce üye ekleyin.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                print('Hata: $e');
                              } finally {
                                if (mounted) {
                                  setState(() => _isProcessing = false);
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.lock_open,
                              color: Colors.black,
                              size: 24,
                            ),
                            label: const Text(
                              'UZAKTAN TURNIKEYİ AÇ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF66),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04171A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KURUMSAL ÜYE DAĞILIMI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 40,
                                  sections: [
                                    PieChartSectionData(
                                      color: const Color(0xFF00FF66),
                                      value: 60,
                                      title: '%60',
                                      radius: 25,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFF00F0FF),
                                      value: 25,
                                      title: '%25',
                                      radius: 25,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFFFF6B00),
                                      value: 15,
                                      title: '%15',
                                      radius: 25,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ChartLegend(
                                  color: Color(0xFF00FF66),
                                  text: 'TurniGym VIP',
                                ),
                                SizedBox(height: 8),
                                _ChartLegend(
                                  color: Color(0xFF00F0FF),
                                  text: 'Greyder',
                                ),
                                SizedBox(height: 8),
                                _ChartLegend(
                                  color: Color(0xFFFF6B00),
                                  text: 'Mavi',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color neonColor,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 0), // Taşıyıcıyı esnek yap
      margin: EdgeInsets.zero, // Margin'i sıfırla, Expanded zaten hallediyor
      padding: const EdgeInsets.all(12), // Padding'i hafif daralt
      decoration: BoxDecoration(
        color: const Color(0xFF04171A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF627E82),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: neonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: neonColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildInsideCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF04171A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FF66).withOpacity(0.3)),
      ),
      child: StreamBuilder<QuerySnapshot>(
        // 'isInside' alanı true olan üyeleri filtreliyoruz
        stream: FirebaseFirestore.instance
            .collection('salonlar')
            .doc(salonId)
            .collection('uyeler')
            .where('isInside', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("İçeridekiler Hatası: ${snapshot.error}");
            return Text(
              "Hata: ${snapshot.error}",
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            );
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(color: Color(0xFF00FF66));
          }
          final insideCount = snapshot.data!.docs.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ANLIK İÇERİDEKİLER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$insideCount Üye",
                style: const TextStyle(
                  fontSize: 32,
                  color: Color(0xFF00FF66),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Salon trafiği aktif",
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= 👥 2. GÖRÜNÜM: ÜYE VE KREDI YÖNETİMİ =================
  Widget _buildMemberManagementView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF04171A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00F0FF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Arama',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF02090B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00F0FF).withOpacity(0.5),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim().toLowerCase();
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF00F0FF),
                              size: 16,
                            ),
                            hintText: 'Üye ismi ara...',
                            hintStyle: TextStyle(
                              color: Color(0xFF627E82),
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Üye Listesi (Profil detayları ve güncelleme için satıra tıklayın)',
                style: TextStyle(
                  color: Color(0xFF627E82),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF04171A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withOpacity(0.15),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Container(
                          color: const Color(0xFF02090B),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Profil',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF627E82),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'İsim / Telefon',
                                  style: TextStyle(
                                    color: Color(0xFF627E82),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Kredi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF627E82),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Şirket',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF627E82),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'İşlemler',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Color(0xFF627E82),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('salonlar')
                                .doc(salonId)
                                .collection('uyeler')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                print("Üye Listesi Hatası: ${snapshot.error}");
                                return const Center(
                                  child: Text(
                                    'Hata oluştu. Konsolu kontrol edin.',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00F0FF),
                                  ),
                                );
                              }

                              final docs = snapshot.data?.docs ?? [];
                              var filteredDocs = docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final name = (data['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return name.contains(_searchQuery);
                              }).toList();

                              filteredDocs.sort((a, b) {
                                final dataA = a.data() as Map<String, dynamic>;
                                final dataB = b.data() as Map<String, dynamic>;
                                final timeA = dataA['timestamp'] ?? 0;
                                final timeB = dataB['timestamp'] ?? 0;
                                return timeB.compareTo(timeA);
                              });

                              if (filteredDocs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Kayıtlı üye bulunamadı.',
                                    style: TextStyle(color: Color(0xFF627E82)),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      filteredDocs[index].data()
                                          as Map<String, dynamic>;
                                  final docId = filteredDocs[index].id;

                                  return _buildCyberTableRow(
                                    context,
                                    docId,
                                    data,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 3,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F0FF), Color(0xFFFF6B00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(-2, 0),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF6B00).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const MemberFormDialog(),
                    );
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Yeni Üye Ekle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02090B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cihaz Durumu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Center(
                        child: Text(
                          'Aktif',
                          style: TextStyle(
                            color: Color(0xFF00FF66),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset(
                          'assets/images/cihaz_durumu.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      const Text(
                        'Son Geçişler',
                        style: TextStyle(
                          color: Color(0xFF627E82),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('salonlar')
                              .doc(salonId)
                              .collection('pass_logs')
                              .orderBy('timestamp', descending: true)
                              .limit(10)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              print("Son Geçişler Hatası: ${snapshot.error}");
                              return Center(
                                child: Text(
                                  'Hata: ${snapshot.error}',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF00F0FF),
                                ),
                              );
                            }
                            final logDocs = snapshot.data?.docs ?? [];
                            if (logDocs.isEmpty)
                              return const Center(
                                child: Text(
                                  'Henüz geçiş kaydı yok.',
                                  style: TextStyle(
                                    color: Color(0xFF627E82),
                                    fontSize: 12,
                                  ),
                                ),
                              );

                            return ListView.builder(
                              itemCount: logDocs.length,
                              itemBuilder: (context, index) {
                                final logData =
                                    logDocs[index].data()
                                        as Map<String, dynamic>;
                                final name =
                                    logData['memberName'] ?? 'Bilinmeyen Üye';
                                final date = logData['date'] ?? '-';
                                final time = logData['time'] ?? '-';
                                final status =
                                    logData['status'] ?? 'Geçiş İzni';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              '$date  $time',
                                              style: const TextStyle(
                                                color: Color(0xFF627E82),
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        status,
                                        style: const TextStyle(
                                          color: Color(0xFF00FF66),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCyberTableRow(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final String name = data['name'] ?? 'Bilinmeyen Üye';
    final String phone = data['phone'] ?? '-';
    final int credit = data['credit'] ?? 0;
    final String company = data['company'] ?? 'TurniGym';
    final String gender = data['gender'] ?? 'Erkek';
    final bool isFemale = gender == 'Kadın';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              MemberFormDialog(docId: docId, existingData: data),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF02171A))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        isFemale
                            ? 'assets/images/kiz.png'
                            : 'assets/images/erkek.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF00F0FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    phone,
                    style: const TextStyle(
                      color: Color(0xFF627E82),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '$credit',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  company,
                  style: const TextStyle(color: Color(0xFF627E82)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // YENİ SATIŞ BUTONU BURAYA EKLENDİ
                  IconButton(
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Color(0xFF00FF66),
                      size: 16,
                    ),
                    tooltip: 'Hızlı Kredi Yükle',
                    onPressed: () => _showQuickSaleDialog(docId, name),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.qr_code_2_outlined,
                      color: Color(0xFF00F0FF),
                      size: 16,
                    ),
                    tooltip: 'Karekod Oluştur',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) =>
                          QrDisplayDialog(memberId: docId, memberName: name),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFFF3B30),
                      size: 16,
                    ),
                    onPressed: () async => await FirebaseFirestore.instance
                        .collection('salonlar')
                        .doc(salonId)
                        .collection('uyeler')
                        .doc(docId)
                        .delete(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickSaleDialog(String memberId, String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF04171A),
        title: Text(
          "Kredi Yükle: $memberName",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _packageOption("Aylık Paket (Sınırsız)", 500, memberId),
            const SizedBox(height: 10),
            _packageOption("10'lu Seans (Kredi)", 300, memberId),
          ],
        ),
      ),
    );
  }

  Widget _packageOption(String name, int price, String memberId) {
    return ListTile(
      tileColor: const Color(0xFF0B2D33),
      title: Text(name, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        "$price TL",
        style: const TextStyle(color: Colors.greenAccent),
      ),
      onTap: () {
        // 1. Önce onay iste
        showDialog(
          context: context,
          barrierDismissible:
              false, // İşlem yapılıyorken yanlışlıkla dışarı tıklamayı engelle
          builder: (BuildContext dialogContext) {
            bool isLoading = false;
            return StatefulBuilder(
              builder: (BuildContext stateContext, StateSetter setState) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF04171A),
                  title: Text(
                    isLoading ? "İşlem Yapılıyor..." : "Satışı Onayla",
                    style: const TextStyle(color: Colors.white),
                  ),
                  content: isLoading
                      ? const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF00FF66)),
                            SizedBox(height: 16),
                            Text(
                              "Veritabanı güncelleniyor...",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                      : Text(
                          "$name için $price TL tahsil edilecek. Onaylıyor musunuz?",
                        ),
                  actions: isLoading
                      ? [] // Yüklenirken butonları gizle
                      : [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text("İptal"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(
                                () => isLoading = true,
                              ); // Spinner animasyonunu aktif et
                              await _performSale(
                                memberId,
                                price,
                                name,
                              ); // İşlemi yap (İlk ekranı kendi içindeki pop kapatacak)

                              if (mounted)
                                Navigator.pop(
                                  context,
                                ); // Arka planda kalan paket seçme ekranını da kapat
                            },
                            child: const Text("ONAYLA"),
                          ),
                        ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _performSale(String memberId, int price, String name) async {
    // 1. Firebase güncellemeleri
    await FirebaseFirestore.instance
        .collection('salonlar')
        .doc(salonId)
        .collection('uyeler')
        .doc(memberId)
        .update({'credit': FieldValue.increment(price)});

    await FirebaseFirestore.instance
        .collection('salonlar')
        .doc(salonId)
        .collection('transactions')
        .add({
          'memberId': memberId,
          'amount': price,
          'packageName': name,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

    // 2. Başarı mesajı (SnackBar)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text('Satış başarılı: $name - $price TL yüklendi!'),
            ],
          ),
          backgroundColor: const Color(0xFF00FF66),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context); // İlk açılan Paket seçimi diyaloğunu kapat
    }
  }

  Widget _buildRecentNotifications() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF04171A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Son Sistem Bildirimleri",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('salonlar')
                .doc(salonId)
                .collection('pass_logs')
                .orderBy('timestamp', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print("Sistem Bildirimleri Hatası: ${snapshot.error}");
                return Text(
                  "Hata: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent),
                );
              }
              if (!snapshot.hasData)
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                );
              final docs = snapshot.data!.docs;
              if (docs.isEmpty)
                return const Text(
                  "Yeni bildirim yok.",
                  style: TextStyle(color: Colors.grey),
                );

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final bool isSuccess = data['status'] == 'Geçiş İzni';
                  return ListTile(
                    leading: Icon(
                      isSuccess
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: isSuccess
                          ? const Color(0xFF00FF66)
                          : Colors.redAccent,
                    ),
                    title: Text(
                      data['memberName'] ?? 'Bilinmeyen Üye',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${data['status']} - ${data['date']} ${data['time']}",
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageStoreView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('salonlar')
          .doc(salonId)
          .collection('packages')
          .orderBy('price')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Paket Market Hatası: ${snapshot.error}");
          return Center(
            child: Text(
              "Hata: ${snapshot.error}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
          );
        }

        final docs = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final iconStr = (data['icon'] ?? '').toString().toLowerCase();

            // İkonları metinden yakalamak için basit bir eşleştirme
            IconData packageIcon = Icons.local_offer_outlined;
            if (iconStr.contains('fitness')) packageIcon = Icons.fitness_center;
            if (iconStr.contains('infinite') || iconStr.contains('inclusive'))
              packageIcon = Icons.all_inclusive;
            if (iconStr.contains('premium'))
              packageIcon = Icons.workspace_premium;

            // Renkleri sırayla atamak için
            final colors = [
              Colors.cyan,
              Colors.greenAccent,
              Colors.amber,
              Colors.purpleAccent,
              Colors.orange,
            ];
            final color = colors[index % colors.length];

            return _buildPackageCard(
              data['name'] ?? 'Paket',
              "${data['price']} TL",
              packageIcon,
              color,
            );
          },
        );
      },
    );
  }

  Widget _buildPackageCard(
    String title,
    String price,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF04171A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Üye seçip satış yapma mantığı buraya eklenecek
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              "Hızlı Satış Yap",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesReportsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF04171A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FİNANSAL SATIŞ RAPORLARI",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('salonlar')
                  .doc(salonId)
                  .collection('transactions')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Satış Raporları Hatası: ${snapshot.error}");
                  return Center(
                    child: Text(
                      "Hata: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(
                    child: Text(
                      "Henüz satış yok.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      color: const Color(0xFF0B2D33),
                      child: ListTile(
                        leading: const Icon(
                          Icons.receipt_long,
                          color: Color(0xFF00F0FF),
                        ),
                        title: Text(
                          data['packageName'] ?? 'Paket',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              data['timestamp'],
                            ),
                          ),
                        ),
                        trailing: Text(
                          "${data['amount']} TL",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= 📊 5. GÖRÜNÜM: GEÇİŞ ANALİTİĞİ =================
  Widget _buildPassAnalyticsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF04171A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "GEÇİŞ ANALİTİĞİ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2D33),
                  foregroundColor: Colors.white,
                  selectedForegroundColor: Colors.black,
                  selectedBackgroundColor: const Color(0xFF00F0FF),
                ),
                segments: const [
                  ButtonSegment(value: 'GÜNLÜK', label: Text('Bugün')),
                  ButtonSegment(value: 'AYLIK', label: Text('Bu Ay')),
                ],
                selected: {_analyticsViewMode},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _analyticsViewMode = newSelection.first;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Özet Kartları (Toplam Giriş, Ortalama Süre, Yoğun Saat)
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  "Toplam Giriş",
                  "124",
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  "Ort. Salon Süresi",
                  "75 dk",
                  Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  "En Yoğun Saat",
                  "19:00",
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Detaylı Liste veya Grafik
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('salonlar')
                  .doc(salonId)
                  .collection('pass_logs')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Geçiş Analitiği Hatası: ${snapshot.error}");
                  return Center(
                    child: Text(
                      "Hata: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                  );
                }
                final logs = snapshot.data!.docs;
                return Column(
                  children: [
                    Expanded(
                      child: _analyticsViewMode == 'GÜNLÜK'
                          ? _buildDailyChart(logs)
                          : _buildMonthlyChart(logs),
                    ),
                    _buildSmartAnalysis(logs, _salonCapacity),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart(List<QueryDocumentSnapshot> logs) {
    Map<int, int> hourlyData = {};
    DateTime now = DateTime.now();

    // Sadece BUGÜNÜN verilerini filtrele ve saatlere böl
    for (var doc in logs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        data['timestamp'] ?? 0,
      );
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        int hour = date.hour;
        hourlyData[hour] = (hourlyData[hour] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (hourlyData.values.isEmpty
                  ? 0
                  : hourlyData.values
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble()) +
              5,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 4 == 0)
                    return Text(
                      '${value.toInt()}:00',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    );
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            24,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (hourlyData[i] ?? 0).toDouble(),
                  color: const Color(0xFF00F0FF),
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(List<QueryDocumentSnapshot> logs) {
    Map<int, int> dailyData = {};
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Sadece BU AYIN verilerini filtrele ve günlere böl
    for (var doc in logs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        data['timestamp'] ?? 0,
      );
      if (date.year == now.year && date.month == now.month) {
        int day = date.day;
        dailyData[day] = (dailyData[day] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.2)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (dailyData.values.isEmpty
                  ? 0
                  : dailyData.values
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble()) +
              5,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Sadece 1. gün ve 5'in katları olan günleri yazdır
                  if (value % 5 == 0 || value == 1)
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    );
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(daysInMonth, (i) {
            int day = i + 1;
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: (dailyData[day] ?? 0).toDouble(),
                  color: const Color(0xFFFF6B00),
                  width: 6,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ================= 🤖 AKILLI ÖZET ANALİZİ =================
  Widget _buildSmartAnalysis(List<QueryDocumentSnapshot> logs, int capacity) {
    DateTime now = DateTime.now();
    int currentUsage = 0;

    // Şu anki (bu saatteki) girişleri say
    for (var doc in logs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        data['timestamp'] ?? 0,
      );
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day &&
          date.hour == now.hour) {
        currentUsage++;
      }
    }

    double occupancyRate = capacity > 0 ? (currentUsage / capacity) * 100 : 0;
    if (occupancyRate > 100) occupancyRate = 100;

    Color statusColor = occupancyRate > 80 ? Colors.redAccent : Colors.cyan;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Analiz: Salon şu an %${occupancyRate.toInt()} kapasite ile çalışıyor. " +
                  (occupancyRate > 80
                      ? "Uyarı: Salon oldukça kalabalık!"
                      : "Salon kullanımı normal seviyede."),
              style: TextStyle(color: statusColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  int _findBusiestHour(List<QueryDocumentSnapshot> logs) {
    Map<int, int> hourlyData = {};
    DateTime now = DateTime.now();

    // Bugünün girişlerini saatlere göre grupla
    for (var doc in logs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        data['timestamp'] ?? 0,
      );
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        int hour = date.hour;
        hourlyData[hour] = (hourlyData[hour] ?? 0) + 1;
      }
    }

    if (hourlyData.isEmpty) return 0;
    // En yüksek giriş yapılan saati döndür
    return hourlyData.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculateOccupancy(List<QueryDocumentSnapshot> logs) {
    int busiestHour = _findBusiestHour(logs);
    int countInBusiestHour = 0;
    DateTime now = DateTime.now();

    // Sadece en yoğun saatteki giriş sayısını hesapla
    for (var doc in logs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        data['timestamp'] ?? 0,
      );
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day &&
          date.hour == busiestHour) {
        countInBusiestHour++;
      }
    }

    int capacity = 50; // Salonun varsayılan maksimum kişi kapasitesi
    double occupancy = (countInBusiestHour / capacity) * 100;
    return occupancy > 100 ? 100 : occupancy;
  }

  // URL ile Güncelleme Fonksiyonu
  Future<void> _updateLogoUrl() async {
    try {
      final newUrl = _logoUrlController.text.trim();
      // Not: Eski sisteme uyumlu olması için alan adını "logoUrl" olarak tutuyoruz.
      await FirebaseFirestore.instance
          .collection('salonlar')
          .doc(salonId)
          .collection('sistem_ayarları')
          .doc('general')
          .set({'logo_url': newUrl}, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _currentLogoUrl = newUrl.isEmpty
              ? null
              : newUrl; // Arayüzü anında güncelle
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "✅ Logo URL başarıyla güncellendi!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Color(0xFF00FF66),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Bir hata oluştu, lütfen tekrar deneyin.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSystemSettingsView() {
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF04171A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SİSTEM AYARLARI",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const TabBar(
              indicatorColor: Color(0xFF00F0FF),
              labelColor: Color(0xFF00F0FF),
              unselectedLabelColor: Color(0xFF627E82),
              tabs: [
                Tab(text: "Paket Yönetimi", icon: Icon(Icons.shopping_bag)),
                Tab(text: "Genel Ayarlar", icon: Icon(Icons.settings)),
                Tab(text: "Güvenlik", icon: Icon(Icons.security)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPackageManagementSection(),
                  _buildGeneralSettingsSection(),
                  _buildSecuritySettingsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettingsSection() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B2D33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Güvenlik ve Erişim Ayarları",
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline, color: Colors.white),
                iconColor: const Color(0xFF00F0FF),
                collapsedIconColor: const Color(0xFF627E82),
                title: const Text(
                  "Güvenlik ve Parola",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Hesap şifrenizi güvenli bir şekilde güncelleyin.",
                  style: TextStyle(color: Color(0xFF627E82), fontSize: 12),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02090B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00F0FF).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Şifre yenileme işlemi, yüksek güvenlik gerektirdiği için 3 adımlı doğrulama (Eski Şifre -> Yeni Şifre -> Tekrar) ile yapılmaktadır. Güvenli panele geçmek için aşağıdaki butona tıklayın.",
                          style: TextStyle(
                            color: Color(0xFF627E82),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  const ChangePasswordDialog(),
                            );
                          },
                          icon: const Icon(Icons.password),
                          label: const Text(
                            "ŞİFREYİ GÜNCELLE",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00F0FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettingsSection() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B2D33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Görünüm Ayarları",
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _logoUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Logo URL Adresi",
                hintText: "https://siteadi.com/logo.png",
                labelStyle: const TextStyle(color: Color(0xFF627E82)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00F0FF)),
                ),
                prefixIcon: const Icon(Icons.link, color: Color(0xFF00F0FF)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _updateLogoUrl,
              icon: const Icon(Icons.save),
              label: const Text(
                "URL İLE GÜNCELLE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                backgroundColor: const Color(0xFF00FF66),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _salonCapacityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Salon Kapasitesi (Maksimum Kişi)',
                      labelStyle: TextStyle(color: Color(0xFF627E82)),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00F0FF)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final capacity =
                        int.tryParse(_salonCapacityController.text.trim()) ??
                        50;
                    await FirebaseFirestore.instance
                        .collection('salonlar')
                        .doc(salonId)
                        .collection('sistem_ayarları')
                        .doc('general')
                        .set({
                          'salon_capacity': capacity,
                        }, SetOptions(merge: true));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '✅ Kapasite başarıyla güncellendi!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Color(0xFF00FF66),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("KAYDET"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    backgroundColor: const Color(0xFF00FF66),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Dashboard'da İçeridekiler Kartını Göster",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "Ana ekranda anlık içerideki üyeleri gösteren kartı açıp kapatır.",
                style: TextStyle(color: Color(0xFF627E82), fontSize: 12),
              ),
              activeColor: const Color(0xFF00FF66),
              value: _showInsideCard,
              onChanged: (val) async {
                await FirebaseFirestore.instance
                    .collection('salonlar')
                    .doc(salonId)
                    .collection('sistem_ayarları')
                    .doc('general')
                    .set({'showInsideCard': val}, SetOptions(merge: true));
              },
            ),
            const Divider(color: Color(0xFF13363B)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Liste Satır Sayısı",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "Tablolarda gösterilecek varsayılan satır sayısı.",
                style: TextStyle(color: Color(0xFF627E82), fontSize: 12),
              ),
              trailing: DropdownButton<String>(
                value: _listRowCount,
                dropdownColor: const Color(0xFF0B2D33),
                style: const TextStyle(color: Colors.white),
                items: ['10', '25', '50'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) async {
                  if (val != null) {
                    await FirebaseFirestore.instance
                        .collection('salonlar')
                        .doc(salonId)
                        .collection('sistem_ayarları')
                        .doc('general')
                        .set({
                          'listRowCount': int.tryParse(val) ?? 25,
                        }, SetOptions(merge: true));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B2D33),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Yeni Paket Tanımla",
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _packageNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Paket Adı',
                        labelStyle: TextStyle(color: Color(0xFF627E82)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00F0FF)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _packagePriceController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (TL)',
                        labelStyle: TextStyle(color: Color(0xFF627E82)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00F0FF)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _packageIconController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'İkon (örn: fitness_center)',
                        labelStyle: TextStyle(color: Color(0xFF627E82)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00F0FF)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final name = _packageNameController.text.trim();
                      final priceStr = _packagePriceController.text.trim();
                      final iconStr = _packageIconController.text.trim();

                      if (name.isNotEmpty && priceStr.isNotEmpty) {
                        final price = double.tryParse(priceStr) ?? 0.0;
                        await _addPackage(name, price, iconStr);

                        _packageNameController.clear();
                        _packagePriceController.clear();
                        _packageIconController.clear();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Paket başarıyla kaydedildi!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Color(0xFF00FF66),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("KAYDET"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFF00FF66),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Kayıtlı Paketler",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('salonlar')
                .doc(salonId)
                .collection('packages')
                .orderBy('price')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print("Kayıtlı Paketler Hatası: ${snapshot.error}");
                return Center(
                  child: Text(
                    "Hata: ${snapshot.error}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                );
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Text(
                  "Henüz kayıtlı bir paket bulunmuyor.",
                  style: TextStyle(color: Colors.grey),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;

                  return Card(
                    color: const Color(0xFF02090B),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: const Color(0xFF00F0FF).withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.local_offer_outlined,
                        color: Color(0xFF00F0FF),
                      ),
                      title: Text(
                        data['name'] ?? 'Paket',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${data['price']} TL",
                        style: const TextStyle(color: Colors.greenAccent),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('salonlar')
                              .doc(salonId)
                              .collection('packages')
                              .doc(docId)
                              .delete();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Paket Ekleme Fonksiyonu
  Future<void> _addPackage(String name, double price, String iconStr) async {
    await FirebaseFirestore.instance
        .collection('salonlar')
        .doc(salonId)
        .collection('packages')
        .add({
          'name': name,
          'price': price,
          'icon': iconStr,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String text;
  const _ChartLegend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

// ================= 🔐 ŞİFRE DEĞİŞTİRME DİYALOGU =================
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (user.email != null) {
        // 1. Mevcut şifreyi doğrula
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordCtrl.text,
        );
        await user.reauthenticateWithCredential(credential);

        // 2. Yeni şifreyi güncelle
        await user.updatePassword(_newPasswordCtrl.text);

        // 3. Başarılı mesajı göster ve kapat
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "✅ Şifreniz başarıyla güncellendi!",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Color(0xFF00FF66),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg =
          e.message ?? "Bir hata oluştu."; // Orijinal hatayı yakala
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMsg = "Mevcut şifreniz yanlış.";
      } else if (e.code == 'weak-password') {
        errorMsg = "Yeni şifreniz çok zayıf (En az 6 karakter olmalı).";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF04171A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Şifre Değiştir",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildPasswordField("Mevcut Şifre", _oldPasswordCtrl, null),
              const SizedBox(height: 16),
              _buildPasswordField("Yeni Şifre", _newPasswordCtrl, (val) {
                if (val == null || val.length < 6)
                  return "Şifre en az 6 karakter olmalı.";
                return null;
              }),
              const SizedBox(height: 16),
              _buildPasswordField("Yeni Şifre (Tekrar)", _confirmPasswordCtrl, (
                val,
              ) {
                if (val != _newPasswordCtrl.text) return "Şifreler eşleşmiyor.";
                return null;
              }),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      "İptal",
                      style: TextStyle(color: Color(0xFF627E82)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00F0FF),
                      foregroundColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "GÜNCELLE",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator:
          validator ??
          (val) => val == null || val.isEmpty ? "Bu alan zorunludur" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF627E82), fontSize: 13),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF00F0FF),
          size: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: const Color(0xFF00F0FF).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00F0FF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: const Color(0xFF02090B),
      ),
    );
  }
}

// ================= KAREKOD DİYALOG POP-UP'I =================
class QrDisplayDialog extends StatefulWidget {
  final String memberId;
  final String memberName;
  const QrDisplayDialog({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<QrDisplayDialog> createState() => _QrDisplayDialogState();
}

class _QrDisplayDialogState extends State<QrDisplayDialog> {
  late Timer _timer;
  String _currentQrData = "";

  @override
  void initState() {
    super.initState();
    _generateDynamicQr();
    // Her 10 saniyede bir QR'ı yenile
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _generateDynamicQr();
    });
  }

  void _generateDynamicQr() {
    // 10 saniyelik zaman dilimi (time slot)
    int timeSlot = DateTime.now().millisecondsSinceEpoch ~/ 10000;

    // memberID ve zaman dilimini birleştirip hash'le
    var bytes = utf8.encode("${widget.memberId}:$timeSlot");
    var digest = sha256.convert(bytes);

    setState(() {
      _currentQrData = digest.toString();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF04171A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GÜVENLİ GİRİŞ KODU',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: QrImageView(
                data: _currentQrData,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "10 saniyede bir yenilenir",
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('KAPAT'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 🔮 PREMIUM SAAS GÜNCELLEME MOTORLU FORM DİYALOGU =================
class MemberFormDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const MemberFormDialog({super.key, this.docId, this.existingData});

  @override
  State<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _creditCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedGender = 'Erkek';
  String _selectedBloodGroup = 'Belirtilmemiş';
  bool _isLoading = false;

  final List<String> _genders = ['Erkek', 'Kadın'];
  final List<String> _bloodGroups = [
    'Belirtilmemiş',
    'A RH+',
    'A RH-',
    'B RH+',
    'B RH-',
    'AB RH+',
    'AB RH-',
    '0 RH+',
    '0 RH-',
  ];

  String get salonId => FirebaseAuth.instance.currentUser!.uid;

  bool get isEditMode => widget.docId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode && widget.existingData != null) {
      final data = widget.existingData!;
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _creditCtrl.text = (data['credit'] ?? 0).toString();
      _emergencyPhoneCtrl.text = data['emergencyPhone'] ?? '';
      _notesCtrl.text = data['notes'] ?? '';
      _selectedGender = data['gender'] ?? 'Erkek';
      _selectedBloodGroup = data['bloodGroup'] ?? 'Belirtilmemiş';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _creditCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final credit = int.tryParse(_creditCtrl.text.trim()) ?? 0;
    final emergencyPhone = _emergencyPhoneCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> payload = {
        'name': name,
        'phone': phone,
        'credit': credit,
        'emergencyPhone': emergencyPhone,
        'gender': _selectedGender,
        'bloodGroup': _selectedBloodGroup,
        'notes': notes,
        'company': widget.existingData?['company'] ?? 'TurniGym',
      };

      if (isEditMode) {
        await FirebaseFirestore.instance
            .collection('salonlar')
            .doc(salonId)
            .collection('uyeler')
            .doc(widget.docId)
            .update(payload);
      } else {
        payload['status'] = 'Active';
        payload['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance
            .collection('salonlar')
            .doc(salonId)
            .collection('uyeler')
            .add(payload);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFemale = _selectedGender == 'Kadın';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF04171A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEditMode
                ? const Color(0xFFFF6B00)
                : const Color(0xFF00F0FF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isEditMode
                  ? const Color(0xFFFF6B00).withOpacity(0.1)
                  : const Color(0xFF00F0FF).withOpacity(0.1),
              blurRadius: 15,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF02090B),
                      backgroundImage: AssetImage(
                        isFemale
                            ? 'assets/images/kiz.png'
                            : 'assets/images/erkek.png',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ÜYE PROFİLİ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditMode
                                ? 'ID: ${widget.docId}'
                                : 'Durum: Eksiksiz Veri Doğrulama',
                            style: const TextStyle(
                              color: Color(0xFF627E82),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isEditMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF66).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF00FF66).withOpacity(0.4),
                          ),
                        ),
                        child: const Text(
                          'AKTİF',
                          style: TextStyle(
                            color: Color(0xFF00FF66),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),

                _buildValidatableField(
                  'İsim Soyisim *',
                  Icons.person_outline,
                  _nameCtrl,
                  isRequired: true,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildValidatableField(
                        'Telefon (0XXX XXX XX XX) *',
                        Icons.phone_outlined,
                        _phoneCtrl,
                        isRequired: true,
                        isPhoneFormat: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildValidatableField(
                        'Kredi Bakiyesi *',
                        Icons.credit_score_outlined,
                        _creditCtrl,
                        isNum: true,
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildValidatableField(
                  'Acil Durum Yakın Telefonu (Opsiyonel)',
                  Icons.contact_phone_outlined,
                  _emergencyPhoneCtrl,
                  isRequired: false,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        'Cinsiyet *',
                        Icons.wc,
                        _selectedGender,
                        _genders,
                        (value) {
                          setState(() => _selectedGender = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownField(
                        'Kan Grubu',
                        Icons.bloodtype_outlined,
                        _selectedBloodGroup,
                        _bloodGroups,
                        (value) {
                          setState(() => _selectedBloodGroup = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText:
                        'Sağlık ve Özel Notlar (Astım, Sakatlık, Önemli Notlar...)',
                    labelStyle: const TextStyle(
                      color: Color(0xFF627E82),
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.assignment_outlined,
                      color: Color(0xFF00F0FF),
                      size: 18,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: Color(0xFF00F0FF),
                        width: 0.3,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFF00F0FF)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF02090B),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: Color(0xFF627E82)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEditMode
                            ? const Color(0xFFFF6B00)
                            : const Color(0xFF00FF66),
                        foregroundColor: Colors.black,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              isEditMode ? 'DEĞİŞİKLİKLERİ KAYDET' : 'KAYDET',
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidatableField(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    bool isNum = false,
    bool isRequired = false,
    bool isPhoneFormat = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: (isNum || isPhoneFormat)
          ? TextInputType.number
          : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Bu alan mecburi bırakılamaz!';
        }
        if (isRequired && isNum && int.tryParse(value!.trim()) == null) {
          return 'Lütfen geçerli bir sayı girin!';
        }
        if (isPhoneFormat && value != null && value.trim().isNotEmpty) {
          if (value.trim().length != 14) {
            return 'Telefon 0XXX XXX XX XX formatında olmalıdır!';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF627E82), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00F0FF), size: 18),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF00F0FF), width: 0.3),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF00F0FF)),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF02090B),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    String selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF04171A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF627E82), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00F0FF), size: 18),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF00F0FF), width: 0.3),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF00F0FF)),
        ),
        filled: true,
        fillColor: const Color(0xFF02090B),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
      ),
    );
  }
}
