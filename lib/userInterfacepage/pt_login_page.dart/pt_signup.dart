/*
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';

class PtSignUp extends StatefulWidget {
  const PtSignUp({super.key});

  @override
  State<PtSignUp> createState() => _PtSignUpState();
}

class _PtSignUpState extends State<PtSignUp>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Düzenleme: GoogleSheetService.login zaten Users? nesnesi döndürüyor.
    final Users? loggedUser = await GoogleSheetService.login(email, password);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (loggedUser != null) {
      try {
        // Rol kontrolü
        final role = loggedUser.role.toLowerCase();
        if (role != 'coach' && role != 'antrenör') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bu panel sadece antrenörler içindir!"),
            ),
          );
          return;
        }

        // Coach ve Sport verilerini oluşturma
        // Not: Eğer Google Sheets'ten ek veriler gelmiyorsa, boş nesnelerle başlatıyoruz
        final coachDetails = Coach(
          userId: loggedUser.appId,
          branchId: loggedUser.branchId,
          sportId: "1", // Varsayılan veya API'den gelen değer
          coachId: "C-${loggedUser.appId}",
          bio: "",
          certificate: "",
          pay_monthly: "0",
          work_start_date: DateTime.now(),
        );

        final coachSport = Sports(
          sportId: '1',
          sportName: 'Branş Belirtilmedi',
          description: '',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PersonalTrainer(
              users: loggedUser,
              sport: coachSport,
              coachData: coachDetails,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Veri işleme hatası: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hatalı email veya şifre!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Antrenör Girişi",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/6272.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          FadeTransition(
            opacity: fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 70,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Antrenör Paneli",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: "E-mail Adresi",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: "Şifre",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "GİRİŞ YAP",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    controller.dispose();
    super.dispose();
  }
}
*/
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';

class PtSignUp extends StatefulWidget {
  const PtSignUp({super.key});

  @override
  State<PtSignUp> createState() => _PtSignUpState();
}

class _PtSignUpState extends State<PtSignUp>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() => isLoading = true);

    final Users? loggedUser = await GoogleSheetService.login(email, password);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (loggedUser != null) {
      try {
        final role = loggedUser.role.toLowerCase();
        if (role != 'coach' && role != 'antrenör') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bu panel sadece antrenörler içindir!"),
            ),
          );
          return;
        }

        final allCoaches = await GoogleSheetService.getCoaches();
        Coach? existingCoach;
        try {
          existingCoach = allCoaches.firstWhere(
            (c) => c.user_id == loggedUser.app,
            orElse: () => throw Exception("Coach bulunamadı"),
          );
        } catch (e) {
          print("Coach kaydı henüz yok: $e");
        }

        final coachDetails =
            existingCoach ??
            Coach(
              coach_id: "C-${loggedUser.app}",
              user_id: loggedUser.app,
              branches_id: loggedUser.branches_id,
              sports_id: "1",
              bio: "",
              certificate_info: "",
              monthly_salary: "0",
              hired_at: DateTime.now().toIso8601String(),
            );

        final allSports = await GoogleSheetService.getSports();
        final coachSport = allSports.isNotEmpty
            ? allSports.first
            : Sports(
                sports_id: "1",
                name: "Branş Belirtilmedi",
                description: "",
              );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PersonalTrainer(
              users: loggedUser,
              sport: coachSport,
              coachData: coachDetails,
              tumGruplar: [],
              tumKullanicilar: [],
              tumOdemeler: [],
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Veri işleme hatası: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hatalı email veya şifre!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Antrenör Girişi",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/6272.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          FadeTransition(
            opacity: fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 70,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Antrenör Paneli",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: "E-mail Adresi",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: "Şifre",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "GİRİŞ YAP",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    controller.dispose();
    super.dispose();
  }
}
