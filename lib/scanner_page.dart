import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TURNIGYM GİRİŞ KAPISI")),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? memberUid = barcodes.first.rawValue;
            if (memberUid != null) {
              _processEntry(context, memberUid);
            }
          }
        },
      ),
    );
  }

  Future<void> _processEntry(BuildContext context, String memberUid) async {
    final salonId = FirebaseAuth.instance.currentUser!.uid;
    final memberRef = FirebaseFirestore.instance
        .collection('salonlar')
        .doc(salonId)
        .collection('uyeler')
        .doc(memberUid);

    final snapshot = await memberRef.get();

    if (snapshot.exists && (snapshot.data()?['credit'] ?? 0) > 0) {
      // 🌟 GİRİŞ ONAYLANDI: Krediyi 1 düşür
      await memberRef.update({'credit': FieldValue.increment(-1)});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Giriş Onaylandı! İyi Antrenmanlar."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // ❌ GİRİŞ REDDEDİLDİ: Yetersiz kredi veya geçersiz üye
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Giriş Reddedildi! Kredi yetersiz."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
