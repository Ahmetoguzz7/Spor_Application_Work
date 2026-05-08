/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart'; // Modellerin yolu
import 'package:my_app/datapage/fetch_data_page.dart'; // Servislerin yolu

void odemeFormuAc(
  BuildContext context,
  Users student,
  Group? seciliGrup,
  Users currentUser,
) {
  // Varsayılan tutar olarak grubun aylık ücretini getiriyoruz
  final TextEditingController miktarController = TextEditingController(
    text: seciliGrup?.free_sports_monthly ?? "",
  );
  final TextEditingController notController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("${student.first_name} ${student.last_name}"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Branş: ${seciliGrup?.sportId ?? 'Genel'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: miktarController,
              decoration: const InputDecoration(
                labelText: "Tutar (TL)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notController,
              decoration: const InputDecoration(
                labelText: "Ödeme Notu / Dekont No",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (miktarController.text.isEmpty) return;

              // --- YENİ PAYMENT MODELİNE GÖRE ATAMALAR ---
              final yeniOdeme = Payment(
                paymentId:
                    "PAY-${DateTime.now().millisecondsSinceEpoch}", // Benzersiz ID
                studentId: student.appId, // Öğrenci ID
                groupId: seciliGrup?.groupId ?? "", // Grup ID
                // Şube ID (Users'tan geliyor)
                // Sports ID (Group'tan geliyor)
                // Ödemeyi alan Hoca/Muhasebe ID
                amount: miktarController.text,
                due_date: DateTime.now().add(
                  const Duration(days: 30),
                ), // Vade (30 gün sonra)
                paid_date: DateTime.now(), // Şu anki ödeme tarihi
                payment_method: "Nakit", // İsteğe göre seçimli yapılabilir
                payment_note: notController.text,
                status: "Paid",

                recored_by: currentUser.appId,
                // Direkt ödendi olarak kaydediyoruz
              );

              // 2. GoogleSheetService'e gönder
              bool basarili = await GoogleSheetService.addPayment(yeniOdeme);

              if (basarili) {
                if (context.mounted) Navigator.pop(context);

                // Opsiyonel: Dekont süreci
                // await dekontOlusturVeGonder(student, yeniOdeme);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ödeme başarıyla tabloya işlendi."),
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Hata: Kayıt yapılamadı!")),
                  );
                }
              }
            },
            child: const Text("Ödemeyi Onayla"),
          ),
        ],
      );
    },
  );
}
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';

void odemeFormuAc(
  BuildContext context,
  Users student,
  Group? seciliGrup,
  Users currentUser,
) {
  final TextEditingController miktarController = TextEditingController(
    text: seciliGrup?.monthly_fee ?? "",
  );
  final TextEditingController notController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("${student.first_name} ${student.last_name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Branş: ${seciliGrup?.sports_id ?? 'Genel'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: miktarController,
              decoration: const InputDecoration(
                labelText: "Tutar (TL)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notController,
              decoration: const InputDecoration(
                labelText: "Ödeme Notu / Dekont No",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (miktarController.text.isEmpty) return;

              final now = DateTime.now();
              final formattedDate =
                  "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

              final yeniOdeme = Payment(
                payments_id: "",
                student_id: student.app,
                groups_id: seciliGrup?.groups_id ?? "",
                recorded_by: currentUser.app,
                amount: miktarController.text,
                due_date: "",
                paid_date: formattedDate,
                status: "paid",
                payment_method: "Nakit",
                note: notController.text,
              );

              bool basarili = await GoogleSheetService.addPayment(yeniOdeme);

              if (basarili) {
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ödeme başarıyla tabloya işlendi."),
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Hata: Kayıt yapılamadı!")),
                  );
                }
              }
            },
            child: const Text("Ödemeyi Onayla"),
          ),
        ],
      );
    },
  );
}
