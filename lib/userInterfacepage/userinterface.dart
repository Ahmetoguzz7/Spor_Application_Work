import 'package:flutter/material.dart';
import 'package:my_app/main.dart';
import 'package:my_app/userInterfacepage/attendance.dart';
import 'package:my_app/userInterfacepage/notifications/pt_natifications.dart';
import 'package:my_app/userInterfacepage/paypage/paygrup.dart';

class PersonalTrainer extends StatelessWidget {
  const PersonalTrainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Koç - Antrenör Paneli"),
        centerTitle: true,
        leading: IconButton(
      icon: Icon(Icons.backspace),
      onPressed: (){
        Navigator.pushReplacement(context,
         MaterialPageRoute(builder: (_) => RoleSelectPage()));
      },
    ),
 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔵 ÜST BÜYÜK KART
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
                      backgroundImage: NetworkImage(
                        "https://depositphotos.com/vector/male-avatar-profile-picture-use-for-social-website-vector-51405259.html",
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Ahmet oğuz Mertoğlu",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text("Branş: Futbol"),
                          Text(""),
                          Text(""),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🧩 ALT KÜÇÜK KARTLAR
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                menuCard(context, "Yoklama", Icons.check_circle, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GrupListesiSayfasi()));
                }),
                menuCard(context, "Aidat", Icons.payments, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GrupSecimSayfasi()));
                }),
                menuCard(context, "Duyurular", Icons.campaign, () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => DuyurularPage()));
                }),
                menuCard(context, "Kişisel Bilgiler", Icons.person, () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => AyarlarPage()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
              Icon(icon, size: 36),
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