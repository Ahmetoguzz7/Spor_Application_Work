/*
import 'package:flutter/material.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/datapage/data_page/data.dart';

class StudentYoklamaPage extends StatefulWidget {
  final String studentId;
  const StudentYoklamaPage({super.key, required this.studentId});

  @override
  State<StudentYoklamaPage> createState() => _StudentYoklamaPageState();
}

class _StudentYoklamaPageState extends State<StudentYoklamaPage> {
  List<Attendance> attendances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    var data = await GoogleSheetService.getAttendances(widget.studentId);
    if (mounted) {
      setState(() {
        attendances = data
            .where((a) => a.studentId == widget.studentId)
            .toList();
        isLoading = false;
      });
    }
  }

  void _addAttendance(String status) async {
    var newRecord = {
      "attendance_id": "ATT-${DateTime.now().millisecondsSinceEpoch}",
      "student_id": widget.studentId,
      "attendance_date":
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
      "status": status == "Geldi" ? "true" : "false",
      "notes": 'Mobil Uygulama',
      "group_id": "GR-01",
      "taken_by": "Coach-Admin",
    };

    bool success = await GoogleSheetService.saveAttendance(
      Attendance.fromJson(newRecord),
    );
    if (success) {
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Başarıyla İşlendi!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = attendances.where((a) => a.status == true).length;
    double ratio = attendances.isEmpty
        ? 0
        : (presentCount / attendances.length) * 100;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Yoklama Takibi"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeaderCard(ratio, presentCount, attendances.length),
                    const SizedBox(height: 25),
                    _buildAttendanceList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAttendanceDialog,
        label: const Text("Yeni Kayıt"),
        icon: const Icon(Icons.add_task),
      ),
    );
  }

  // SENİN TASARIMIN BURADA KANKA:
  Widget _buildHeaderCard(double ratio, int present, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[400]!, Colors.indigo[700]!],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Katılım Performansı",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                "%${ratio.toInt()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$total Antrenman / $present Katılım",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
          CircularProgressIndicator(
            value: ratio / 100,
            color: Colors.white,
            backgroundColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendances.length,
      itemBuilder: (context, index) {
        final a = attendances[index];
        return Card(
          child: ListTile(
            leading: Icon(
              a.status ? Icons.check : Icons.close,
              color: a.status ? Colors.green : Colors.red,
            ),
            title: Text(a.date),
            trailing: Text(
              a.status ? "Geldi" : "Gelmedi",
              style: TextStyle(color: a.status ? Colors.green : Colors.red),
            ),
          ),
        );
      },
    );
  }

  void _showAttendanceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addAttendance("Geldi"),
                child: const Text("GELDİ"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addAttendance("Gelmedi"),
                child: const Text("GELMEDİ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/
import 'package:flutter/material.dart';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/datapage/data_page/data.dart';

class StudentYoklamaPage extends StatefulWidget {
  final String studentId;
  const StudentYoklamaPage({super.key, required this.studentId});

  @override
  State<StudentYoklamaPage> createState() => _StudentYoklamaPageState();
}

class _StudentYoklamaPageState extends State<StudentYoklamaPage> {
  List<Attendance> attendances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final allAttendances = await GoogleSheetService.getAttendances();
    final filtered = allAttendances
        .where((a) => a.student_id == widget.studentId)
        .toList();

    if (mounted) {
      setState(() {
        attendances = filtered;
        isLoading = false;
      });
    }
  }

  void _addAttendance(String status) async {
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final newAttendance = Attendance(
      attendances_id: "",
      groups_id: "GR-01",
      student_id: widget.studentId,
      taken_by: "Coach-Admin",
      attendance_date: formattedDate,
      status: status == "Geldi" ? "TRUE" : "FALSE",
      note: "Mobil Uygulama",
    );

    bool success = await GoogleSheetService.saveAttendance(newAttendance);

    if (success) {
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Başarıyla İşlendi!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = attendances.where((a) => a.status == "TRUE").length;
    double ratio = attendances.isEmpty
        ? 0
        : (presentCount / attendances.length) * 100;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Yoklama Takibi"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeaderCard(ratio, presentCount, attendances.length),
                    const SizedBox(height: 25),
                    _buildAttendanceList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAttendanceDialog,
        label: const Text("Yeni Kayıt"),
        icon: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildHeaderCard(double ratio, int present, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[400]!, Colors.indigo[700]!],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Katılım Performansı",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                "%${ratio.toInt()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$total Antrenman / $present Katılım",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
          CircularProgressIndicator(
            value: ratio / 100,
            color: Colors.white,
            backgroundColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendances.length,
      itemBuilder: (context, index) {
        final a = attendances[index];
        final isPresent = a.status == "TRUE";

        return Card(
          child: ListTile(
            leading: Icon(
              isPresent ? Icons.check : Icons.close,
              color: isPresent ? Colors.green : Colors.red,
            ),
            title: Text(a.attendance_date),
            trailing: Text(
              isPresent ? "Geldi" : "Gelmedi",
              style: TextStyle(color: isPresent ? Colors.green : Colors.red),
            ),
          ),
        );
      },
    );
  }

  void _showAttendanceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addAttendance("Geldi"),
                child: const Text("GELDİ"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addAttendance("Gelmedi"),
                child: const Text("GELMEDİ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
