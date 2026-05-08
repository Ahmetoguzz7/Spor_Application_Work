import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/main.dart';
import 'package:my_app/userInterfacepage/attendance.dart';
import 'package:my_app/userInterfacepage/notifications/pt_natifications.dart';

class PersonalTrainer extends StatelessWidget {
  final Users users;
  final Sports sport;
  final Coach coachData;
  final List<Group> tumGruplar;
  final List<Users> tumKullanicilar;
  final List<Payment> tumOdemeler;

  const PersonalTrainer({
    super.key,
    required this.users,
    required this.sport,
    required this.coachData,
    this.tumGruplar = const [],
    this.tumKullanicilar = const [],
    this.tumOdemeler = const [],
  });

  // 🔥 YENİ: Duyurular sayfasını açan fonksiyon
  Future<void> _openNotificationsPage(BuildContext context) async {
    // TÜM DUYURULARI ÇEK
    final allNotifications = await GoogleSheetService.getNotifications(
      userId: users.app,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DuyurularPage(
          tumDuyurular: allNotifications, // 🔥 DÜZELTİLDİ!
          currentUser: users,
          currentCoach: coachData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Antrenör Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => RoleSelectPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hızlı İşlemler",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        context,
                        "Yoklama Al",
                        "Sporcu katılımı",
                        Icons.fact_check_rounded,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GrupListesiSayfasi(
                              user: users,
                              coache: coachData,
                            ),
                          ),
                        ),
                      ),
                      /*
                      _buildActionCard(
                        context,
                        "Ödemeler",
                        "Aidat takibi",
                        Icons.account_balance_wallet_rounded,
                        Colors.orange,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GrupSecimSayfasi(
                              tumGruplar: tumGruplar,
                              tumKullanicilar: tumKullanicilar,
                              tumOdemeler: tumOdemeler,
                              currentUser: users,
                            ),
                          ),
                        ),
                      ),
                      */
                      _buildActionCard(
                        context,
                        "Duyuru Yap",
                        "Grup mesajları",
                        Icons.notification_add_rounded,
                        Colors.blue,
                        () => _openNotificationsPage(context), // 🔥 DÜZELTİLDİ!
                      ),
                      _buildActionCard(
                        context,
                        "Profilim",
                        "Sertifika & Bio",
                        Icons.badge_rounded,
                        Colors.purple,
                        () => _showCoachDetails(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildSummaryInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🎨 TASARIM BİLEŞENLERİ (Aynı kalacak) ---

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            backgroundImage: users.profile_photo_url.isNotEmpty
                ? NetworkImage(users.profile_photo_url)
                : null,
            child: users.profile_photo_url.isEmpty
                ? const Icon(Icons.person, size: 45, color: Colors.blueAccent)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Merhaba,",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  "${users.first_name} ${users.last_name}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sport.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[800]!, Colors.black87],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem("Öğrenci", tumKullanicilar.length.toString()),
          _buildDivider(),
          _buildInfoItem("Grup", tumGruplar.length.toString()),
          _buildDivider(),
          _buildInfoItem("Ders", "bugün-3"),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.white24);
  }

  void _showCoachDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(width: 50, child: Divider(thickness: 4)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sözleşme & Bilgiler",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _detailRow(Icons.verified, "Sertifika", coachData.certificate_info),
            _detailRow(
              Icons.payments,
              "Maaş Hakkedişi",
              "${coachData.monthly_salary} TL",
            ),
            _detailRow(
              Icons.calendar_today,
              "İşe Başlangıç",
              coachData.hired_at.toString().split(' ')[0],
            ),
            _detailRow(Icons.info_outline, "Hakkımda", coachData.bio),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
