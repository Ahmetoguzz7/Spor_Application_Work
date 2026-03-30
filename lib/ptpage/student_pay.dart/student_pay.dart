import 'package:flutter/material.dart';
import 'package:my_app/ptpage/student_models.dart';


class AidatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool odendi = mevcutOgrenci.aidatOdediMi;
    return Scaffold(
      appBar: AppBar(title: Text("Aidat Bilgisi")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(odendi ? Icons.check_circle : Icons.cancel, size: 80, color: odendi ? Colors.green : Colors.red),
            Text(odendi ? "Ödeme Tamamlandı" : "Ödeme Bekleniyor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            _detayTile("Ödeme Yapan", mevcutOgrenci.ad),
            _detayTile("Baba Adı", mevcutOgrenci.babaAdi),
            _detayTile("Anne Adı", mevcutOgrenci.anneAdi),
            _detayTile("Kayıtlı Branş", mevcutOgrenci.brans),
          ],
        ),
      ),
    );
  }

  Widget _detayTile(String t, String v) => ListTile(title: Text(t, style: TextStyle(fontSize: 14, color: Colors.grey)), subtitle: Text(v, style: TextStyle(fontSize: 18, color: Colors.black)));
}