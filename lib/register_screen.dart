import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _salonNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _salonNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final salonAdi = _salonNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (salonAdi.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen tüm alanları doldurun.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (password != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifreler eşleşmiyor.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Kayıt olan kullanıcıya özel boş bir salon dökümanı oluştur:
      await FirebaseFirestore.instance.collection('salonlar').doc(uid).set({
        'salonAdi': salonAdi,
        'olusturulmaTarihi': DateTime.now(),
        'aktifUyeSayisi': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Kayıt başarılı! Yönlendiriliyorsunuz...'),
            backgroundColor: Color(0xFF00FF66),
          ),
        );
        Navigator.pop(
          context,
        ); // İşlem başarılıysa giriş ekranına (veya otomatik olarak ana sayfaya) dön
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 250,
                  child: Image.asset(
                    'assets/images/turnigym.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _salonNameController,
                  style: TextStyle(color: AppColors.text(context)),
                  decoration: InputDecoration(
                    labelText: 'Marka İsminiz',
                    hintText: 'Örn: FitnessX, IronCore, PeakPerformance',
                    labelStyle: TextStyle(color: AppColors.textMuted(context)),
                    prefixIcon: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.neonCyan,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppColors.text(context)),
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    labelStyle: TextStyle(color: AppColors.textMuted(context)),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.neonCyan,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: AppColors.text(context)),
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    labelStyle: TextStyle(color: AppColors.textMuted(context)),
                    prefixIcon: const Icon(
                      Icons.lock_open_outlined,
                      color: AppColors.neonCyan,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: AppColors.text(context)),
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    labelStyle: TextStyle(color: AppColors.textMuted(context)),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.neonCyan,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'KAYIT OL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Geri Dön",
                    style: TextStyle(color: AppColors.textMuted(context)),
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
