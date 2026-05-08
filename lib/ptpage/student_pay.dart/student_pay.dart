import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/datapage/data_page/data.dart';

class AidatPage extends StatelessWidget {
  final Users user;
  final List<Payment> tumOdemeler;
  final List<Group> tumGruplar;
  final List<GroupStudent> tumGroupStudents;

  const AidatPage({
    super.key,
    required this.user,
    required this.tumOdemeler,
    required this.tumGruplar,
    required this.tumGroupStudents,
  });

  // due_date'den yıl çek
  int? _getYearFromDueDate(String dueDate) {
    if (dueDate.isEmpty) return null;
    if (dueDate.contains('-')) {
      return int.tryParse(dueDate.substring(0, 4));
    } else if (dueDate.contains('.') && dueDate.split('.').length == 3) {
      var parts = dueDate.split('.');
      return int.tryParse(parts[2]);
    }
    return null;
  }

  // due_date'den ay çek
  int? _getMonthFromDueDate(String dueDate) {
    if (dueDate.isEmpty) return null;
    if (dueDate.contains('-') && dueDate.length >= 10) {
      return int.tryParse(dueDate.substring(5, 7));
    } else if (dueDate.contains('-') && dueDate.length == 7) {
      return int.tryParse(dueDate.substring(5, 7));
    } else if (dueDate.contains('.') && dueDate.split('.').length == 3) {
      var parts = dueDate.split('.');
      return int.tryParse(parts[1]);
    } else if (dueDate.contains('T')) {
      return int.tryParse(dueDate.substring(5, 7));
    }
    return null;
  }

  String _getStudentGroupId() {
    final relation = tumGroupStudents.firstWhere(
      (r) =>
          r.student_id == user.app &&
          r.is_active.toString().toUpperCase() == "TRUE",
      orElse: () => GroupStudent(
        group_students_id: "",
        groups_id: "",
        student_id: "",
        enrolled_at: "",
        is_active: "",
      ),
    );
    return relation.groups_id;
  }

  double _getMonthlyFee() {
    return double.tryParse(user.amount) ?? 0;
  }

  String _getGroupName() {
    final groupId = _getStudentGroupId();
    if (groupId.isEmpty) return "Atanmamış";
    final group = tumGruplar.firstWhere(
      (g) => g.groups_id == groupId,
      orElse: () => Group(
        groups_id: "",
        branches_id: "",
        coach_id: "",
        sports_id: "",
        name: "Grup Bulunamadı",
        schedule: "",
        capacity: "",
        monthly_fee: "0",
        is_active: "",
      ),
    );
    return group.name;
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM').format(now);
  }

  double _getPaidAmountForMonth(String monthYear) {
    print("========== STUDENT PAY ÖDEME HESAPLAMA ==========");
    print("Aranan dönem: $monthYear");
    print("Toplam ödeme kaydı: ${tumOdemeler.length}");

    double total = 0;
    List<String> targetParts = monthYear.split('-');
    int targetYear = int.parse(targetParts[0]);
    int targetMonth = int.parse(targetParts[1]);

    for (var p in tumOdemeler) {
      print(
        "  Ödeme kontrol: student_id=${p.student_id}, user.app=${user.app}, due_date=${p.due_date}, amount=${p.amount}, status=${p.status}",
      );

      if (p.student_id != user.app) {
        print("    ❌ student_id eşleşmiyor");
        continue;
      }
      if (p.status != "paid") {
        print("    ❌ status paid değil");
        continue;
      }

      int? paymentYear = _getYearFromDueDate(p.due_date);
      int? paymentMonth = _getMonthFromDueDate(p.due_date);

      print("    paymentYear=$paymentYear, paymentMonth=$paymentMonth");

      if (paymentYear != null && paymentMonth != null) {
        if (paymentYear == targetYear && paymentMonth == targetMonth) {
          double amount = double.tryParse(p.amount) ?? 0;
          total += amount;
          print("    ✅ EŞLEŞTİ! Toplam: $total");
        } else {
          print(
            "    ❌ Tarih eşleşmiyor: $paymentYear-$paymentMonth != $targetYear-$targetMonth",
          );
        }
      }
    }

    print("📊 Toplam ödenen: $total TL");
    return total;
  }

  double _getRemainingDebt() {
    final monthlyFee = _getMonthlyFee();
    if (monthlyFee == 0) return 0;
    final paidThisMonth = _getPaidAmountForMonth(_getCurrentMonthYear());
    final remaining = monthlyFee - paidThisMonth;
    return remaining > 0 ? remaining : 0;
  }

