import 'package:flutter/material.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/datapage/fetch_data_page.dart';

class DuyurularPage extends StatefulWidget {
  final List<Notifications> tumDuyurular;
  final Users currentUser;
  final Coach? currentCoach;

  const DuyurularPage({
    super.key,
    required this.tumDuyurular,
    required this.currentUser,
    this.currentCoach,
  });

  @override
  State<DuyurularPage> createState() => _DuyurularPageState();
}

class _DuyurularPageState extends State<DuyurularPage> {
  List<Notifications> filteredNotifications = [];
  List<String> kullaniciGruplari = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _kullaniciGruplariniGetir();
  }

  Future<void> _kullaniciGruplariniGetir() async {
    try {
      print("========== GRUP BULMA ==========");
      print(
        "Kullanıcı: ${widget.currentUser.first_name} ${widget.currentUser.last_name}",
      );
      print("Rol: ${widget.currentUser.role}");

      if (widget.currentCoach != null &&
          widget.currentCoach!.coach_id.isNotEmpty) {
        final groups = await GoogleSheetService.getGroupsByCoach(
          widget.currentCoach!.coach_id,
        );
        kullaniciGruplari = groups.map((g) => g.groups_id.toString()).toList();
        print("📚 Antrenörün grupları: $kullaniciGruplari");
      } else {
        final groupRelations =
            await GoogleSheetService.getGroupStudentsByStudentId(
              widget.currentUser.app,
            );
        kullaniciGruplari = groupRelations
            .where((rel) => rel.is_active.toString().toUpperCase() == "TRUE")
            .map((rel) => rel.groups_id.toString())
            .toList();
        print("📚 Öğrencinin aktif grupları: $kullaniciGruplari");
      }

      _filtreleDuyurular();
    } catch (e) {
      print("Grup yükleme hatası: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filtreleDuyurular() {
    print("========== DUYURU FİLTRELEME ==========");
    print("Toplam duyuru: ${widget.tumDuyurular.length}");
    print("Kullanıcı grupları: $kullaniciGruplari");

    filteredNotifications = widget.tumDuyurular.where((d) {
      final recipientId = d.recipient_id?.toString() ?? "";

      print("Duyuru: ${d.title} -> recipient_id: '$recipientId'");

      // 1. Herkese açık
      if (recipientId == "all" ||
          recipientId == "Tümü" ||
          recipientId == "ALL") {
        print("  ✅ Herkese açık");
        return true;
      }

      // 2. Gruba özel (kullanıcının grubuyla eşleşen)
      if (recipientId.isNotEmpty && kullaniciGruplari.contains(recipientId)) {
        print("  ✅ Grup eşleşti: $recipientId");
        return true;
      }

      print("  ❌ Eşleşmedi");
      return false;
    }).toList();

    filteredNotifications.sort((a, b) {
      final dateA = _parseDate(a.sent_at);
      final dateB = _parseDate(b.sent_at);
      return dateB.compareTo(dateA);
    });

    print("📊 Filtrelenmiş duyuru sayısı: ${filteredNotifications.length}");
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime(2000);
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime(2000);
    }
  }

  Future<void> _markAsRead(Notifications duyuru) async {
    if (duyuru.is_read?.toLowerCase() == "true") return;

    await GoogleSheetService.markNotificationAsRead(
      duyuru.notifications_id,
      widget.currentUser.app,
    );

    setState(() {
      final index = filteredNotifications.indexWhere(
        (d) => d.notifications_id == duyuru.notifications_id,
      );
      if (index != -1) {
        final updatedDuyuru = Notifications(
          notifications_id: duyuru.notifications_id,
          sender_id: duyuru.sender_id,
          recipient_id: duyuru.recipient_id,
          title: duyuru.title,
          message: duyuru.message,
          type: duyuru.type,
          is_read: "TRUE",
          sent_at: duyuru.sent_at,
          groups_id: duyuru.groups_id,
        );
        filteredNotifications[index] = updatedDuyuru;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Duyurular & Bildirimler",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredNotifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final duyuru = filteredNotifications[index];
                return GestureDetector(
                  onTap: () => _markAsRead(duyuru),
                  child: _buildDuyuruCard(duyuru),
                );
              },
            ),
    );
  }

  Widget _buildDuyuruCard(Notifications duyuru) {
    bool isUnread = duyuru.is_read?.toLowerCase() != "true";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isUnread
            ? Border.all(
                color: _getIconColor(duyuru.type).withOpacity(0.3),
                width: 1.5,
              )
            : Border.all(color: Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: _getIconColor(duyuru.type).withOpacity(0.1),
          child: Icon(_getIcon(duyuru.type), color: _getIconColor(duyuru.type)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                duyuru.title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (isUnread)
              const Icon(
                Icons.fiber_manual_record,
                color: Colors.blue,
                size: 12,
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                duyuru.message,
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tip: ${_getTypeDisplay(duyuru.type)}",
                    style: TextStyle(
                      fontSize: 11,
                      color: _getIconColor(duyuru.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatDate(duyuru.sent_at),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeDisplay(String type) {
    switch (type.toLowerCase()) {
      case 'payment_reminder':
        return 'Ödeme Hatırlatması';
      case 'attendance_alert':
        return 'Antrenman İptali';
      case 'announcement':
        return 'Duyuru';
      case 'urgent':
        return 'Acil';
      default:
        return type;
    }
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

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'payment_reminder':
        return Icons.account_balance_wallet;
      case 'urgent':
        return Icons.priority_high;
      case 'announcement':
        return Icons.emoji_events;
      case 'attendance_alert':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'payment_reminder':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'announcement':
        return Colors.green;
      case 'attendance_alert':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Henüz bir duyuru bulunmuyor.",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
