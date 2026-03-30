class Ogrenci {
  final String ad;
  final String grup;
  bool buradaMi; // Değiştirilebilir olması için final değil

  Ogrenci({required this.ad, required this.grup, this.buradaMi = true});
}

// Örnek öğrenci listesi
List<Ogrenci> tumOgrenciler = [
  Ogrenci(ad: "Bilal Derman", grup: "Futbol-A"),
  Ogrenci(ad: "Ahmet Yılmaz", grup: "Futbol-A"),
  Ogrenci(ad: "Mehmet Demir", grup: "Basketbol-B"),
  Ogrenci(ad: "Ayşe Kaya", grup: "Voleybol-C"),
  Ogrenci(ad: "Deniz Ak", grup: "Karate-D"),
];