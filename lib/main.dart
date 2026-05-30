import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TurniGymApp());
}

class TurniGymApp extends StatelessWidget {
  const TurniGymApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030E11),
        cardColor: const Color(0xFF04171A),
        primaryColor: const Color(0xFF00F0FF),
      ),
      home: const AuthChecker(),
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
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<String> _menuTitles = [
    'Kontrol Merkezi',
    'Üye & Kredi Yönetimi',
    'Paket & Satış',
    'Geçiş Analitiği',
    'Şirket Tanımlama',
    'Donanım Kalibrasyonu',
    'Sistem Ayarları',
  ];

  final List<IconData> _menuIcons = [
    Icons.token_outlined,
    Icons.group_outlined,
    Icons.add_card_outlined,
    Icons.analytics_outlined,
    Icons.business_outlined,
    Icons.developer_board,
    Icons.tune_outlined,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Image.asset('assets/images/turnigym.png', width: 180),
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
                            style: TextStyle(
                              color: Color(0xFF627E82),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _menuTitles[_selectedIndex],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Color(0xFFFF3B30),
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00F0FF),
                                width: 1.5,
                              ),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Color(0xFF04171A),
                              child: Icon(
                                Icons.person_outline,
                                color: Color(0xFF00F0FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: _selectedIndex == 0
                        ? _buildDashboardView()
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

  // ================= 🔒 1. GÖRÜNÜM: KONTROL MERKEZİ =================
  Widget _buildDashboardView() {
    String todayStr = DateFormat('dd.MM.yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('members')
                  .snapshots(),
              builder: (context, snapshot) {
                String totalMembers = snapshot.hasData
                    ? '${snapshot.data!.docs.length}'
                    : '...';
                return _buildStatCard(
                  'TOPLAM AKTİF ÜYE',
                  totalMembers,
                  Icons.group_add,
                  const Color(0xFF00FF66),
                );
              },
            ),
            const SizedBox(width: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pass_logs')
                  .where('date', isEqualTo: todayStr)
                  .snapshots(),
              builder: (context, snapshot) {
                String todayPass = snapshot.hasData
                    ? '${snapshot.data!.docs.length}'
                    : '...';
                return _buildStatCard(
                  'BUGÜNKÜ GEÇİŞ',
                  todayPass,
                  Icons.swap_vert,
                  const Color(0xFF00F0FF),
                );
              },
            ),
            const SizedBox(width: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pass_logs')
                  .where('date', isEqualTo: todayStr)
                  .snapshots(),
              builder: (context, snapshot) {
                String todayCredit = snapshot.hasData
                    ? '${snapshot.data!.docs.length}'
                    : '...';
                return _buildStatCard(
                  'HARCANAN KREDİ',
                  todayCredit,
                  Icons.bolt,
                  const Color(0xFFFF6B00),
                );
              },
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'DONANIM SAĞLIĞI',
              '%100',
              Icons.router,
              const Color(0xFFFF00F0),
            ),
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
                              try {
                                final memberSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('members')
                                    .orderBy('timestamp', descending: true)
                                    .limit(1)
                                    .get();

                                if (memberSnapshot.docs.isNotEmpty) {
                                  final lastMemberDoc =
                                      memberSnapshot.docs.first;
                                  final String memberName =
                                      lastMemberDoc['name'];
                                  final int currentCredit =
                                      lastMemberDoc['credit'];
                                  final String docId = lastMemberDoc.id;

                                  if (currentCredit > 0) {
                                    await FirebaseFirestore.instance
                                        .collection('members')
                                        .doc(docId)
                                        .update({'credit': currentCredit - 1});

                                    final now = DateTime.now();
                                    await FirebaseFirestore.instance
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
                                flex: 2,
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
                                .collection('members')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return const Center(
                                  child: Text('Hata oluştu.'),
                                );
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
                              .collection('pass_logs')
                              .orderBy('timestamp', descending: true)
                              .limit(10)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return const Center(
                                child: Text(
                                  'Log hatası.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                  ),
                                ),
                              );
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
              flex: 2,
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
                  IconButton(
                    icon: const Icon(
                      Icons.qr_code_2_outlined,
                      color: Color(0xFF00F0FF),
                      size: 18,
                    ),
                    tooltip: 'Karekod Oluştur',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            QrDisplayDialog(memberId: docId, memberName: name),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFFF3B30),
                      size: 16,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('members')
                          .doc(docId)
                          .delete();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

// ================= KAREKOD DİYALOG POP-UP'I =================
class QrDisplayDialog extends StatelessWidget {
  final String memberId;
  final String memberName;
  const QrDisplayDialog({
    super.key,
    required this.memberId,
    required this.memberName,
  });

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
          border: Border.all(
            color: const Color(0xFF00F0FF).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F0FF).withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ÜYE GİRİŞ BİLETİ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              memberName.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(color: Colors.white12, height: 24),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 180,
                height: 180,
                child: QrImageView(
                  data: memberId,
                  version: QrVersions.auto,
                  gapless: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ID: $memberId',
              style: const TextStyle(
                color: Color(0xFF627E82),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'KAPAT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            .collection('members')
            .doc(widget.docId)
            .update(payload);
      } else {
        payload['status'] = 'Active';
        payload['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance.collection('members').add(payload);
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
