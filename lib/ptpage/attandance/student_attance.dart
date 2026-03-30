/*import 'package:flutter/material.dart';
import 'package:my_app/ptpage/student_models.dart';


class StudentYoklamaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yoklama Detayı"), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _ozetKutu("Toplam Katılım", "%${mevcutOgrenci.yoklamaOrani.toInt()}", Icons.done_all, Colors.green),
            SizedBox(height: 20),
            _bilgiKart("Öğrenci Bilgileri", [
              _satir("TC No", mevcutOgrenci.tcNo),
              _satir("Branş", mevcutOgrenci.brans),
              _satir("Grup", mevcutOgrenci.grup),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _ozetKutu(String t, String v, IconData i, Color c) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t), Text(v, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c))]),
          Icon(i, size: 40, color: c),
        ],
      ),
    );
  }

  Widget _bilgiKart(String baslik, List<Widget> icerik) {
    return Card(child: Padding(padding: EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(baslik, style: TextStyle(fontWeight: FontWeight.bold)), Divider(), ...icerik])));
  }

  Widget _satir(String l, String v) => Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: TextStyle(fontWeight: FontWeight.bold))]));
}
*/
//BU KOÇ SAYFASI KISMINA GEÇECEK SADECE DENEME AMAÇLI
import 'package:flutter/material.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/ptpage/attandance/attandance_model.dart';

class StudentYoklamaPage extends StatefulWidget {
  final String studentId;

  StudentYoklamaPage({required this.studentId});

  @override
  _StudentYoklamaPageState createState() => _StudentYoklamaPageState();
}

class _StudentYoklamaPageState extends State<StudentYoklamaPage> {
  // Kanka burayı dynamic yerine Attendance yapalım ki kafası karışmasın
  List<Attendance> attendances = []; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    // Servis zaten List<Attendance> döndürüyor
    var data = await GoogleSheetService.getAttendances(widget.studentId);
    setState(() {
      attendances = data;
      isLoading = false;
    });
  }

  void _addAttendance(String status) async {
    var newRecord = Attendance(
      attendanceId: "ATT-${DateTime.now().millisecondsSinceEpoch}",
      studentId: widget.studentId,
      date: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      status: status, 
      notes: 'Mobil Uygulama',
    );

    bool success = await GoogleSheetService.saveAttendance(newRecord);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Yoklama kaydedildi!")));
        _fetchData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ DÜZELTME: a['status'] yerine a.status (Nokta kullandık)
    int presentCount = attendances.where((a) => a.status.toLowerCase() == "geldi").length;
    double ratio = attendances.isEmpty ? 0 : (presentCount / attendances.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text("Öğrenci: ${widget.studentId}"), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _kart("Katılım Oranı", "%${ratio.toInt()}", Icons.analytics, Colors.blue),
                SizedBox(height: 20),
                _listeKart("Geçmiş Yoklamalar", attendances),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(),
        label: Text("Yoklama Al"),
        icon: Icon(Icons.add),
      ),
    );
  }

  void _showDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Öğrenci Geldi mi?"),
      actions: [
        TextButton(onPressed: () { _addAttendance("Gelmedi"); Navigator.pop(context); }, child: Text("HAYIR", style: TextStyle(color: Colors.red))),
        ElevatedButton(onPressed: () { _addAttendance("Geldi"); Navigator.pop(context); }, child: Text("EVET")),
      ],
    ));
  }

  Widget _kart(String t, String v, IconData i, Color c) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t), Text(v, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c))]),
        Icon(i, size: 40, color: c),
      ]),
    );
  }

  // ✅ DÜZELTME: Liste tipi Attendance oldu
  Widget _listeKart(String baslik, List<Attendance> liste) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(baslik, style: TextStyle(fontWeight: FontWeight.bold)),
        Divider(),
        if (liste.isEmpty) Text("Kayıt yok."),
        // ✅ DÜZELTME: a['date'] yerine a.date kullandık
        ...liste.map((a) => Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(a.date), 
              Text(a.status, style: TextStyle(fontWeight: FontWeight.bold, color: a.status.toLowerCase() == "geldi" ? Colors.green : Colors.red))
            ]
          ),
        )).toList()
      ]),
    );
  }
}