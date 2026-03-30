class Ogrenci {
  final String ad;
  final String grup;
  bool aidatOdediMi; // Ödeme durumu (true: Ödedi, false: Ödemedi)

  Ogrenci({
    required this.ad, 
    required this.grup, 
    this.aidatOdediMi = false, // Varsayılan olarak ödenmedi başlar
  });
}

// Örnek Veri Seti
List<Ogrenci> tumOgrenciler = [
  Ogrenci(ad: "Bilal Derman", grup: "A Grubu"),
  Ogrenci(ad: "Ahmet Yılmaz", grup: "A Grubu"),
  Ogrenci(ad: "Mehmet Demir", grup: "B Grubu"),
  Ogrenci(ad: "Ayşe Kaya", grup: "A Grubu"),
  Ogrenci(ad: "Can Öz", grup: "C Grubu"),
];