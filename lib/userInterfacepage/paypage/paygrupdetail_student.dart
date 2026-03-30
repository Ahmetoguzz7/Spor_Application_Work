import 'package:flutter/material.dart';
import 'package:my_app/userInterfacepage/paypage/ogrencimodel.dart';
import 'package:my_app/userInterfacepage/paypage/paypage_detail_form.dart';
import 'package:my_app/userInterfacepage/paypage/paypage_detail_form_model.dart';


class AidatTakipSayfasi extends StatefulWidget {
  final String grupAdi;

  AidatTakipSayfasi({required this.grupAdi});

  @override
  _AidatTakipSayfasiState createState() => _AidatTakipSayfasiState();
}

class _AidatTakipSayfasiState extends State<AidatTakipSayfasi> {
  @override
  Widget build(BuildContext context) {
    // Sadece bu gruba ait öğrencileri süzüyoruz
    final grupOgrencileri = tumOgrenciler
        .where((o) => o.grup == widget.grupAdi)
        .toList();

    // Kaç kişi ödeme yapmış sayısını hesaplayalım
    int odenenSayisi = grupOgrencileri.where((o) => o.aidatOdediMi).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.grupAdi} Aidat Takibi"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Toplam Ödeme: $odenenSayisi / ${grupOgrencileri.length}",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: grupOgrencileri.length,
        itemBuilder: (context, index) {
          final ogrenci = grupOgrencileri[index];
          
          return CheckboxListTile(
            title: Text(
              ogrenci.ad,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ogrenci.aidatOdediMi ? Colors.green : Colors.black,
              ),
            ),
            subtitle: Text(ogrenci.aidatOdediMi ? "Aidat Ödendi" : "Beklemede"),
            value: ogrenci.aidatOdediMi,
            activeColor: Colors.green,
            checkColor: Colors.white,
            secondary: Icon(
              ogrenci.aidatOdediMi ? Icons.monetization_on : Icons.money_off,
              color: ogrenci.aidatOdediMi ? Colors.green : Colors.grey,
            ),
           onChanged: (bool? deger) {

 if (deger == true) {
  // 1. Önce ekrandaki durumu güncelle (Tik atılsın)
  setState(() {
    ogrenci.aidatOdediMi = true;
  });

  // 2. Formu aç (Gerekliyse)
  odemeFormuAc(context, kocOgrenci(ad: ogrenci.ad, grup: ogrenci.grup, email: "ahmetoguzmertoglu@beyes.com.tr"));

  // 3. PDF oluştur ve Mail taslağını aç
  // Not: Buradaki parametreleri formdan gelen gerçek verilerle doldurmayı unutma!
 

} else {
  setState(() {
    ogrenci.aidatOdediMi = false;
  });
}
}
          );
        },
      ),
    );
  }
}