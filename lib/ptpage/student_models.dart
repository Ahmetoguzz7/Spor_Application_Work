class Ogrenci {
  final String ad, tcNo, dogumTarihi, brans, anneAdi, babaAdi, grup;
  final int yas;
  final bool aidatOdediMi;
  final double yoklamaOrani;

  Ogrenci({
    required this.ad, required this.tcNo, required this.dogumTarihi,
    required this.brans, required this.yas, required this.anneAdi,
    required this.babaAdi, required this.grup,
    this.aidatOdediMi = true, this.yoklamaOrani = 80.0,
  });
}

// Örnek Sabit Veri
final mevcutOgrenci = Ogrenci(
  ad: "Ahmet Oğuz Mertoğlu",
  tcNo: "12345678901",
  dogumTarihi: "15.05.2006",
  brans: "Futbol",
  yas: 20,
  anneAdi: "Zeynep",
  babaAdi: "Mehmet",
  grup: "A Takımı",
);