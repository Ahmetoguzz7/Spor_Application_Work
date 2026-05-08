import 'package:flutter/material.dart';
import 'package:my_app/main.dart';
import 'package:my_app/ptpage/user_login_page.dart/student_login.dart';
import 'package:my_app/ptpage/user_sign_up.dart/student_signup.dart'
    hide StudentLogin; // LoginPage burada tanımlı olmalı
// SignUpPage burada tanımlı olmalı

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Geri butonu tasarımı
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ), // Daha modern bir ikon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RoleSelectPage()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Arka Plan Görseli
          Positioned.fill(
            child: Image.asset(
              "assets/images/6272.jpg", // Önceki sayfalarında kullandığın görsel ismiyle güncelledim
              fit: BoxFit.cover,
            ),
          ),
          // Karartma Katmanı (Okunabilirliği artırır)
          Container(color: Colors.black.withOpacity(0.65)),

          // İçerik Alanı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animasyonu için Hero
                const Hero(
                  tag: "logo",
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 110, // Biraz büyütüldü
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "SPOR PANELİ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontFamily:
                        'Roboto', // Eğer özel fontun varsa buraya ekleyebilirsin
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Geleceğin sporcuları burada yetişiyor.\nHemen aramıza katıl.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 17,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 70),

                // GİRİŞ YAP BUTONU (Dolu Buton)
                _buildButton(
                  context: context,
                  text: "Giriş Yap",
                  isFilled: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentLogin(),
                    ), // Const eklendi
                  ),
                ),

                const SizedBox(height: 20),

                // KAYIT OL BUTONU (Çerçeveli Buton)
                _buildButton(
                  context: context,
                  text: "Kayıt Ol",
                  isFilled: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignUpPage(),
                    ), // Const eklendi
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Optimize Edilmiş Buton Tasarımı
  Widget _buildButton({
    required BuildContext context,
    required String text,
    required bool isFilled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58, // Biraz daha dolgun butonlar
      child: isFilled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onTap,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onTap,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