  String _getPaymentStatus() {
    final monthlyFee = _getMonthlyFee();
    final paidThisMonth = _getPaidAmountForMonth(_getCurrentMonthYear());

    if (monthlyFee == 0) return "unpaid";
    if (paidThisMonth >= monthlyFee) return "paid";
    if (paidThisMonth > 0) return "partial";
    return "unpaid";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "paid":
        return Colors.green;
      case "partial":
        return Colors.blue;
      case "unpaid":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "paid":
        return "✅ Bu Ay Tamamen Ödendi";
      case "partial":
        return "⚠️ Kısmi Ödeme Yapıldı";
      case "unpaid":
        return "❌ Bu Ay Ödenmedi";
      default:
        return "Belirsiz";
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "Belirsiz";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatMonthYear(String monthYear) {
    if (monthYear.isEmpty || monthYear.length < 7) return monthYear;
    try {
      final parts = monthYear.split('-');
      if (parts.length != 2) return monthYear;
      final year = parts[0];
      final month = int.parse(parts[1]);
      const months = [
        "Ocak",
        "Şubat",
        "Mart",
        "Nisan",
        "Mayıs",
        "Haziran",
        "Temmuz",
        "Ağustos",
        "Eylül",
        "Ekim",
        "Kasım",
        "Aralık",
      ];
      return "${months[month - 1]} $year";
    } catch (e) {
      return monthYear;
    }
  }

  void _showPaymentDetail(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ödeme Detayı"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tutar: ${payment.amount} TL",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _detailRow("Ödeme Yöntemi", payment.payment_method),
            _detailRow("Ödeme Tarihi", _formatDate(payment.paid_date)),
            _detailRow(
              "Dönem",
              _formatMonthYear(payment.due_date.substring(0, 7)),
            ),
            if (payment.note.isNotEmpty) _detailRow("Not", payment.note),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _detayTile(
    String title,
    String value,
    IconData icon, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.teal),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthlyFee = _getMonthlyFee();
    final currentMonth = _getCurrentMonthYear();
    final paidThisMonth = _getPaidAmountForMonth(currentMonth);
    final remainingDebt = _getRemainingDebt();
    final status = _getPaymentStatus();
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final groupName = _getGroupName();

    final odemeler = tumOdemeler.where((p) => p.student_id == user.app).toList()
      ..sort((a, b) => b.paid_date.compareTo(a.paid_date));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Ödeme Bilgilerim"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [statusColor.withOpacity(0.1), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      status == "paid"
                          ? Icons.verified_user
                          : status == "partial"
                          ? Icons.pending_actions
                          : Icons.cancel,
                      size: 80,
                      color: statusColor,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (status == "partial")
                      Text(
                        "Ödenen: $paidThisMonth TL / $monthlyFee TL",
                        style: TextStyle(color: statusColor, fontSize: 16),
                      ),
                    if (status == "partial" && remainingDebt > 0)
                      Text(
                        "Kalan Borç: ${remainingDebt.toStringAsFixed(2)} TL",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    if (status == "unpaid")
                      Text(
                        "$monthlyFee TL ödemeniz bekleniyor",
                        style: TextStyle(color: statusColor, fontSize: 16),
                      ),
                    if (status == "paid")
                      Text(
                        "$monthlyFee TL aylık ücretiniz ödenmiştir.",
                        style: TextStyle(color: statusColor, fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    _detayTile(
                      "Öğrenci",
                      "${user.first_name} ${user.last_name}",
                      Icons.person_outline,
                    ),
                    const Divider(height: 1, indent: 60),
                    _detayTile("Grup", groupName, Icons.group),
                    const Divider(height: 1, indent: 60),
                    _detayTile("Aylık Ücret", "$monthlyFee TL", Icons.money),
                    const Divider(height: 1, indent: 60),
                    _detayTile(
                      "Ödeme Dönemi",
                      _formatMonthYear(currentMonth),
                      Icons.calendar_month,
                    ),
                    const Divider(height: 1, indent: 60),
                    _detayTile(
                      "Bu Ay Ödenen",
                      "$paidThisMonth TL",
                      Icons.payment,
                    ),
                    const Divider(height: 1, indent: 60),
                    _detayTile(
                      "Kalan Borç",
                      remainingDebt > 0
                          ? "${remainingDebt.toStringAsFixed(2)} TL"
                          : "0 TL",
                      Icons.warning_amber,
                      textColor: remainingDebt > 0
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ödeme Geçmişi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (odemeler.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Henüz ödeme kaydı bulunmuyor"),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: odemeler.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final p = odemeler[index];
                          final paymentMonth = p.due_date.length >= 7
                              ? p.due_date.substring(0, 7)
                              : p.due_date;
                          final isCurrentMonth = paymentMonth == currentMonth;
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCurrentMonth
                                    ? statusColor.withOpacity(0.2)
                                    : Colors.teal.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isCurrentMonth ? Icons.star : Icons.receipt,
                                color: isCurrentMonth
                                    ? statusColor
                                    : Colors.teal,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              "${p.amount} TL",
                              style: TextStyle(
                                fontWeight: isCurrentMonth
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${p.payment_method} - ${_formatDate(p.paid_date)}",
                                ),
                                Text(
                                  "Dönem: ${_formatMonthYear(paymentMonth)}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: p.note.isNotEmpty
                                ? Icon(Icons.note, color: Colors.grey, size: 18)
                                : null,
                            onTap: () => _showPaymentDetail(context, p),
                          );
                        },
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
}
