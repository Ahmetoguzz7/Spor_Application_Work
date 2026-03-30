import 'package:flutter/material.dart';

class DuyurularPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Duyurular")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Haftalık Program"),
            subtitle: Text("Pazartesi antrenmanları saat 18:00'dedir."),
          ),
        ],
      ),
    );
  }
}