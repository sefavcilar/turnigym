import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurniGym VIP Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030E11),
        cardColor: const Color(0xFF04171A),
        primaryColor: const Color(0xFF00F0FF),
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: const Color(0xFFFF6B00),
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 1;

  final List<String> _menuTitles = [
    'Yönetim Paneli',
    'Üye Yönetimi',
    'Üye Listesi',
    'Üye Yönetimi',
    'Turniş Fannel',
    'İşlerr Logu',
  ];

  final List<IconData> _menuIcons = [
    Icons.home_outlined,
    Icons.group_outlined,
    Icons.person_search_outlined,
    Icons.tune_outlined,
    Icons.blur_circular_outlined,
    Icons.info_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ================= SOL SIDEBAR =================
          Container(
            width: 250,
            color: const Color(0xFF02090B),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Orijinal Logomuz
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const RadialGradient(
                        center: Alignment.center,
                        radius:
                            0.65, // Görselin merkezinden ne kadar uzağa net kalacağı
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ], // Siyah olan yerler net, transparan olan yerler bulanık/kayıp olur
                        stops: [
                          0.7,
                          1.0,
                        ], // Netliğin nerede başlayıp nerede biteceğini ayarlar
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/images/turnigym.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuTitles.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected
                                ? const Color(0xFF041E22)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00FF66)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00FF66,
                                      ).withOpacity(0.15),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
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
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              dense: true,
                              onTap: () =>
                                  setState(() => _selectedIndex = index),
                            ),
                          ),
                        ),
                      );
                    },
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
                              letterSpacing: 0.5,
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
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none,
                                  color: Color(0xFFFF3B30),
                                ),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
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
                    child: Row(
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
                                    color: const Color(
                                      0xFF00F0FF,
                                    ).withOpacity(0.3),
                                    width: 1,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF00F0FF,
                                            ).withOpacity(0.5),
                                          ),
                                        ),
                                        child: const TextField(
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.search,
                                              color: Color(0xFF00F0FF),
                                              size: 16,
                                            ),
                                            hintText: 'Arama',
                                            hintStyle: TextStyle(
                                              color: Color(0xFF627E82),
                                              fontSize: 12,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 38,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF00F0FF),
                                            Color(0xFF00A3FF),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Arama',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 38,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF02090B),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white10,
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          Text(
                                            'İssim/Telefon',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              const Text(
                                'Üye Listesi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF04171A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF00F0FF,
                                      ).withOpacity(0.15),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ListView(
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
                                                flex: 3,
                                                child: Text(
                                                  'İsim/Telefon',
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
                                                  'Fingerprint',
                                                  textAlign: TextAlign.center,
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
                                                  'Kredit',
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
                                                  'Üye',
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
                                        _buildCyberTableRow(
                                          'Ashün Hismez',
                                          '(0126) 925-33-33',
                                          const Color(0xFF00F0FF),
                                          15,
                                          'TurniGym',
                                        ),
                                        _buildCyberTableRow(
                                          'Dekseli Ratser',
                                          '(0125) 926-85-33',
                                          const Color(0xFF00FF66),
                                          25,
                                          'TumiGym',
                                        ),
                                        _buildCyberTableRow(
                                          'Harmel İbayne',
                                          '(0125) 927-83-33',
                                          const Color(0xFF627E82),
                                          31,
                                          'Üyer Güm',
                                        ),
                                        _buildCyberTableRow(
                                          'Darbet Religin',
                                          '(0126) 927-85-88',
                                          const Color(0xFFFF3B30),
                                          0,
                                          'TurniGym',
                                        ),
                                        _buildCyberTableRow(
                                          'Mikael Yaymı',
                                          '(0125) 927-85-33',
                                          const Color(0xFF00FF66),
                                          0,
                                          'Üyer Güm',
                                        ),
                                        _buildCyberTableRow(
                                          'Miclaxl Batırn',
                                          '(0125) 927-85-39',
                                          const Color(0xFF00F0FF),
                                          0,
                                          'Üyer Güm',
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
                                    colors: [
                                      Color(0xFF00F0FF),
                                      Color(0xFFFF6B00),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF6B00,
                                      ).withOpacity(0.25),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(1.5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF04171A),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showAddMemberDialog(context),
                                      icon: const Icon(
                                        Icons.person_add_alt_1,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: const FittedBox(
                                        child: Text(
                                          'Yeni Üye Ekle',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // CİHAZ DURUMU KARTI
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Görselle bir bütün olması için tam siyah
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF00F0FF,
                                      ).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Cihaz Durumu',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.more_horiz,
                                              color: Color(0xFF627E82),
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      // 🟢 CİHAZ GÖRSELİ - Gölgeli efekt kaldırıldı, arka planla bütünleştirildi
                                      Center(
                                        child: Container(
                                          width: 140,
                                          height: 140,
                                          color: Colors.transparent,
                                          child: Image.asset(
                                            'assets/images/cihaz_durumu.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Center(
                                        child: Text(
                                          'Aktif',
                                          style: TextStyle(
                                            color: Color(0xFF00FF66),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      const Center(
                                        child: Text(
                                          'Geçiş İzni',
                                          style: TextStyle(
                                            color: Color(0xFF00FF66),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Turnike Geçiş Logu  Son Geçiş',
                                        style: TextStyle(
                                          color: Color(0xFF627E82),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.white12,
                                        height: 12,
                                        thickness: 0.5,
                                      ),
                                      Expanded(
                                        child: ListView(
                                          children: [
                                            _buildDeviceLog(
                                              '15.02.2023',
                                              '08:09:35',
                                              'Geçiş İzni',
                                            ),
                                            _buildDeviceLog(
                                              '01.02.2023',
                                              '0:39:05',
                                              'Geçiş İzni',
                                            ),
                                            _buildDeviceLog(
                                              '25.02.2023',
                                              'Geçiş İzni',
                                              'Aktif',
                                            ),
                                            _buildDeviceLog(
                                              '26.02.2023',
                                              'Aktif',
                                              'Aktif',
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberTableRow(
    String name,
    String phone,
    Color fingerColor,
    int credit,
    String company,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF02171A), width: 1)),
      ),
      child: Row(
        children: [
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
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
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
            flex: 2,
            child: Center(
              child: Icon(Icons.fingerprint, color: fingerColor, size: 22),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '$credit',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                company,
                style: const TextStyle(color: Color(0xFF627E82), fontSize: 13),
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
                    Icons.edit_outlined,
                    color: Color(0xFF00F0FF),
                    size: 16,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF3B30),
                    size: 16,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceLog(String date, String time, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$date  $time',
            style: const TextStyle(color: Color(0xFF627E82), fontSize: 11),
          ),
          Text(
            status,
            style: const TextStyle(color: Color(0xFF00FF66), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ================= YENİ ÜYE EKLE NEON DİYALOG MODAL =================
  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final creditController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            Future<void> saveMember() async {
              if (isLoading) return;

              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final creditText = creditController.text.trim();

              if (name.isEmpty || phone.isEmpty || creditText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final credit = int.tryParse(creditText);
              if (credit == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lütfen kredi miktarı için geçerli bir tamsayı girin.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() => isLoading = true);

              try {
                await FirebaseFirestore.instance.collection('members').add({
                  'name': name,
                  'phone': phone,
                  'credit': credit,
                  'company': 'TurniGym',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yeni üye başarıyla eklendi!'),
                      backgroundColor: Color(0xFF00FF66),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: Üye eklenemedi. ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (context.mounted) {
                  setState(() => isLoading = false);
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 450,
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
                      color: const Color(0xFF00F0FF).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YENİ ÜYE EKLE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildNeonTextField(
                      'İsim Soyisim',
                      Icons.person_outline,
                      nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildNeonTextField(
                      'Telefon Numarası',
                      Icons.phone_outlined,
                      phoneController,
                    ),
                    const SizedBox(height: 16),
                    _buildNeonTextField(
                      'Kredi Miktarı',
                      Icons.credit_score_outlined,
                      creditController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'İptal',
                            style: TextStyle(
                              color: Color(0xFF627E82),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FF66).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : saveMember,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF66),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'KAYDET',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      creditController.dispose();
    });
  }

  Widget _buildNeonTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF627E82)),
        prefixIcon: Icon(icon, color: const Color(0xFF00F0FF)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: const Color(0xFF00F0FF).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00F0FF), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF02090B),
      ),
    );
  }
}
