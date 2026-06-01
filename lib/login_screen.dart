import 'package:flutter/material.dart';
import 'main.dart'; // MainLayout'a erişebilmek için
import 'app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller'ları final olarak tanımlıyoruz
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false; // "Beni Hatırla" durumu

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('saved_email') ?? '';
      if (_emailController.text.isNotEmpty) _rememberMe = true;
    });
  }

  @override
  void dispose() {
    // Hafıza sızıntısını ve "used after being disposed" hatasını kökten önlüyoruz
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint('Giriş denemesi -> Email: $email, Şifre: $password');

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen E-posta ve Şifrenizi girin.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    try {
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', _emailController.text);
      }

      // Gerçek Firebase Giriş İşlemi (Bypass Kaldırıldı)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Not: Yönlendirme yapmıyoruz çünkü main.dart'taki StreamBuilder girişi algılayıp otomatik MainLayout'a atacak.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Giriş başarısız: ${e.message ?? "Bilgilerinizi kontrol edin."}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌟 Taşma (RenderFlex overflow) hatasını önlemek için SingleChildScrollView şart!
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ), // Web'de çok yayılmasın
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) =>
                              setState(() => _rememberMe = val!),
                          activeColor: AppColors.neonGreen,
                        ),
                        Text(
                          "Beni Hatırla",
                          style: TextStyle(color: AppColors.textMuted(context)),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_emailController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Lütfen önce E-posta adresini girin.",
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: _emailController.text.trim(),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Şifre sıfırlama bağlantısı e-postanıza gönderildi.",
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Hata: ${e.toString()}")),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Şifremi Unuttum",
                        style: TextStyle(color: AppColors.neonCyan),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'GİRİŞ YAP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Hesabınız yok mu? ",
                      style: TextStyle(color: AppColors.textMuted(context)),
                      children: const [
                        TextSpan(
                          text: "Hemen Kayıt Olun",
                          style: TextStyle(
                            color: AppColors.neonGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
