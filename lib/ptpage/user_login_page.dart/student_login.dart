import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/main.dart';
import 'package:my_app/parent/parent_page.dart';
import 'package:my_app/ptpage/studenonboarda/student_onboarding.dart';
import 'package:my_app/ptpage/student_interface.dart';
import 'package:my_app/ptpage/user_sign_up.dart/student_signup.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen(Users loggedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final String role = loggedUser.role.toLowerCase();

    if (!mounted) return;

    if (role == 'parent' || role == 'veli') {
      await prefs.setBool('onboarding_done_${loggedUser.app}', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VeliAnaSayfa(veli: loggedUser)),
      );
    } else if (role == 'student' || role == 'öğrenci') {
      bool isCompleted =
          prefs.getBool('onboarding_done_${loggedUser.app}') ?? false;

      if (isCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserInterface(user: loggedUser)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserInterface(user: loggedUser)),
        );
      }
    } else if (role == 'coach' || role == 'antrenör') {
      await prefs.setBool('onboarding_done_${loggedUser.app}', true);

      final allCoaches = await GoogleSheetService.getCoaches();
      final allSports = await GoogleSheetService.getSports();

      Coach existingCoach = allCoaches.firstWhere(
        (c) => c.user_id == loggedUser.app,
        orElse: () => Coach(
          coach_id: "",
          user_id: loggedUser.app,
          branches_id: loggedUser.branches_id,
          sports_id: "1",
          bio: "",
          certificate_info: "",
          monthly_salary: "0",
          hired_at: DateTime.now().toIso8601String(),
        ),
      );

      Sports sport = allSports.isNotEmpty
          ? allSports.first
          : Sports(sports_id: "1", name: "Genel Branş", description: "");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PersonalTrainer(
            users: loggedUser,
            sport: sport,
            coachData: existingCoach,
            tumGruplar: [],
            tumKullanicilar: [],
            tumOdemeler: [],
          ),
        ),
      );
    } else {
      await prefs.setBool('onboarding_done_${loggedUser.app}', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserInterface(user: loggedUser)),
      );
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Users? loggedUser = await GoogleSheetService.login(email, password);

      print("Giriş sonucu: ${loggedUser != null ? loggedUser.email : "null"}");

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (loggedUser != null) {
        await _navigateToNextScreen(loggedUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hatalı email veya şifre!")),
        );
      }
    } catch (e) {
      print("Giriş hatası: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Giriş hatası: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/6272.jpg", fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.55)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(
                          Icons.sports_basketball,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Spor Akademi",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Sisteme erişmek için giriş yapınız",
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        _emailController,
                        "Email / Telefon",
                        Icons.email_outlined,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _passwordController,
                        "Şifre",
                        Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                      _buildLoginButton(),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Hesabın yok mu? "),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => SignUpPage()),
                              );
                            },
                            child: const Text(
                              "Kayıt Ol",
                              style: TextStyle(color: Colors.orangeAccent),
                            ),
                          ),
                        ],
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.orangeAccent),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Giriş Yap",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
