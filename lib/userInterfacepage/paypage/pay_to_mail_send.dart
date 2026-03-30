import 'package:my_app/userInterfacepage/paypage/paypage_detail_form_model.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> mailGonder(kocOgrenci ogrenci) async {

  final subject = Uri.encodeComponent("Aidat Ödeme Bilgisi");
  final body = Uri.encodeComponent(
      "${ogrenci.ad} öğrencisinin aidatı ödendi.");

  final Uri emailUri = Uri.parse(
      "mailto:${ogrenci.email}?subject=$subject&body=$body");

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'Mail uygulaması açılamadı';
  }
}