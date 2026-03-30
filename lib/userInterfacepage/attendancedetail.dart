import 'package:flutter/material.dart';
import 'package:my_app/userInterfacepage/student.dart';


class YoklamaSayfasi extends StatefulWidget {
  final String grupAdi;
  YoklamaSayfasi({required this.grupAdi});

  @override
  _YoklamaSayfasiState createState() => _YoklamaSayfasiState();
}

class _YoklamaSayfasiState extends State<YoklamaSayfasi> {
  @override
  Widget build(BuildContext context) {
    // Sadece bu gruba ait öğrencileri filtrele
    final grupOgrencileri = tumOgrenciler.where((o) => o.grup == widget.grupAdi).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.grupAdi} Yoklaması"),
        actions: [
          // Sağ üst köşeye sadece gelmeyenleri görmek için bir buton ekleyebiliriz
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () => _gelmeyenleriGoster(context, grupOgrencileri),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: grupOgrencileri.length,
        itemBuilder: (context, index) {
          final ogrenci = grupOgrencileri[index];
          return CheckboxListTile(
            title: Text(ogrenci.ad),
            subtitle: Text(ogrenci.buradaMi ? "Burada" : "Gelmedi"),
            value: ogrenci.buradaMi,
            activeColor: Colors.green,
            onChanged: (bool? value) {
              setState(() {
                ogrenci.buradaMi = value!;
              });
            },
          );
        },
      ),
    );
  }

  // Sadece gelmeyenleri (tik atılmayanları) bir popup penceresinde gösterir
  void _gelmeyenleriGoster(BuildContext context, List<Ogrenci> liste) {
    final gelmeyenler = liste.where((o) => !o!.buradaMi).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Gelmeyenler Listesi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              Divider(),
              gelmeyenler.isEmpty 
                ? Text("Herkes burada!") 
                : Expanded(
                    child: ListView.builder(
                      itemCount: gelmeyenler.length,
                      itemBuilder: (context, i) => ListTile(title: Text(gelmeyenler[i].ad)),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}