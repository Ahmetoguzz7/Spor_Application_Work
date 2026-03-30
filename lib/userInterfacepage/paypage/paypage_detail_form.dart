import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/userInterfacepage/paypage/paypage_detail_form_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';



Future<void> dekontOlusturVeGonder(kocOgrenci ogrenci, {required String ogrenciAdi}) async {

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(30),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            pw.Center(
              child: pw.Text(
                "OGRENCI AIDAT ODEME DEKONTU",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 30),

            pw.Text("Ogrenci: ${ogrenci.ad}"),
            pw.Text("Grup: ${ogrenci.grup}"),
            pw.Text("Odeme Tarihi: ${ogrenci.odemeTarihi?.toString().split(' ')[0] ?? ""}"),
            pw.Text("Odeyen Kisi: ${ogrenci.kimOdedi ?? ""}"),
            pw.Text("Odemeyi Alan: ${ogrenci.odemeAlan ?? ""}"),
            pw.Text("Alinan Ucret: ${ogrenci.odemeTutari ?? ""} TL"),

            pw.SizedBox(height: 40),

            pw.Text(
              "Islem Tarihi: ${DateTime.now().toString().split('.')[0]}",
              style: pw.TextStyle(fontSize: 12),
            ),

          ],
        ),
      ),
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/dekont.pdf");

  await file.writeAsBytes(await pdf.save());

  final Email email = Email(
    body: "Odeme dekontunuz ekte gonderilmistir.",
    subject: "Aidat Odeme Dekontu",
    recipients: [ogrenci.email],
    attachmentPaths: [file.path],
  );

  await FlutterEmailSender.send(email);
}

void odemeFormuAc(BuildContext context, kocOgrenci ogrenci) async {

  DateTime? secilenTarih;
  String? kimOdedi;
  String? odemeAlan;
  String? alinanUcret;

  await showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(
        title: const Text("Ödeme Bilgisi"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ElevatedButton(
              child: const Text("Ödeme Tarihi Seç"),
              onPressed: () async {

                secilenTarih = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                );

              },
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              hint: const Text("Kim Ödedi"),
              items: const [
                DropdownMenuItem(value: "Anne", child: Text("Anne")),
                DropdownMenuItem(value: "Baba", child: Text("Baba")),
                DropdownMenuItem(value: "Kendisi", child: Text("Kendisi")),
              ],
              onChanged: (v) {
                kimOdedi = v;
              },
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(
                labelText: "Ödemeyi Kim Aldı",
              ),
              onChanged: (v) {
                odemeAlan = v;
              },
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(
                labelText: "Alınan Ücret (TL)",
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                alinanUcret = v;
              },
            ),

          ],
        ),

        actions: [

          TextButton(
            child: const Text("İptal"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          ElevatedButton(
            child: const Text("Kaydet"),
            onPressed: () async {

              ogrenci.aidatOdediMi = true;
              ogrenci.odemeTarihi = secilenTarih;
              ogrenci.kimOdedi = kimOdedi;
              ogrenci.odemeAlan = odemeAlan;
              ogrenci.odemeTutari = alinanUcret;

              Navigator.pop(context);

              await dekontOlusturVeGonder(ogrenci, ogrenciAdi: '');

            },
          )

        ],
      );

    },
  );
}