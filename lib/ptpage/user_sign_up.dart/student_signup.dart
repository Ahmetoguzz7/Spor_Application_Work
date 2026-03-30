/*import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/ptpage/competeprofile/completeprofile.dart';
import 'package:my_app/ptpage/student_interface.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';
import 'package:my_app/ptpage/user_loginandsignup_page/loginandsignup.dart'; // AuthSelectionPage yolu


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  void _handleLogin() async {
    setState(() => isLoading = true);

    // Servis üzerinden giriş yapmayı dene
    final studentData = await GoogleSheetService.login(
      emailController.text, 
      passwordController.text
      
    );

    setState(() => isLoading = false);

    if (studentData != null) {
      // Başarılı: JSON'u Student nesnesine çevir ve içeri yolla
      final student = Student.fromJson(studentData);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserInterface(student: student)),
      );
    } else {
      // Başarısız: Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email veya Şifre Hatalı!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Yap"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) =>  CompleteProfilePage(userData: {},))
          ),
        ),
      ),
      body: Stack(
        children: [
          // Arka Plan Görseli
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          FadeTransition(
            opacity: fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Hero(
                        tag: "logo",
                        child: Icon(Icons.fitness_center, size: 70),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Hoş Geldiniz",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: "Email",
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Şifre",
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text("Giriş Yap"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/ptpage/competeprofile/completeprofile.dart';
import 'package:my_app/ptpage/student_interface.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';
import 'package:my_app/ptpage/user_loginandsignup_page/loginandsignup.dart'; // AuthSelectionPage yolu

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  void _handleLogin() async {
    // Boş alan kontrolü
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() => isLoading = true);

    // 1. Servis üzerinden giriş yapmayı dene (Ham veriyi al)
    final rawData = await GoogleSheetService.login(
      emailController.text.trim(), 
      passwordController.text.trim()
    );

    setState(() => isLoading = false);

    if (rawData != null) {
      // --- AKILLI YÖNLENDİRME BAŞLADI ---

      // 2. Branş bilgisi eksik mi kontrol et (Eksikse Profil Tamamlama'ya)
      if (rawData['branch_id'] == null || rawData['branch_id'].toString().trim().isEmpty) {
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteProfilePage(userData: rawData),
            ),
          );
        }
      } 
      // 3. Branş bilgisi tam ise ana sayfaya
      else {
        final student = Student.fromJson(rawData);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserInterface(student: student),
            ),
          );
        }
      }
    } else {
      // Başarısız: Hata mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email veya Şifre Hatalı!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // İçeriğin klavye açıldığında yukarı kayması için
      resizeToAvoidBottomInset: true, 
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Giriş Yap", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Geri butonu AuthSelectionPage sayfasına dönmeli
          onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AuthSelectionPage())
          ),
        ),
      ),
      body: Stack(
        children: [
          // Arka Plan Görseli
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          FadeTransition(
            opacity: fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                    ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Hero(
                        tag: "logo",
                        child: Icon(Icons.fitness_center, size: 80, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Tekrar Hoş Geldin!",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: "Email",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Şifre",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}