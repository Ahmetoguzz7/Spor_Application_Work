import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';

class YoklamaSayfasi extends StatefulWidget {
  final Group selectedGroup;
  final Users currentUser;

  const YoklamaSayfasi({
    super.key,
    required this.selectedGroup,
    required this.currentUser,
  });

  @override
  _YoklamaSayfasiState createState() => _YoklamaSayfasiState();
}

class _YoklamaSayfasiState extends State<YoklamaSayfasi> {
  List<Map<String, dynamic>> yoklamaListesi = [];
  List<Users> allUsers = [];
  List<GroupStudent> allRelations = [];
  List<Attendance> allAttendances = [];

  bool isLoading = true;
  bool isSaving = false;
  String searchQuery = "";
  String selectedFilter = "Tümü";
  DateTime selectedDate = DateTime.now();

  final List<String> filterOptions = ["Tümü", "Gelenler", "Gelmeyenler"];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        GoogleSheetService.getUsers(),
        GoogleSheetService.getGroupStudents(),
        GoogleSheetService.getAttendancesForGroup(
          widget.selectedGroup.groups_id,
        ),
      ]);

      allUsers = results[0] as List<Users>;
      allRelations = results[1] as List<GroupStudent>;
      allAttendances = results[2] as List<Attendance>;

      print("=== VERİLER YÜKLENDİ ===");
      print("Toplam yoklama: ${allAttendances.length}");

      await _loadAttendanceForDate(selectedDate);

      setState(() => isLoading = false);
    } catch (e) {
      print("Hata: $e");
      setState(() => isLoading = false);
    }
  }

  List<Users> getGroupStudents() {
    final groupRelations = allRelations
        .where(
          (rel) =>
              rel.groups_id == widget.selectedGroup.groups_id &&
              rel.is_active.toUpperCase() == "TRUE",
        )
        .toList();

    final studentIds = groupRelations.map((rel) => rel.student_id).toList();

    final students = allUsers
        .where(
          (user) =>
              studentIds.contains(user.app) &&
              user.role.toLowerCase() == "student",
        )
        .toList();

    return students;
  }

  Future<void> _loadAttendanceForDate(DateTime date) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    print("🔍 TARİH: $formattedDate için yoklama çekiliyor...");
    print("📊 allAttendances uzunluğu: ${allAttendances.length}");

    // 🔥 Tarih karşılaştırmasını DÜZGÜN YAP
    final todayAttendances = allAttendances.where((a) {
      final attDate = a.attendance_date.split('T')[0];
      return attDate == formattedDate;
    }).toList();

    print(
      "📅 $formattedDate tarihinde ${todayAttendances.length} yoklama kaydı bulundu",
    );

    final students = getGroupStudents();
    final List<Map<String, dynamic>> tempList = [];

    for (var ogrenci in students) {
      Attendance? foundAttendance;
      for (var att in todayAttendances) {
        if (att.student_id == ogrenci.app) {
          foundAttendance = att;
          break;
        }
      }

      // 🔥 KRİTİK: status değerini doğru parse et
      bool isPresent = false;
      if (foundAttendance != null) {
        final statusValue = foundAttendance.status;
        print(
          "🔍 ${ogrenci.first_name} ${ogrenci.last_name}: status değeri = '$statusValue'",
        );

        // Hem string "TRUE" hem de bool true kontrolü
        if (statusValue == true ||
            statusValue == "TRUE" ||
            statusValue == "true" ||
            statusValue.toString().toUpperCase() == "TRUE") {
          isPresent = true;
        }
      }

      tempList.add({
        "student": ogrenci,
        "is_present": isPresent,
        "note": foundAttendance?.note ?? "",
        "has_attendance": foundAttendance != null,
      });
    }

    setState(() {
      yoklamaListesi = tempList;
    });

    print(
      "📊 Toplam ${tempList.length} öğrenci, Gelen: ${tempList.where((e) => e["is_present"] == true).length}",
    );
  }

  Future<void> _saveAttendance() async {
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (!isToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sadece bugün için yoklama alabilirsiniz!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Onay dialogu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yoklamayı Kaydet"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📊 ${widget.selectedGroup.name}"),
            const SizedBox(height: 8),
            Text("✅ Gelen: $presentCount öğrenci"),
            Text("❌ Gelmeyen: $absentCount öğrenci"),
            const SizedBox(height: 16),
            const Text("Yoklamayı kaydetmek istediğinize emin misiniz?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSaving = true);

    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    int savedCount = 0;

    for (var item in yoklamaListesi) {
      final Users ogrenci = item["student"];
      final isPresent = item["is_present"] == true;
      final note = item["note"] ?? "";

      final attendance = Attendance(
        attendances_id: "",
        groups_id: widget.selectedGroup.groups_id,
        student_id: ogrenci.app,
        taken_by: widget.currentUser.app,
        attendance_date: formattedDate,
        status: isPresent ? "TRUE" : "FALSE",
        note: note,
      );

      bool success = await GoogleSheetService.saveAttendance(attendance);
      if (success) savedCount++;
    }

    // Verileri tazele
    allAttendances = await GoogleSheetService.getAttendancesForGroup(
      widget.selectedGroup.groups_id,
    );
    await _loadAttendanceForDate(selectedDate);

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ $savedCount öğrencinin yoklaması kaydedildi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _changeDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
      });
      await _loadAttendanceForDate(picked);
      setState(() => isLoading = false);
    }
  }

  void _showNoteDialog(Map<String, dynamic> item, int index) {
    final ogrenci = item["student"] as Users;
    final TextEditingController controller = TextEditingController(
      text: item["note"],
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${ogrenci.first_name} ${ogrenci.last_name}"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Not ekleyin...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => yoklamaListesi[index]["note"] = controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Not eklendi"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredList {
    var list = yoklamaListesi;

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      list = list.where((item) {
        final ogrenci = item["student"] as Users;
        return ogrenci.first_name.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            ogrenci.last_name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Durum filtresi
    if (selectedFilter == "Gelenler") {
      list = list.where((item) => item["is_present"] == true).toList();
    } else if (selectedFilter == "Gelmeyenler") {
      list = list.where((item) => item["is_present"] == false).toList();
    }

    return list;
  }

  int get presentCount =>
      yoklamaListesi.where((item) => item["is_present"] == true).length;
  int get absentCount =>
      yoklamaListesi.where((item) => item["is_present"] == false).length;
  int get totalCount => yoklamaListesi.length;
  double get presentPercentage =>
      totalCount > 0 ? (presentCount / totalCount) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.selectedGroup.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}${isToday ? " (Bugün)" : ""}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _changeDate,
            tooltip: "Tarih Seç",
          ),
          if (isToday && !isLoading && !isSaving)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAttendance,
              tooltip: "Yoklamayı Kaydet",
            ),
          if (isSaving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadAttendanceForDate(selectedDate),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : totalCount == 0
            ? _buildEmptyWidget()
            : Column(
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 12),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 12),
                  Expanded(child: _buildStudentList()),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.indigoAccent],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            "Toplam",
            totalCount.toString(),
            Icons.people,
            Colors.white,
          ),
          _buildStatItem(
            "Gelen",
            presentCount.toString(),
            Icons.check_circle,
            Colors.green.shade300,
          ),
          _buildStatItem(
            "Gelmeyen",
            absentCount.toString(),
            Icons.cancel,
            Colors.red.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Arama kutusu
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Öğrenci ara...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filtre butonu
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: selectedFilter,
              items: filterOptions.map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          filter == "Tümü"
                              ? Icons.list_alt
                              : filter == "Gelenler"
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color: filter == "Tümü"
                              ? Colors.blue
                              : filter == "Gelenler"
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(filter),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedFilter = value!),
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list),
              selectedItemBuilder: (context) {
                return filterOptions.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          selectedFilter == "Tümü"
                              ? Icons.list_alt
                              : selectedFilter == "Gelenler"
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color: selectedFilter == "Tümü"
                              ? Colors.blue
                              : selectedFilter == "Gelenler"
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(selectedFilter),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    final filtered = _filteredList;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              selectedFilter == "Gelenler"
                  ? "Bugün gelen öğrenci yok"
                  : selectedFilter == "Gelmeyenler"
                  ? "Bugün gelmeyen öğrenci yok"
                  : "Öğrenci bulunamadı",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final ogrenci = item["student"] as Users;
        final originalIndex = yoklamaListesi.indexOf(item);
        final isPresent = item["is_present"] == true;
        final hasNote = item["note"].toString().isNotEmpty;
        final isToday =
            selectedDate.year == DateTime.now().year &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.day == DateTime.now().day;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isPresent ? Colors.green.shade50 : Colors.white,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                    radius: 22,
                    child: Text(
                      ogrenci.first_name.isNotEmpty
                          ? ogrenci.first_name[0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: isPresent
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    "${ogrenci.first_name} ${ogrenci.last_name}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: isPresent
                          ? TextDecoration.none
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: hasNote
                      ? Text(
                          item["note"],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.indigo.shade600,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Not butonu
                      IconButton(
                        icon: Icon(
                          Icons.note_alt,
                          color: hasNote ? Colors.indigo : Colors.grey.shade400,
                          size: 22,
                        ),
                        onPressed: () => _showNoteDialog(item, originalIndex),
                        tooltip: "Not Ekle",
                      ),
                      // Yoklama butonu (sadece bugün için aktif)
                      if (isToday)
                        Switch(
                          value: isPresent,
                          onChanged: (val) {
                            setState(() {
                              yoklamaListesi[originalIndex]["is_present"] = val;
                            });
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          activeTrackColor: Colors.green.shade200,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPresent
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPresent ? "Geldi" : "Gelmedi",
                            style: TextStyle(
                              color: isPresent ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Not varsa göster
                if (hasNote && item["note"].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_note,
                            size: 18,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item["note"],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Bu grupta henüz öğrenci yok",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            "Öğrenciler atandıktan sonra yoklama alabilirsiniz",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
