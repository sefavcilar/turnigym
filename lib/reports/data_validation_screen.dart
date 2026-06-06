import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';

class DataValidationScreen extends StatefulWidget {
  const DataValidationScreen({super.key});

  @override
  State<DataValidationScreen> createState() => _DataValidationScreenState();
}

class _DataValidationScreenState extends State<DataValidationScreen>
    with SingleTickerProviderStateMixin {
  bool _isSynced = false;
  bool _isLoading = true;
  int _firebaseCount = 0;
  int _calendarCount = 0;
  // TODO: Yetkilendirme sonrası Hakan Hoca'nın paylaştığı gerçek Takvim ID'si buraya yazılmalı
  String _calendarId = 'primary';

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Yanıp sönme hızı
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Sayfa açıldığında otomatik olarak verileri çekecek fonksiyonumuz:
    updateDashboardStats();
  }

  Future<void> _validateData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Firebase (TurniGym) Verisini Al
      final salonId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_salon';
      final logsSnapshot = await FirebaseFirestore.instance
          .collection('salonlar')
          .doc(salonId)
          .collection('pass_logs')
          .get();
      _firebaseCount = logsSnapshot.docs.length;

      // 2. Google Takvim Verisini Al
      final calendarService = CalendarService();
      final events = await calendarService.getEvents(_calendarId);
      _calendarCount = events.length;

      setState(() {
        _isSynced = (_firebaseCount == _calendarCount);
      });

      if (!_isSynced) {
        _animationController.repeat(
          reverse: true,
        ); // Sürekli yanıp sönmeyi başlat
      } else {
        _animationController.stop();
        _animationController.value = 1.0;
      }
    } catch (e) {
      debugPrint("Veri doğrulama hatası: $e");
      setState(() {
        _isSynced = false;
        _firebaseCount = 0;
        _calendarCount = 0;
      });
      _animationController.repeat(reverse: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Firebase'den tüm üyeleri çekip sayısını test ediyoruz
  Future<void> updateDashboardStats() async {
    print("Firebase'den veriler çekiliyor...");
    var snapshot = await FirebaseFirestore.instance.collection('members').get();

    print(
      "Firebase'den gelen belge sayısı: ${snapshot.size}",
    ); // Veri geldi mi?

    setState(() {
      // Kodunuzdaki "toplamAktifUye" karşılığı _firebaseCount olduğu için onu kullanıyoruz
      _firebaseCount = snapshot.size;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgCard => _isDark ? const Color(0xFF04171A) : Colors.white;
  Color get _bgInner =>
      _isDark ? const Color(0xFF0B2D33) : const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _bgCard, // Panelin ana kart rengiyle aynı
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Çok uzun olabilen başlığı yatay kaydırılabilir yaptık
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    "SİSTEM & TABLO DOĞRULAMA (TURNIGYM vs GOOGLE TAKVİM)",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Test butonunu eklediğin kısım
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Takvimi Test Et"),
                  onPressed: () async {
                    // Yeni oluşturduğumuz fonksiyonu çağırıyoruz
                    await updateDashboardStats();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Durum: ${_isSynced ? "Senkronize" : "Farklı"} | Sistem: $_firebaseCount, Takvim: $_calendarCount",
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildSummaryCard(), // Üst özet kartı
                const SizedBox(height: 20),
                Expanded(
                  child: _buildComparisonTable(),
                ), // Detaylı karşılaştırma tablosu
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bgInner, // Dashboard iç kart rengi
        border: Border.all(
          color: _isSynced ? const Color(0xFF00FF66) : Colors.redAccent,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              "Bugünkü Durum:",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(
              width: 24,
            ), // mainAxisAlignment.spaceBetween yerine sabit boşluk
            _isSynced
                ? const Text(
                    "SENKRONİZE ✅",
                    style: TextStyle(
                      color: Color(0xFF00FF66),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : FadeTransition(
                    opacity: _opacityAnimation,
                    child: const Text(
                      "UYUMSUZLUK VAR ⚠️",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: _bgInner,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
      ),
      child: ListView(
        children: [
          _buildTableRow(
            "Kayıt Türü",
            "Sistem (TurniGym)",
            "Google Takvim",
            "Durum",
            isHeader: true,
            index: 0,
          ),
          const Divider(color: Color(0xFFFF6B00), height: 1),
          _buildTableRow(
            "Toplam Kayıt",
            "$_firebaseCount",
            "$_calendarCount",
            _isSynced ? "Senkronize" : "Hatalı",
            isError: !_isSynced,
            index: 1,
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildTableRow(
            "Hatalı / Farklı",
            "${(_firebaseCount - _calendarCount).abs()}",
            "0",
            _isSynced ? "Yok" : "Fark Var",
            isError: !_isSynced,
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String a,
    String b,
    String c,
    String d, {
    bool isHeader = false,
    bool isError = false,
    int index = 0,
  }) {
    return Container(
      color: index % 2 == 0
          ? Colors.transparent
          : Colors.black.withOpacity(0.05),
      padding: const EdgeInsets.all(16.0),
      // Tabloyu SingleChildScrollView ile sarıp Expanded'ları sabit SizedBox'lara çeviriyoruz
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: Text(
                a,
                style: TextStyle(
                  color: isHeader ? const Color(0xFFFF6B00) : Colors.black87,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                b,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: Text(
                c,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: Text(
                d,
                style: TextStyle(
                  color: isHeader
                      ? Colors.black
                      : (isError ? Colors.redAccent : const Color(0xFF00FF66)),
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Geçici çözüm: Sınıfı doğrudan bu dosyanın içine taşıdık
class CalendarService {
  Future<List<calendar.Event>> getEvents(String calendarId) async {
    try {
      // 1. JSON dosyasını güvenli bir şekilde yükle
      final jsonString = await rootBundle
          .loadString('assets/service-account.json')
          .catchError((e) {
            debugPrint("HATA: JSON dosyası bulunamadı!");
            return "{}";
          });

      if (jsonString == "{}") return [];

      final accountCredentials = ServiceAccountCredentials.fromJson(jsonString);

      // 2. Kimlik Doğrulaması ve Google Calendar API Bağlantısı
      var scopes = [calendar.CalendarApi.calendarReadonlyScope];
      var client = await clientViaServiceAccount(accountCredentials, scopes);
      var calendarApi = calendar.CalendarApi(client);

      // 3. Sadece bugünün etkinliklerini çek (00:00 ile 23:59 arası)
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      var events = await calendarApi.events.list(
        calendarId,
        timeMin: startOfDay.toUtc(),
        timeMax: endOfDay.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (e) {
      debugPrint("Takvim servisi hatası: $e");
      return [];
    }
  }
}
