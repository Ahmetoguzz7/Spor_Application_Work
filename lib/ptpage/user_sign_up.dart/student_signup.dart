import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/main.dart';
import 'package:my_app/parent/parent_page.dart';
import 'package:my_app/ptpage/studenonboarda/student_onboarding.dart';
import 'package:my_app/ptpage/student_interface.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  String selectedRole = 'student';
  String selectedBranchId = '1';
  bool isLoading = false;

  final List<Map<String, String>> branches = [
    {'id': '1', 'name': 'Kadıköy Şubesi'},
    {'id': '2', 'name': 'Beşiktaş Şubesi'},
    {'id': '3', 'name': 'Ataşehir Şubesi'},
  ];

  void _redirectAfterRegister(Users user) async {
    final role = user.role.toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    if (role == 'student' || role == 'öğrenci') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingPage(currentUser: user)),
      );
    } else if (role == 'parent' || role == 'veli') {
      await prefs.setBool('onboarding_done_${user.app}', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VeliAnaSayfa(veli: user)),
      );
    } else if (role == 'coach' || role == 'antrenör') {
      await prefs.setBool('onboarding_done_${user.app}', true);

      setState(() => isLoading = true);

      final allCoaches = await GoogleSheetService.getCoaches();
      final allSports = await GoogleSheetService.getSports();

      // Coach kaydı var mı kontrol et
      Coach? existingCoach;
      try {
        existingCoach = allCoaches.firstWhere(
          (c) => c.user_id == user.app,
          orElse: () => Coach(
            coach_id: '',
            user_id: '',
            branches_id: '',
            sports_id: '',
            bio: '',
            certificate_info: '',
            monthly_salary: '',
            hired_at: '',
          ),
        );
      } catch (e) {
        print("Coach kaydı kontrol hatası: $e");
      }

      // Eğer yoksa yeni coach kaydı oluştur
      Coach coachData;
      if (existingCoach != null) {
        coachData = existingCoach;
      } else {
        // Yeni coach kaydı oluştur
        coachData = Coach(
          coach_id: "",
          user_id: user.app,
          branches_id: user.branches_id,
          sports_id: "1",
          bio: "Hoş geldiniz! Lütfen profilinizi güncelleyin.",
          certificate_info: "Henüz sertifika girilmedi.",
          monthly_salary: "0",
          hired_at: DateTime.now().toIso8601String(),
        );
        await GoogleSheetService.registerCoach(coachData);

        // Yeni kaydedilen coach'un ID'sini al
        final updatedCoaches = await GoogleSheetService.getCoaches();
        final newCoach = updatedCoaches.firstWhere(
          (c) => c.user_id == user.app,
          orElse: () => coachData,
        );
        coachData = newCoach;
      }

      Sports sport = allSports.isNotEmpty
          ? allSports.first
          : Sports(sports_id: "1", name: "Genel Branş", description: "");

      setState(() => isLoading = false);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PersonalTrainer(
              users: user,
              sport: sport,
              coachData: coachData,
              tumGruplar: [],
              tumKullanicilar: [],
              tumOdemeler: [],
            ),
          ),
        );
      }
    } else {
      await prefs.setBool('onboarding_done_${user.app}', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserInterface(user: user)),
      );
    }
  }

  /*
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Users yeniKullanici = Users(
        app: "",
        branches_id: selectedBranchId,
        first_name: nameController.text.trim(),
        last_name: surnameController.text.trim(),
        email: emailController.text.trim().toLowerCase(),
        phone: phoneController.text.trim(),
        password_hash: passwordController.text.trim(),
        role: selectedRole,
        profile_photo_url: "",
        amount: "0",
        b_date: DateTime.now().toIso8601String().substring(0, 10),
        created_at: DateTime.now().toIso8601String(),
        last_login: "",
        is_active: "TRUE",
      );

      bool result = await GoogleSheetService.registerUser(yeniKullanici);

      setState(() => isLoading = false);

      if (result) {
        if (mounted) {
          // Kayıt başarılı, yönlendir
          _redirectAfterRegister(yeniKullanici);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Bu bilgilerle daha önce kayıt yapılmış veya bir hata oluştu!",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }
  */
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Map<String, dynamic> userInfo = {
        "app": "",
        "branches_id": selectedBranchId,
        "first_name": nameController.text.trim(),
        "last_name": surnameController.text.trim(),
        "email": emailController.text.trim().toLowerCase(),
        "phone": phoneController.text.trim(),
        "password_hash": passwordController.text.trim(),
        "role": selectedRole,
        "profile_photo_url": "",
        "amount": "0",
        "b_date": DateTime.now().toIso8601String().substring(0, 10),
        "created_at": DateTime.now().toIso8601String(),
        "last_login": "",
        "is_active": "TRUE",
      };

      Map<String, dynamic> allData = {"user_info": userInfo};

      // Eğer coach ise ekstra bilgiler
      if (selectedRole == 'coach') {
        allData["sports_id"] = "1";
        allData["bio"] = "";
        allData["certificate_info"] = "";
      }

      bool result = await GoogleSheetService.registerEverywhere(allData);

      setState(() => isLoading = false);

      if (result) {
        if (mounted) {
          // Kullanıcıyı bul ve yönlendir
          final users = await GoogleSheetService.getUsers();
          final newUser = users.firstWhere(
            (u) => u.email == userInfo['email'],
            orElse: () => throw Exception("Kullanıcı bulunamadı"),
          );
          _redirectAfterRegister(newUser);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kayıt başarısız!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hesap Oluştur"),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectPage()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 70,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 30),
              _inputField(nameController, "Ad", Icons.person),
              _inputField(surnameController, "Soyad", Icons.person_outline),
              _inputField(
                emailController,
                "E-posta",
                Icons.email,
                inputType: TextInputType.emailAddress,
              ),
              _inputField(
                passwordController,
                "Şifre",
                Icons.lock,
                isPassword: true,
              ),
              _inputField(
                phoneController,
                "Telefon No",
                Icons.phone,
                inputType: TextInputType.phone,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Şube Seçiniz",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _buildBranchDropdown(),
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  "Sistemdeki Rolünüz",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _buildRoleSelection(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          RadioListTile(
            title: const Text("Öğrenci / Sporcu"),
            subtitle: const Text("Gelişim takibi ve programlar için"),
            value: 'student',
            groupValue: selectedRole,
            onChanged: (val) => setState(() => selectedRole = val.toString()),
          ),
          const Divider(height: 1),
          RadioListTile(
            title: const Text("Veli"),
            subtitle: const Text("Sporcu ödemeleri ve yoklama takibi için"),
            value: 'parent',
            groupValue: selectedRole,
            onChanged: (val) => setState(() => selectedRole = val.toString()),
          ),
          const Divider(height: 1),
          RadioListTile(
            title: const Text("Antrenör / Koç"),
            subtitle: const Text("Sporcu yönetimi ve ders takibi için"),
            value: 'coach',
            groupValue: selectedRole,
            onChanged: (val) => setState(() => selectedRole = val.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedBranchId,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: branches
          .map((b) => DropdownMenuItem(value: b['id'], child: Text(b['name']!)))
          .toList(),
      onChanged: (val) => setState(() => selectedBranchId = val!),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: isLoading ? null : _handleRegister,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "KAYDI TAMAMLA VE GİRİş YAP",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (v) => v!.isEmpty ? "Lütfen bu alanı doldurun" : null,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
