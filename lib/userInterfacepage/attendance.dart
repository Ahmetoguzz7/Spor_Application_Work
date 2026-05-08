import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/userInterfacepage/attendancedetail.dart';

class GrupListesiSayfasi extends StatefulWidget {
  final Coach coache;
  final Users user;

  const GrupListesiSayfasi({
    super.key,
    required this.coache,
    required this.user,
  });

  @override
  State<GrupListesiSayfasi> createState() => _GrupListesiSayfasiState();
}

class _GrupListesiSayfasiState extends State<GrupListesiSayfasi> {
  List<Group> gruplar = [];
  bool isLoading = true;
  String? errorMessage;
  Map<String, bool> todayAttendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _loadGroupsAndAttendance();
  }

  Future<void> _loadGroupsAndAttendance() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final groups = await GoogleSheetService.getGroupsByCoach(
        widget.coache.coach_id,
      );
      gruplar = groups;

      final today = DateTime.now();
      final formattedToday =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      for (var grup in gruplar) {
        final attendances = await GoogleSheetService.getAttendancesForGroup(
          grup.groups_id,
        );
        final todayAttendance = attendances.any(
          (a) => a.attendance_date == formattedToday,
        );
        todayAttendanceStatus[grup.groups_id] = todayAttendance;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadGroupsAndAttendance();
  }

  String _getGroupTime(String schedule) {
    if (schedule.contains(RegExp(r'\d{1,2}:\d{2}'))) {
      final match = RegExp(r'\d{1,2}:\d{2}').firstMatch(schedule);
      if (match != null) return match.group(0)!;
    }
    return schedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          "Gruplarım",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: "Yenile",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? _buildErrorWidget()
            : gruplar.isEmpty
            ? _buildEmptyWidget()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gruplar.length,
                itemBuilder: (context, index) {
                  final grup = gruplar[index];
                  final hasAttendanceToday =
                      todayAttendanceStatus[grup.groups_id] ?? false;
                  return _buildGroupCard(grup, hasAttendanceToday);
                },
              ),
      ),
    );
  }

  Widget _buildGroupCard(Group grup, bool hasAttendanceToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // 🔥🔥🔥 DÜZELTİLMİŞ NAVIGASYON 🔥🔥🔥
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YoklamaSayfasi(
                  selectedGroup: grup,
                  currentUser: widget.user,
                ),
              ),
            ).then((_) => _refreshData());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.indigo, Colors.indigoAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.sports_basketball,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            grup.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 10,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _getGroupTime(grup.schedule),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.people,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "Kapasite: ${grup.capacity}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasAttendanceToday
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasAttendanceToday
                                ? Icons.check_circle
                                : Icons.warning_amber,
                            size: 16,
                            color: hasAttendanceToday
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasAttendanceToday
                                ? "Yoklama alındı"
                                : "Yoklama alınmadı",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: hasAttendanceToday
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.calendar_today,
                      grup.schedule,
                      Colors.indigo.shade100,
                      Colors.indigo,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.payments,
                      "${grup.monthly_fee} TL",
                      Colors.green.shade100,
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            "Yoklama Al",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.indigo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            "Bir hata oluştu",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? "Bilinmeyen hata",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text("Tekrar Dene"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_off, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            "Henüz size atanmış bir grup bulunamadı",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Yöneticiniz sizi bir gruba atayınca burada görünecektir",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
