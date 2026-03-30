import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart'; // Student modelinin olduğu yer
import 'package:my_app/ptpage/attandance/student_attance.dart'; // Senin yoklama sayfan
import 'package:my_app/ptpage/notifications/student_natifications.dart';
import 'package:my_app/ptpage/student_info.dart';
import 'package:my_app/ptpage/student_pay.dart/student_pay.dart';
import 'package:my_app/main.dart'; // RoleSelectPage için

class UserInterface extends StatelessWidget {
  // Sayfa açılırken hangi öğrenci olduğunu bilmek zorunda
  final Student student;

  const UserInterface({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sporcu ve Veli Paneli"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.backspace),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RoleSelectPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔵 ÜST BÜYÜK KART - ÖĞRENCİ ÖZETİ
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ID: ${student.studentId}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Branş ID: ${student.sportId}"),
                          Text("Yaş: ${student.age}"),
                          const Text("Durum: Aktif"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🧩 MENÜ KARTLARI
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                // 1. DERS YOKLAMA
                menuCard(context, "Ders Yoklama", Icons.check_circle, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentYoklamaPage(studentId: student.studentId),
                    ),
                  );
                }),

                // 2. AYLIK AİDAT
                menuCard(context, "Aylık Aidat", Icons.payments, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  AidatPage()),
                  );
                }),

                // 3. DUYURULAR
                menuCard(context, "Duyurular", Icons.campaign, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  DuyurularPage()),
                  );
                }),

                // 4. KİŞİSEL BİLGİLER
                menuCard(context, "Kişisel Bilgiler", Icons.person, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  KisiselBilgilerPage()),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Ortak Kart Tasarımı
  Widget menuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}