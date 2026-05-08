/*
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/userInterfacepage/paypage/paygrupdetail_student.dart';

class GrupSecimSayfasi extends StatelessWidget {
  final List<Group> tumGruplar;
  final List<Users> tumKullanicilar;
  final List<Payment> tumOdemeler;
  final Users currentUser; // Giriş yapan kullanıcıyı buraya ekledik

  GrupSecimSayfasi({
    super.key,
    required this.tumGruplar,
    required this.tumKullanicilar,
    required this.tumOdemeler,
    required this.currentUser, // Constructor'a eklendi
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aidat Grupları"), centerTitle: true),
      body: tumGruplar.isEmpty
          ? const Center(child: Text("Henüz grup tanımlanmamış."))
          : ListView.builder(
              itemCount: tumGruplar.length,
              itemBuilder: (context, index) {
                final seciliGrup = tumGruplar[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.group, color: Colors.white),
                    ),
                    title: Text(
                      seciliGrup.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Program: ${seciliGrup.schedule}\nKapasite: ${seciliGrup.capacity}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${seciliGrup.free_sports_monthly} TL",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // Yönlendirme artık AidatTakipSayfasi'nın yeni yapısına uygun
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AidatTakipSayfasi(
                            seciliGrup: seciliGrup,
                            tumKullanicilar: tumKullanicilar,
                            tumOdemeler: tumOdemeler,
                            grupAdi: seciliGrup.groupName,
                            user: currentUser, // Yeni eklenen zorunlu parametre
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/userInterfacepage/paypage/paygrupdetail_student.dart';

class GrupSecimSayfasi extends StatelessWidget {
  final List<Group> tumGruplar;
  final List<Users> tumKullanicilar;
  final List<Payment> tumOdemeler;
  final Users currentUser;

  const GrupSecimSayfasi({
    super.key,
    required this.tumGruplar,
    required this.tumKullanicilar,
    required this.tumOdemeler,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aidat Grupları"), centerTitle: true),
      body: tumGruplar.isEmpty
          ? const Center(child: Text("Henüz grup tanımlanmamış."))
          : ListView.builder(
              itemCount: tumGruplar.length,
              itemBuilder: (context, index) {
                final seciliGrup = tumGruplar[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.group, color: Colors.white),
                    ),
                    title: Text(
                      seciliGrup.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Program: ${seciliGrup.schedule}\nKapasite: ${seciliGrup.capacity}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${seciliGrup.monthly_fee} TL",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AidatTakipSayfasi(
                            seciliGrup: seciliGrup,
                            tumKullanicilar: tumKullanicilar,
                            tumOdemeler: tumOdemeler,
                            grupAdi: seciliGrup.name,
                            user: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
