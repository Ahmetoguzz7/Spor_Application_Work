/*
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';

class AidatTakipSayfasi extends StatefulWidget {
  final Group? seciliGrup; // group nesnesi (null gelebilir öğrenci panelinde)
  final List<Users> tumKullanicilar;
  final List<Payment> tumOdemeler;
  final String grupAdi;
  final Users user; // Giriş yapan kullanıcı

  const AidatTakipSayfasi({
    super.key,
    this.seciliGrup,
    required this.tumKullanicilar,
    required this.tumOdemeler,
    required this.grupAdi,
    required this.user,
  });

  @override
  _AidatTakipSayfasiState createState() => _AidatTakipSayfasiState();
}

class _AidatTakipSayfasiState extends State<AidatTakipSayfasi> {
  @override
  Widget build(BuildContext context) {
    // 1. Filtreleme: Eğer seciliGrup yoksa (öğrenci paneli), sadece giriş yapan öğrenciyi göster.
    // Varsa (koç paneli), o grubun ve şubenin öğrencilerini göster.
    final gosterilecekOgrenciler = widget.tumKullanicilar.where((u) {
      if (widget.seciliGrup == null) {
        return u.appId == widget.user.appId; // Sadece kendini gör
      }
      return u.role == "student" && u.branchId == widget.seciliGrup!.branchId;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.grupAdi), centerTitle: true),
      body: gosterilecekOgrenciler.isEmpty
          ? const Center(child: Text("Gösterilecek veri bulunamadı."))
          : ListView.builder(
              itemCount: gosterilecekOgrenciler.length,
              itemBuilder: (context, index) {
                final ogrenci = gosterilecekOgrenciler[index];

                // Ödeme kontrolü: payment modelindeki status'a göre
                bool odediMi = widget.tumOdemeler.any(
                  (p) =>
                      p.studentId == ogrenci.appId &&
                      (widget.seciliGrup == null ||
                          p.groupId == widget.seciliGrup!.groupId) &&
                      p.status.toLowerCase() == "paid",
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: odediMi
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        odediMi ? Icons.check : Icons.priority_high,
                        color: odediMi ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text("${ogrenci.first_name} ${ogrenci.last_name}"),
                    subtitle: Text(odediMi ? "Aidat Ödendi" : "Ödeme Bekliyor"),
                    trailing: Text(
                      odediMi ? "TAMAM" : "EKSİK",
                      style: TextStyle(
                        color: odediMi ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      if (!odediMi) {
                        _odemeIsleminiBaslat(ogrenci);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  void _odemeIsleminiBaslat(Users ogrenci) {
    // Burada ödeme detaylarını göstermek için bir dialog veya yeni sayfa açabilirsin
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ödeme Bilgisi"),
        content: Text(
          "${ogrenci.first_name} için ödeme kaydı oluşturulsun mu?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () {
              // Sheets'e kayıt atma mantığı buraya
              Navigator.pop(context);
            },
            child: const Text("Onayla"),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';

class AidatTakipSayfasi extends StatefulWidget {
  final Group? seciliGrup;
  final List<Users> tumKullanicilar;
  final List<Payment> tumOdemeler;
  final String grupAdi;
  final Users user;

  const AidatTakipSayfasi({
    super.key,
    this.seciliGrup,
    required this.tumKullanicilar,
    required this.tumOdemeler,
    required this.grupAdi,
    required this.user,
  });

  @override
  _AidatTakipSayfasiState createState() => _AidatTakipSayfasiState();
}

class _AidatTakipSayfasiState extends State<AidatTakipSayfasi> {
  @override
  Widget build(BuildContext context) {
    final gosterilecekOgrenciler = widget.tumKullanicilar.where((u) {
      if (widget.seciliGrup == null) {
        return u.app == widget.user.app;
      }
      return u.role == "student" &&
          u.branches_id == widget.seciliGrup!.branches_id;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.grupAdi), centerTitle: true),
      body: gosterilecekOgrenciler.isEmpty
          ? const Center(child: Text("Gösterilecek veri bulunamadı."))
          : ListView.builder(
              itemCount: gosterilecekOgrenciler.length,
              itemBuilder: (context, index) {
                final ogrenci = gosterilecekOgrenciler[index];

                bool odediMi = widget.tumOdemeler.any(
                  (p) =>
                      p.student_id == ogrenci.app &&
                      (widget.seciliGrup == null ||
                          p.groups_id == widget.seciliGrup!.groups_id) &&
                      p.status.toLowerCase() == "paid",
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: odediMi
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        odediMi ? Icons.check : Icons.priority_high,
                        color: odediMi ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text("${ogrenci.first_name} ${ogrenci.last_name}"),
                    subtitle: Text(odediMi ? "Aidat Ödendi" : "Ödeme Bekliyor"),
                    trailing: Text(
                      odediMi ? "TAMAM" : "EKSİK",
                      style: TextStyle(
                        color: odediMi ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      if (!odediMi) {
                        _odemeIsleminiBaslat(ogrenci);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  void _odemeIsleminiBaslat(Users ogrenci) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ödeme Bilgisi"),
        content: Text(
          "${ogrenci.first_name} için ödeme kaydı oluşturulsun mu?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Sheets'e kayıt atma mantığı buraya eklenecek
              Navigator.pop(context);
            },
            child: const Text("Onayla"),
          ),
        ],
      ),
    );
  }
}
