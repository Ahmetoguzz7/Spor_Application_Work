import 'package:flutter/material.dart';
import 'package:my_app/datapage/fetch_data_page.dart'; // GoogleSheetService'in olduğu dosya yolu

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller'lar - Sheets'teki kolon isimleriyle uyumlu
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();

  String selectedRole = 'student'; // Varsayılan rol
  bool isLoading = false; // Yükleme durumu kontrolü

  // --- KAYIT İŞLEMİ ---
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // 1. İşlem başladı, butonda çark dönecek
      setState(() => isLoading = true);

      // Sheets kolon başlıklarıyla aynı Map yapısı
      Map<String, dynamic> allData = {
        "user_name": nameController.text.trim(),
        "user_sur_name": surnameController.text.trim(),
        "email": emailController.text.trim(),
        "password_hash": passwordController.text.trim(),
        "role": selectedRole,
        "phone": phoneController.text.trim(),
        "age": ageController.text.trim(),
        "created_at": DateTime.now().toString().substring(0, 19),
      };

      // 2. Google Sheets'e veriyi gönder (Apps Script'teki Master fonksiyonu çalışır)
      bool success = await GoogleSheetService.registerEverywhere(allData);

      if (success) {
        // 3. Başarılı mesajını göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Kayıt Başarıyla Sisteme İşlendi!"),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // 4. 2 saniye bekle ki kullanıcı kaydedildiğini ve çarkın döndüğünü görsün
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() => isLoading = false); // İşlem bitti
          Navigator.pop(context); // Login sayfasına geri dön
        }
      } else {
        // Hata durumu
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hata! Veri sisteme işlenemedi."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Sporcu Kaydı")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Hero(
                tag: "logo",
                child: Icon(Icons.fitness_center, size: 80, color: Colors.blue),
              ),
              const SizedBox(height: 20),
              
              _inputField(nameController, "Adınız", Icons.person),
              _inputField(surnameController, "Soyadınız", Icons.person_outline),
              _inputField(emailController, "E-posta", Icons.email),
              _inputField(passwordController, "Şifre", Icons.lock, isPassword: true),
              _inputField(phoneController, "Telefon No", Icons.phone, inputType: TextInputType.phone),
              _inputField(ageController, "Yaş", Icons.calendar_today, inputType: TextInputType.number),
              
              const SizedBox(height: 20),
              const Text("Kullanıcı Rolü Seçin:", style: TextStyle(fontWeight: FontWeight.bold)),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 'student',
                    groupValue: selectedRole,
                    onChanged: (val) => setState(() => selectedRole = val.toString()),
                  ),
                  const Text("Öğrenci"),
                  const SizedBox(width: 20),
                  Radio(
                    value: 'koc',
                    groupValue: selectedRole,
                    onChanged: (val) => setState(() => selectedRole = val.toString()),
                  ),
                  const Text("Koç"),
                ],
              ),

              const SizedBox(height: 40),

              // --- KAYIT BUTONU (ANIMASYONLU) ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  // Eğer işlem sürüyorsa butonu inaktif yapıyoruz
                  onPressed: isLoading ? null : _handleRegister,
                  child: isLoading 
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "KAYIT OL VE SİSTEME İŞLE",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ORTAK INPUT TASARIMI ---
  Widget _inputField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (v) => v!.isEmpty ? "Bu alan boş bırakılamaz" : null,
      ),
    );
  }
}