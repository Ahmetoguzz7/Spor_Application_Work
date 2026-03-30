import 'package:http/http.dart' as http;
import 'package:my_app/ptpage/attandance/attandance_model.dart';
import 'dart:convert';
import 'package:my_app/datapage/data_page/data.dart'; // Student modeli burada sanırım

class GoogleSheetService {
  static const String _baseUrl = "https://script.google.com/macros/s/AKfycbzzDqSHW2otqQKtPI8cuTE025ranIkbOYM2SrI_cinfeV23I9D5BINB9Yszxa92e1do/exec";

  // --- TEMEL OKUMA FONKSİYONU ---
  static Future<List<dynamic>> fetchTable(String sheetName) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl?sheet=$sheetName"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Hata: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }





 //--------------------------------------------------------------------
  static Future<List<Student>> getStudents() async {
   
    final List<dynamic> rawData = await fetchTable("Students");
    
    return rawData.map((item) => Student.fromJson(item)).toList();
  }
//--------------------------------------------------------------------
  // --- KOÇ FİLTRELEME FONKSİYONU ---
  static Future<List<Student>> getStudentsForCoach(String coachBranchId) async {
    // Artık yukarıdaki getStudents() fonksiyonu var, hata vermez
    final allStudents = await getStudents(); 

    // Şubeye göre filtrele
    return allStudents.where((s) => s.branchId == coachBranchId).toList();
  }











//--------------------------------------------------------------------
//login için debug için önemli kalabilir.
/*
static Future<Map<String, dynamic>?> login(String email, String password) async {
  final List<dynamic> users = await fetchTable("Users");
  
  print("--- DEBUG BAŞLADI ---");
  for (var u in users) {
    var sEmail = u['email'].toString().trim();
    var sPass = u['password_hash'].toString().trim();
    
    print("Sorgulanan: '$email' == '$sEmail' ?");
    print("Sorgulanan Şifre: '$password' == '$sPass' ?");

    if (sEmail == email.trim() && sPass == password.trim()) {
      print("BULDUM! Giriş onaylandı.");
      // ... geri kalan kod ...
      return u; 
    }
  }
  print("EŞLEŞME YOK!");
  return null;
}
*/

static Future<Map<String, dynamic>?> login(String email, String password) async {
  try {
    // 1. Tüm kullanıcılar tablosunu çek
    final List<dynamic> users = await fetchTable("Users");
    
    // 2. Email ve Şifre kontrolü (Trim ve String zorlaması ile)
    final user = users.firstWhere(
      (u) => u['email'].toString().trim() == email.trim() && 
             u['password_hash'].toString().trim() == password.trim(),
      orElse: () => null,
    );

    if (user != null) {
      print("Giriş başarılı! Rol: ${user['role']}");

      // 3. Eğer kullanıcı KOÇ ise direkt Users verisini döndür
      if (user['role'].toString().toLowerCase() == 'koc') {
        // İstersen burada Coaches tablosundan da ek bilgi çekebilirsin
        return user; 
      } 
      
      // 4. Eğer kullanıcı ÖĞRENCİ (veya veli) ise Students tablosundan detayları getir
      else {
        final List<dynamic> students = await fetchTable("Students");
        final studentData = students.firstWhere(
          (s) => s['user_id'].toString() == user['user_id'].toString(),
          orElse: () => null,
        );
        
        // Öğrenci verisi bulunduysa döndür, bulunamadıysa ana kullanıcıyı döndür
        return studentData ?? user;
      }
    }
    
    print("Hata: Kullanıcı bulunamadı veya şifre yanlış.");
    return null;
    
  } catch (e) {
    print("Login fonksiyonunda hata oluştu: $e");
    return null;
  }
}
//--------------------------------------------------------------------
// --- MASTER KAYIT (REGISTER EVERYWHERE) ---
  static Future<bool> registerEverywhere(Map<String, dynamic> allInfo) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: jsonEncode({
          "action": "registerEverywhere",
          "data": allInfo,
        }),
      );
      
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      print("Kayıt Hatası: $e");
      return false;
    }
  }






//--------------------------------------------------------------------

 // 1. Belirli bir öğrencinin yoklamalarını getir
static Future<List<Attendance>> getAttendances(String studentId) async {
  final List<dynamic> rawData = await fetchTable("Attendances");
  return rawData
      .map((item) => Attendance.fromJson(item))
      .where((a) => a.studentId == studentId)
      .toList();
}

// 2. Yeni yoklama kaydet
static Future<bool> saveAttendance(Attendance attendance) async {
  try {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "saveAttendance",
        "sheet": "Attendances",
        "data": attendance.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      // result Map mi, yoksa başka tip mi?
      if (result is Map) {
        // Eğer Map ve status key varsa kontrol et
        if (result.containsKey('status')) {
          return result['status'] == 'success';
        } else {
          return true; // Map ama status yoksa varsayılan true
        }
      } else {
        // result Map değilse direkt true/false dönebiliriz
        return result.toString().toLowerCase() == 'success';
      }
    } else {
      print("HTTP Hatası: ${response.statusCode}, body: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Yoklama Kayıt Hatası: $e");
    return false;
  }
}
  //-------------------Update Profil-------------------
static Future<bool> updateProfile(Map<String, dynamic> data, ) async {
  try {
    final response = await http.post(
        Uri.parse(_baseUrl),
      body: jsonEncode({
        "action": "updateUser",
        "data": data,
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
}
//--------------------------------------------------------------------
