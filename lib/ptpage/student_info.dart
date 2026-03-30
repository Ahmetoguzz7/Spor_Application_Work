import 'package:flutter/material.dart';
import 'package:my_app/ptpage/student_models.dart';


class KisiselBilgilerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil Detayları")),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _profilSatir("Ad Soyad", mevcutOgrenci.ad, Icons.person),
          _profilSatir("TC Kimlik", mevcutOgrenci.tcNo, Icons.badge),
          _profilSatir("Doğum Tarihi", mevcutOgrenci.dogumTarihi, Icons.cake),
          _profilSatir("Yaş", mevcutOgrenci.yas.toString(), Icons.history),
          _profilSatir("Branş", mevcutOgrenci.brans, Icons.sports_soccer),
          _profilSatir("Grup", mevcutOgrenci.grup, Icons.group),
          _profilSatir("Anne Adı", mevcutOgrenci.anneAdi, Icons.woman),
          _profilSatir("Baba Adı", mevcutOgrenci.babaAdi, Icons.man),
        ],
      ),
    );
  }

  Widget _profilSatir(String t, String v, IconData i) {
    return ListTile(
      leading: Icon(i, color: Colors.indigo),
      title: Text(t, style: TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
      onTap: () =>   Divider(height: 1),
    );
  }
}