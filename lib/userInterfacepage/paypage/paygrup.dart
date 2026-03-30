import 'package:flutter/material.dart';
import 'package:my_app/userInterfacepage/paypage/paygrupdetail_student.dart';


void main() => runApp(MaterialApp(
  home: GrupSecimSayfasi(),
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primarySwatch: Colors.indigo),
));

class GrupSecimSayfasi extends StatelessWidget {
  final List<String> gruplar = ["A Grubu", "B Grubu", "C Grubu"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aidat Grupları")),
      body: ListView.builder(
        itemCount: gruplar.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.folder_shared, color: Colors.indigo),
              title: Text(gruplar[index]),
              subtitle: Text("Ödeme listesi için dokunun"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AidatTakipSayfasi(grupAdi: gruplar[index]),
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