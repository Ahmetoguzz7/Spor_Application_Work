/*
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart'; // Users modelinin olduğu yer

class KisiselBilgilerPage extends StatelessWidget {
  final Users user;

  const KisiselBilgilerPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Detayları"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Üst Kısım: Profil Fotoğrafı ve İsim
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    backgroundImage: user.profile_photo_url.isNotEmpty
                        ? NetworkImage(user.profile_photo_url)
                        : null,
                    child: user.profile_photo_url.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${user.first_name} ${user.last_name}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Chip(
                    label: Text(user.role.toUpperCase()),
                    backgroundColor: Colors.indigo.shade100,
                  ),
                ],
              ),
            ),

            // Bilgi Listesi
            Padding(
              padding: const EdgeInsets.all(15),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    _profilSatir("E-Posta Adresi", user.email, Icons.email),
                    const Divider(height: 1),
                    _profilSatir("Telefon Numarası", user.phone, Icons.phone),
                    const Divider(height: 1),
                    _profilSatir("Şube ID", user.branches_id, Icons.location_on),
                    const Divider(height: 1),
                    _profilSatir("Sistem ID", user.app, Icons.fingerprint),
                    const Divider(height: 1),
                    _profilSatir(
                      "Kayıt Tarihi",
                      user.created_at,
                      Icons.calendar_today,
                    ),
                    const Divider(height: 1),
                    _profilSatir(
                      "Hesap Durumu",
                      user.status == "1" ? "Aktif" : "Pasif",
                      Icons.verified_user,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilSatir(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.indigo, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';

class KisiselBilgilerPage extends StatelessWidget {
  final Users user;

  const KisiselBilgilerPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Detayları"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    backgroundImage: user.profile_photo_url.isNotEmpty
                        ? NetworkImage(user.profile_photo_url)
                        : null,
                    child: user.profile_photo_url.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${user.first_name} ${user.last_name}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Chip(
                    label: Text(user.role.toUpperCase()),
                    backgroundColor: Colors.indigo.shade100,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    _profilSatir("E-Posta Adresi", user.email, Icons.email),
                    const Divider(height: 1),
                    _profilSatir("Telefon Numarası", user.phone, Icons.phone),
                    const Divider(height: 1),
                    _profilSatir(
                      "Şube ID",
                      user.branches_id,
                      Icons.location_on,
                    ),
                    const Divider(height: 1),
                    _profilSatir("Sistem ID", user.app, Icons.fingerprint),
                    const Divider(height: 1),
                    _profilSatir(
                      "Kayıt Tarihi",
                      user.created_at,
                      Icons.calendar_today,
                    ),
                    const Divider(height: 1),
                    _profilSatir(
                      "Hesap Durumu",
                      user.is_active.toLowerCase() == "true"
                          ? "Aktif"
                          : "Pasif",
                      Icons.verified_user,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilSatir(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.indigo, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
