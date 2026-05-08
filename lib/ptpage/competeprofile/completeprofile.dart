import 'package:flutter/material.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/datapage/data_page/data.dart'; // Users modelinin yolu
import 'package:my_app/ptpage/student_interface.dart';

class CompleteProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const CompleteProfilePage({super.key, required this.userData});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final branchController = TextEditingController();
  final sportController = TextEditingController();
  final phoneController =
      TextEditingController(); // Kayıtta eksikse burada tamamlayabilir
  bool isLoading = false;

  void _handleCompleteProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // 1. Sheets'e gönderilecek paket (Modeldeki keylerle aynı olmalı)
      Map<String, dynamic> updateData = {
        "email": widget.userData["email"], // Güncelleme için anahtar
        "branch_id": branchController.text.trim(),
        "role": widget.userData["role"] ?? "student",
        "is_active": "1", // Profil tamamlandığına göre artık aktif
        "last_login": DateTime.now().toString().substring(0, 19),
      };

      try {
        // Servis üzerinden Sheets'i güncelle
        await GoogleSheetService.updateProfile(widget.userData["email"]);
      } catch (e) {
        print("Profil güncelleme hatası: $e");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil Bilgileri Başarıyla Güncellendi!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // 2. Model için verileri birleştir
        // Mevcut verilerin üzerine yeni gelenleri yazıyoruz
        final Map<String, dynamic> finalMap = Map.from(widget.userData);
        finalMap.addAll(updateData);

        final loggedUser = Users.fromJson(finalMap);

        // 3. Yönlendirme
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => UserInterface(user: loggedUser),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profilini Tamamla")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.badge, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                "Hoş geldin ${widget.userData['first_name'] ?? ''}!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Devam etmek için lütfen eksik bilgileri doldur."),
              const SizedBox(height: 30),

              _buildInput(
                branchController,
                "Şube Kodu / Adı",
                Icons.location_on,
              ),
              _buildInput(
                sportController,
                "Spor Branşı (Örn: Basketbol)",
                Icons.sports_soccer,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleCompleteProfile,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "KAYDET VE GİRİŞ YAP",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
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
    branchController.dispose();
    sportController.dispose();
    super.dispose();
  }
}
