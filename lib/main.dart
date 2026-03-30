import 'package:flutter/material.dart';
import 'package:my_app/ptpage/student_interface.dart';
import 'package:my_app/ptpage/user_loginandsignup_page/loginandsignup.dart';
import 'package:my_app/userInterfacepage/pt_login_page.dart/pt_signup.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RoleSelectPage(),
    );
  }
}

// 👤 ROL SEÇME SAYFASI
class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Türünü Seç"),
        centerTitle: true,
       

      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2, // alt alta 3 büyük kart
          mainAxisSpacing: 16,
          children: [
            roleCard(
              context,
              title: "Kullanıcı Girişi",
              subtitle: "Sporcular",
              icon: Icons.person,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthSelectionPage()),
                );
              },
            ),
            roleCard(
              context,
              title: "Koç Girişi",
              subtitle: "Antrenörler",
              icon: Icons.sports,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PtSignUp()),
                );
              },
            ),
            roleCard(
              context,
              title: "Yönetici Girişi",
              subtitle: "Yöneticiler",
              icon: Icons.admin_panel_settings,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalTrainer()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget roleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap, 
    required String subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}