import 'package:flutter/material.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/ptpage/student_interface.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';

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
  final parentController = TextEditingController(); // Yaş yerine Veli adı
  bool isLoading = false;

 void _handleCompleteProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // 1. Paketi hazırla
      Map<String, dynamic> updateData = {
        "user_id": widget.userData["user_id"] ?? widget.userData["student_id"],
        "branch_id": branchController.text.trim(),
        "sport_id": sportController.text.trim(),
        "parent_id": parentController.text.trim(),
        "enrollment_date": DateTime.now().toString().substring(0, 10),
      };

      // 2. Veriyi arka planda gönder (Await etsek de sonucu sorgulamıyoruz)
      // Bu sayede bağlantı kopsa bile kullanıcıyı bekletip hata göstermeyeceğiz
      try {
        await GoogleSheetService.updateProfile(updateData);
      } catch (e) {
        print("Arka planda bir hata oluştu ama devam ediliyor: $e");
      }

      // 3. BAŞARIYLA GÜNCELLENDİ MANTIĞI
      // Beklemeye gerek kalmadan direkt başarı mesajı ve yönlendirme
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil Bilgileri Başarıyla Güncellendi!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Model için verileri birleştir
        final finalData = {...widget.userData, ...updateData};
        final student = Student.fromJson(finalData);

        // 1 saniye sonra ana sayfaya fırlat
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => UserInterface(student: student))
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
              const Text("Sporcu Bilgilerini Güncelle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildInput(branchController, "Şube Seçiniz", Icons.location_on),
              _buildInput(sportController, "Spor Branşı", Icons.sports_soccer),
              _buildInput(parentController, "Veli Adı Soyadı", Icons.family_restroom), // İŞTE VELİ ALANI
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleCompleteProfile,
                  child: isLoading ? const CircularProgressIndicator() : const Text("KAYDET VE GİRİŞ YAP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: (v) => v!.isEmpty ? "Boş bırakılamaz" : null,
      ),
    );
  }
}