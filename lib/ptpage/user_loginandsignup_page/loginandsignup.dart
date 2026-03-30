/*import 'package:flutter/material.dart';
import 'package:my_app/main.dart';
import 'package:my_app/ptpage/user_login_page.dart/student_login.dart';
import 'package:my_app/ptpage/user_sign_up.dart/student_signup.dart';


class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş / Kayıt"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
           Navigator.pushReplacement(context, 
           MaterialPageRoute(builder:   (_) => const RoleSelectPage()));
          },
        ),
      ),
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// DARK LAYER
          Container(color: Colors.black.withOpacity(0.5)),

          /// CONTENT
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Hero(
                    tag: "logo",
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 90,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Hoşgeldin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 60),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text("Giriş Yap"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text("Kayıt Ol"),
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
}
*/
import 'package:flutter/material.dart';
import 'package:my_app/main.dart';
import 'package:my_app/ptpage/user_login_page.dart/student_login.dart';
import 'package:my_app/ptpage/user_sign_up.dart/student_signup.dart'; // Dosya ismin buysa kalsın

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Arka planın AppBar altına girmesi için
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectPage()));
          },
        ),
      ),
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Karartma Katmanı
          Container(color: Colors.black.withOpacity(0.6)),

          // İçerik
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Hero(
                  tag: "logo",
                  child: Icon(Icons.fitness_center, color: Colors.white, size: 100),
                ),
                const SizedBox(height: 20),
                const Text(
                  "SPOR PANELİ",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(height: 10),
                Text(
                  "Geleceğin sporcuları burada yetişiyor.",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // GİRİŞ BUTONU
                _buildButton(
                  context: context,
                  text: "Giriş Yap",
                  isFilled: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  LoginPage())),
                ),

                const SizedBox(height: 20),

                // KAYIT BUTONU
                _buildButton(
                  context: context,
                  text: "Kayıt Ol",
                  isFilled: false,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  SignUpPage())), // Burayı SignUpPage yaptım
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Buton Tasarımı Yardımcı Widget
  Widget _buildButton({required BuildContext context, required String text, required bool isFilled, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isFilled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: onTap,
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: onTap,
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
    );
  }
}