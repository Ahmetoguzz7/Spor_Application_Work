import 'package:flutter/material.dart';
import 'package:my_app/userInterfacepage/attendancedetail.dart';


void main() => runApp(MaterialApp(home: GrupListesiSayfasi()));

class GrupListesiSayfasi extends StatelessWidget {
  final List<String> gruplar = ["Futbol-A", "Basketbol-B", "Voleybol-C", "Karate-D"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gruplar")),
      body: ListView.builder(
        itemCount: gruplar.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(gruplar[index]),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                // Tıklanan grup ismini detay sayfasına yolluyoruz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YoklamaSayfasi(grupAdi: gruplar[index]),
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