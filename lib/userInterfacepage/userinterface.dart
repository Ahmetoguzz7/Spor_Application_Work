import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/main.dart';
import 'package:my_app/unifiedLoginPage.dart';
import 'package:my_app/userInterfacepage/attendance.dart';
import 'package:my_app/userInterfacepage/attendancedetail.dart';
import 'package:my_app/userInterfacepage/notifications/pt_natifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalTrainer extends StatefulWidget {
  final Users users;
  final Sports sport;
  final Coach coachData;

  const PersonalTrainer({
    super.key,
    required this.users,
    required this.sport,
    required this.coachData,
  });

  @override
  State<PersonalTrainer> createState() => _PersonalTrainerState();
}

class _PersonalTrainerState extends State<PersonalTrainer> {
  late Future<Map<String, dynamic>> _trainerDataFuture;

  @override
  void initState() {
    super.initState();
    _trainerDataFuture = _loadTrainerData();
  }

  Future<Map<String, dynamic>> _loadTrainerData() async {
    try {
      // 1. Antrenörün gruplarını çek
      final myGroups = await GoogleSheetService.getGroupsByCoach(
        widget.coachData.coach_id,
      );

      // 2. Gruplardaki öğrenci ID'lerini bul
      List<String> studentIds = [];
      for (var group in myGroups) {
        final groupStudents =
            await GoogleSheetService.getGroupStudentsByGroupId(group.groups_id);
        studentIds.addAll(
          groupStudents
              .where((gs) => gs.is_active == "TRUE")
              .map((gs) => gs.student_id)
              .toList(),
        );
      }
      studentIds = studentIds.toSet().toList();

      // 3. Öğrenci bilgilerini çek
      final allUsers = await GoogleSheetService.getUsers();
      final myStudents = allUsers
          .where((u) => studentIds.contains(u.app))
          .toList();

      // 4. Öğrencilere ait ödemeleri çek
      final allPayments = await GoogleSheetService.getPayments();
      final myPayments = allPayments
          .where((p) => studentIds.contains(p.student_id))
          .toList();

      // 5. TÜM DUYURULARI ÇEK
      final allNotifications = await GoogleSheetService.getNotifications(
        userId: widget.users.app,
      );

      // Kullanıcının gruplarını bul (filtreleme için)
      List<String> userGroups = myGroups
          .map((g) => g.groups_id.toString())
          .toList();

      // Duyuruları filtrele (herkese açık veya gruba özel)
      final filteredNotifications = allNotifications.where((d) {
        final recipientId = d.recipient_id?.toString() ?? "";
        if (recipientId == "all" ||
            recipientId == "Tümü" ||
            recipientId == "ALL")
          return true;
        if (recipientId.isNotEmpty && userGroups.contains(recipientId))
          return true;
        return false;
      }).toList();

      // SON 7 GÜN İÇİNDEKİ DUYURULARI FİLTRELE
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final recentNotifications = filteredNotifications.where((n) {
        final date = _parseDate(n.sent_at);
        return date.isAfter(sevenDaysAgo);
      }).toList();

      // Tarihe göre sırala (en yeni en üstte)
      recentNotifications.sort((a, b) {
        final dateA = _parseDate(a.sent_at);
        final dateB = _parseDate(b.sent_at);
        return dateB.compareTo(dateA);
      });

      // EN FAZLA 3 DUYURU GÖSTER
      final topNotifications = recentNotifications.take(3).toList();

      return {
        'groups': myGroups,
        'students': myStudents,
        'payments': myPayments,
        'recentNotifications': topNotifications,
        'allNotificationsCount': recentNotifications.length,
      };
    } catch (e) {
      print("Veri yükleme hatası: $e");
      return {
        'groups': <Group>[],
        'students': <Users>[],
        'payments': <Payment>[],
        'recentNotifications': <Notifications>[],
        'allNotificationsCount': 0,
      };
    }
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime(2000);
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime(2000);
    }
  }

  Future<void> _openNotificationsPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DuyurularPage(
          currentUser: widget.users,
          currentCoach: widget.coachData,
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Şimdi";
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 0) return "${diff.inDays} gün önce";
      if (diff.inHours > 0) return "${diff.inHours} saat önce";
      if (diff.inMinutes > 0) return "${diff.inMinutes} dakika önce";
      return "Şimdi";
    } catch (e) {
      return "Şimdi";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _trainerDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error);
          }

          final myGroups = snapshot.data?['groups'] as List<Group>? ?? [];
          final myStudents = snapshot.data?['students'] as List<Users>? ?? [];
          final myPayments = snapshot.data?['payments'] as List<Payment>? ?? [];
          final recentNotifications =
              snapshot.data?['recentNotifications'] as List<Notifications>? ??
              [];
          final allNotificationsCount =
              snapshot.data?['allNotificationsCount'] as int? ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _trainerDataFuture = _loadTrainerData();
              });
              await _trainerDataFuture;
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 260,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () async {
                      // 🔥 TÜM KAYITLI BİLGİLERİ TEMİZLE
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('saved_email');
                      await prefs.remove('saved_password');
                      await prefs.setBool('remember_me', false);

                      // 🔥 TÜM SAYFALARI TEMİZLE, LOGIN'E YÖNLENDİR
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UnifiedLoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(myStudents, myGroups, myPayments),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hızlı İşlemler",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                "Yoklama Al",
                                Icons.fact_check_rounded,
                                Colors.green,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GrupListesiSayfasi(
                                      user: widget.users,
                                      coache: widget.coachData,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionCard(
                                "Duyurular",
                                Icons.campaign,
                                Colors.blue,
                                () => _openNotificationsPage(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionCard(
                                "Profilim",
                                Icons.badge,
                                Colors.purple,
                                () => _showCoachDetails(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 🔥 SON 7 GÜNÜN DUYURULARI BÖLÜMÜ
                        if (recentNotifications.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.campaign,
                                      size: 18,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Son 7 Günün Duyuruları",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$allNotificationsCount duyuru",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...recentNotifications.map(
                                  (notif) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildNotificationCard(notif),
                                  ),
                                ),
                                if (allNotificationsCount > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _openNotificationsPage(context),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Tüm duyuruları gör (${allNotificationsCount - 3} daha)",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 12,
                                            color: Colors.blue.shade600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Gruplarım bölümü
                        if (myGroups.isNotEmpty) ...[
                          const Row(
                            children: [
                              Icon(Icons.group, size: 20, color: Colors.orange),
                              SizedBox(width: 6),
                              Text(
                                "Gruplarım",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...myGroups.map(
                            (group) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildGroupCard(group),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Notifications notif) {
    bool isUrgent = notif.type?.toLowerCase() == "urgent";

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUrgent
            ? Border.all(color: Colors.red.shade200, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isUrgent
                              ? Colors.red.shade800
                              : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Acil",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.message,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatDate(notif.sent_at),
            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(Group group) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YoklamaSayfasi(
                  selectedGroup: group,
                  currentUser: widget.users,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.group, size: 28, color: Colors.orange[700]),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              group.schedule,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (group.monthly_fee.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.payments,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${group.monthly_fee} TL",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_basketball,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "SPOR ARENA",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Veriler Yükleniyor...",
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object? error) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Bağlantı Hatası",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _trainerDataFuture = _loadTrainerData();
                });
              },
              child: const Text(
                "Tekrar Dene",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    List<Users> myStudents,
    List<Group> myGroups,
    List<Payment> myPayments,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: widget.users.profile_photo_url.isNotEmpty
                          ? NetworkImage(widget.users.profile_photo_url)
                          : null,
                      child: widget.users.profile_photo_url.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hoş Geldin,",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "${widget.users.first_name} ${widget.users.last_name}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sports_basketball,
                                size: 12,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.sport.name,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatCard(
                    myStudents.length,
                    "ÖĞRENCİ",
                    Icons.people,
                    Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    myGroups.length,
                    "GRUP",
                    Icons.group,
                    Colors.green,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    myPayments.length,
                    "ÖDEME",
                    Icons.payments,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(int value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCoachDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.badge, color: Colors.orange, size: 28),
                SizedBox(width: 10),
                Text(
                  "Antrenör Profili",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow(
              Icons.verified,
              "Sertifika",
              widget.coachData.certificate_info,
            ),
            const Divider(),
            _infoRow(
              Icons.payments,
              "Maaş",
              "${widget.coachData.monthly_salary} TL",
            ),
            const Divider(),
            _infoRow(
              Icons.calendar_today,
              "İşe Başlangıç",
              widget.coachData.hired_at.toString().split('T')[0],
            ),
            const Divider(),
            _infoRow(Icons.info, "Hakkımda", widget.coachData.bio),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : "Belirtilmemiş")),
        ],
      ),
    );
  }
}
