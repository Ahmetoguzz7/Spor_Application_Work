class kocOgrenci {

  String ad;
  String grup;
  String email;

  bool aidatOdediMi;

  DateTime? odemeTarihi;
  String? kimOdedi;
  String? odemeAlan;
  String? odemeTutari;

  kocOgrenci({
    required this.ad,
    required this.grup,
    required this.email,
    this.aidatOdediMi = false,
    this.odemeTarihi,
    this.kimOdedi,
    this.odemeAlan,
    this.odemeTutari,
  });

}