import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
          Container(
            width: 260,
            color: const Color(0xFF02090B),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/turnigym.png',
                    width: 180,
                    fit: BoxFit.contain,
                    color: const Color(0xFF02090B),
                    colorBlendMode: BlendMode.dstATop,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuTitles.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
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
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                _menuIcons[index],
                                color: isSelected
                                    ? const Color(0xFF00FF66)
                                    : const Color(0xFF627E82),
                                size: 18,
                              ),
                              title: Text(
                                _menuTitles[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF627E82),
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
                // 💡 İşte o hatalı Padding/Style ilişkisi burada jilet gibi ayrıştırıldı:
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'TURNIGYM v1.0.0 Enterprise',
                    style: TextStyle(
                      color: Color(0xFF13363B),
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
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

                  // TABLO VE SAĞ KARTLAR
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TABLO TARAFI
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔍 ARAMA BARI
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF04171A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00F0FF,
                                    ).withOpacity(0.3),
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
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: (value) {
                                            setState(() {
                                              _searchQuery = value
                                                  .trim()
                                                  .toLowerCase();
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
                                            contentPadding: EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                          ),
                                        ),
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
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 🔄 TABLO ALANI
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
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Color(
                                                          0xFF00F0FF,
                                                        ),
                                                      ),
                                                );
                                              }

                                              final docs =
                                                  snapshot.data?.docs ?? [];

                                              var filteredDocs = docs.where((
                                                doc,
                                              ) {
                                                final data =
                                                    doc.data()
                                                        as Map<String, dynamic>;
                                                final name =
                                                    (data['name'] ?? '')
                                                        .toString()
                                                        .toLowerCase();
                                                return name.contains(
                                                  _searchQuery,
                                                );
                                              }).toList();

                                              filteredDocs.sort((a, b) {
                                                final dataA =
                                                    a.data()
                                                        as Map<String, dynamic>;
                                                final dataB =
                                                    b.data()
                                                        as Map<String, dynamic>;
                                                final timeA =
                                                    dataA['timestamp'] ?? 0;
                                                final timeB =
                                                    dataB['timestamp'] ?? 0;
                                                return timeB.compareTo(timeA);
                                              });

                                              if (filteredDocs.isEmpty) {
                                                return const Center(
                                                  child: Text(
                                                    'Kayıtlı üye bulunamadı.',
                                                    style: TextStyle(
                                                      color: Color(0xFF627E82),
                                                    ),
                                                  ),
                                                );
                                              }

                                              return ListView.builder(
                                                itemCount: filteredDocs.length,
                                                itemBuilder: (context, index) {
                                                  final data =
                                                      filteredDocs[index].data()
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >;
                                                  final docId =
                                                      filteredDocs[index].id;

                                                  return _buildCyberTableRow(
                                                    context,
                                                    docId,
                                                    data['name'] ??
                                                        'Bilinmeyen Üye',
                                                    data['phone'] ?? '-',
                                                    (data['credit'] ?? 0) > 0
                                                        ? const Color(
                                                            0xFF00FF66,
                                                          )
                                                        : const Color(
                                                            0xFFFF3B30,
                                                          ),
                                                    data['credit'] ?? 0,
                                                    data['company'] ??
                                                        'TurniGym',
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

                        // SAĞ KONTROL PANELİ
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
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00F0FF,
                                      ).withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                      offset: const Offset(-2, 0),
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF6B00,
                                      ).withOpacity(0.4),
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
                                      builder: (context) =>
                                          const AddMemberDialog(),
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
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
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
                                      color: const Color(
                                        0xFF00F0FF,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                                      const Divider(
                                        color: Colors.white12,
                                        height: 24,
                                      ),
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
                                              .orderBy(
                                                'timestamp',
                                                descending: true,
                                              )
                                              .limit(10)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Center(
                                                child: Text(
                                                  'Log hatası.',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              );
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Color(0xFF00F0FF),
                                                    ),
                                              );
                                            }

                                            final logDocs =
                                                snapshot.data?.docs ?? [];

                                            if (logDocs.isEmpty) {
                                              return const Center(
                                                child: Text(
                                                  'Henüz geçiş kaydı yok.',
                                                  style: TextStyle(
                                                    color: Color(0xFF627E82),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }

                                            return ListView.builder(
                                              itemCount: logDocs.length,
                                              itemBuilder: (context, index) {
                                                final logData =
                                                    logDocs[index].data()
                                                        as Map<String, dynamic>;

                                                final name =
                                                    logData['memberName'] ??
                                                    'Bilinmeyen Üye';
                                                final date =
                                                    logData['date'] ?? '-';
                                                final time =
                                                    logData['time'] ?? '-';
                                                final status =
                                                    logData['status'] ??
                                                    'Geçiş İzni';

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              name,
                                                              style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                            Text(
                                                              '$date  $time',
                                                              style:
                                                                  const TextStyle(
                                                                    color: Color(
                                                                      0xFF627E82,
                                                                    ),
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        status,
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF00FF66,
                                                          ),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
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
    BuildContext context,
    String docId,
    String name,
    String phone,
    Color fingerColor,
    int credit,
    String company,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF02171A))),
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
    );
  }
}

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

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _creditCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _creditCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final creditText = _creditCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || creditText.isEmpty) return;
    final credit = int.tryParse(creditText) ?? 0;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('members').add({
        'name': name,
        'phone': phone,
        'credit': credit,
        'company': 'TurniGym',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
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
          border: Border.all(
            color: const Color(0xFF00F0FF).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YENİ ÜYE EKLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            _buildField('İsim Soyisim', Icons.person_outline, _nameCtrl),
            const SizedBox(height: 12),
            _buildField('Telefon', Icons.phone_outlined, _phoneCtrl),
            const SizedBox(height: 12),
            _buildField(
              'Kredi',
              Icons.credit_score_outlined,
              _creditCtrl,
              isNum: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Iptal',
                    style: TextStyle(color: Color(0xFF627E82)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF66),
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
                      : const Text('KAYDET'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    bool isNum = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF627E82), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00F0FF), size: 18),
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
        filled: true,
        fillColor: const Color(0xFF02090B),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
