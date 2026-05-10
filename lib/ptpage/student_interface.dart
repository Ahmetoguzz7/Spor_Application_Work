import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_app/datapage/data_page/data.dart';
import 'package:my_app/main.dart';
import 'package:my_app/parent/parent_page.dart';
import 'package:my_app/ptpage/student_attendance_page/student_attendance.dart';
import 'package:my_app/ptpage/student_info.dart';
import 'package:my_app/ptpage/student_pay.dart/student_pay.dart';

import 'package:my_app/ptpage/user_sign_up.dart/student_signup.dart';
import 'package:my_app/userInterfacepage/notifications/pt_natifications.dart';
import 'package:my_app/datapage/fetch_data_page.dart';

class UserInterface extends StatefulWidget {
  final Users user;
  final List<Notifications> tumBildirimler;

  const UserInterface({
    super.key,
    required this.user,
    this.tumBildirimler = const [],
  });

  @override
  State<UserInterface> createState() => _UserInterfaceState();
}

class _UserInterfaceState extends State<UserInterface> {
  List<Users> bagliCocuklar = [];
  Users? bagliVeli;
  Coach? currentCoach;
  bool isLoading = false;
  int _currentCardIndex = 0;

  List<Payment> allPayments = [];
  List<Group> allGroups = [];
  List<GroupStudent> allRelations = [];
  bool isLoadingPaymentData = true;

  @override
  void initState() {
    super.initState();
    print("🔥 GELEN USER: ${widget.user.toJson()}");
    print("🔥 USER APP: '${widget.user.app}'");
    print("🔥 USER ID: '${widget.user.app}'");
    // ...

    _sayfaVerileriniYukle();
    _loadCurrentCoach();
    _loadPaymentData();
  }

  Future<void> _openNotificationsPage(BuildContext context) async {
    // 🔥 ÖNCE TÜM DUYURULARI ÇEK
    final allNotifications = await GoogleSheetService.getNotifications(
      userId: widget.user.branches_id,
    );

    if (!context.mounted) return;

    final isCoach =
        widget.user.role.toLowerCase() == 'coach' ||
        widget.user.role.toLowerCase() == 'antrenör';

    if (isCoach && currentCoach != null && currentCoach!.coach_id.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DuyurularPage(
            tumDuyurular: allNotifications, // 🔥 EKLENDİ!
            currentUser: widget.user,
            currentCoach: currentCoach!,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DuyurularPage(
            tumDuyurular: allNotifications, // 🔥 EKLENDİ!
            currentUser: widget.user,
            currentCoach: null,
          ),
        ),
      );
    }
  }

  Future<void> _loadPaymentData() async {
    try {
      print("📡 Ödeme verileri çekiliyor...");
      final payments = await GoogleSheetService.getPayments();
      final groups = await GoogleSheetService.getGroups();
      final relations = await GoogleSheetService.getGroupStudents();

      setState(() {
        allPayments = payments;
        allGroups = groups;
        allRelations = relations;
        isLoadingPaymentData = false;
      });

      print(
        "✅ Ödeme verileri yüklendi: ${payments.length} ödeme, ${groups.length} grup",
      );
    } catch (e) {
      print("❌ Ödeme verileri yüklenemedi: $e");
      setState(() => isLoadingPaymentData = false);
    }
  }

  Future<void> _loadCurrentCoach() async {
    try {
      final coaches = await GoogleSheetService.getCoaches();
      final coach = coaches.firstWhere(
        (c) => c.user_id == widget.user.app,
        orElse: () => Coach(
          coach_id: "",
          user_id: "",
          branches_id: "",
          sports_id: "",
          bio: "",
          certificate_info: "",
          monthly_salary: "",
          hired_at: "",
        ),
      );
      setState(() {
        currentCoach = coach;
      });
    } catch (e) {
      print("Coach yüklenemedi: $e");
    }
  }

  void _sayfaVerileriniYukle() {
    bool isParent =
        widget.user.role.toLowerCase() == 'parent' ||
        widget.user.role.toLowerCase() == 'veli';

    if (isParent) {
      _loadChildren();
    } else {
      _checkAndLoadParent();
    }
  }

  Future<void> _checkAndLoadParent() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      List<dynamic> bridgeData = await GoogleSheetService.fetchTable(
        "parent_student",
      );
      var link = bridgeData.firstWhere(
        (row) => row['student_id'].toString() == widget.user.app.toString(),
        orElse: () => null,
      );

      if (link != null) {
        String parentId = link['parent_id'].toString();
        List<Users> allUsers = await GoogleSheetService.getUsers();
        setState(() {
          bagliVeli = allUsers.firstWhere((u) => u.app.toString() == parentId);
        });
      }
    } catch (e) {
      print("Veli getirme hatası: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadChildren() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      List<dynamic> bridgeData = await GoogleSheetService.fetchTable(
        "parent_student",
      );
      List<String> myStudentIds = bridgeData
          .where(
            (row) => row['parent_id'].toString() == widget.user.app.toString(),
          )
          .map((row) => row['student_id'].toString())
          .toList();

      if (myStudentIds.isNotEmpty) {
        List<Users> allUsers = await GoogleSheetService.getUsers();
        setState(() {
          bagliCocuklar = allUsers
              .where((u) => myStudentIds.contains(u.app.toString()))
              .toList();
        });
      }
    } catch (e) {
      print("Hata: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isParent =
        widget.user.role.toLowerCase() == 'parent' ||
        widget.user.role.toLowerCase() == 'veli';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isParent ? "Veli Portföyü" : "Sporcu Paneli"),
        centerTitle: true,
        backgroundColor: Colors.orange[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RoleSelectPage()),
          ),
        ),
      ),

      body: isLoading || isLoadingPaymentData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (isParent) _buildParentVault() else _buildUserHeader(),
                  if (!isParent && bagliVeli != null)
                    _buildSwitchToParentButton(),
                  const SizedBox(height: 10),
                  _buildMenuGrid(isParent),
                ],
              ),
            ),
    );
  }

  Widget _buildParentVault() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.orange[800],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              if (bagliCocuklar.isEmpty)
                _buildEmptyWallet()
              else
                _buildChildrenCarousel(),
              const SizedBox(height: 25),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (bagliCocuklar.isNotEmpty) _buildChildDashboard(),
      ],
    );
  }

  Widget _buildChildrenCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            onPageChanged: (index, _) =>
                setState(() => _currentCardIndex = index),
          ),
          items: bagliCocuklar
              .map((child) => _buildBankStyleCard(child))
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bagliCocuklar.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                  _currentCardIndex == entry.key ? 0.9 : 0.4,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchToParentButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VeliAnaSayfa(veli: bagliVeli!)),
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[900]!, Colors.black],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Row(
            children: [
              const Icon(Icons.family_restroom, color: Colors.orange, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bağlı Veli Hesabı",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      "${bagliVeli!.first_name} ${bagliVeli!.last_name}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.orange,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(bool isParent) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _menuCard(
            "Ders Yoklama",
            Icons.check_circle_outline,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentAttendancePage(student: widget.user),
              ),
            ),
          ),
          _menuCard(
            "Aylık Aidat",
            Icons.payments_outlined,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AidatPage(
                  user: widget.user,
                  tumOdemeler: allPayments,
                  tumGruplar: allGroups,
                  tumGroupStudents: allRelations,
                ),
              ),
            ),
          ),
          _menuCard(
            "Duyurular",
            Icons.campaign_outlined,
            Colors.blue,
            () => _openNotificationsPage(context),
          ),
          _menuCard(
            "Kişisel Bilgiler",
            Icons.badge_outlined,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KisiselBilgilerPage(user: widget.user),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankStyleCard(Users child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueGrey[800]!, Colors.black]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "SPORCU KARTI",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            "${child.first_name} ${child.last_name}".toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "ID: ${child.app}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[800],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.user.first_name} ${widget.user.last_name}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Şube: ${widget.user.branches_id}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChildDashboard() {
    Users selected = bagliCocuklar[_currentCardIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${selected.first_name} Özeti",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _statusCard(
                  "Son Yoklama",
                  "Geldi",
                  Icons.check,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statusCard(
                  "Aidat",
                  "Ödendi",
                  Icons.payment,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            val,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWallet() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        "Henüz bir sporcu hesabı bağlanmamış.",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  void _veliBaglamaDialog() {
    final TextEditingController _phoneController = TextEditingController();
    bool _isSearching = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sistemde kayıtlı olan velinizin telefon numarasını girerek aile portföyüne katılabilirsiniz.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  labelText: "Veli Telefon Numarası",
                  hintText: "05xx xxx xx xx",
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange[800]!,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSearching
                  ? null
                  : () async {
                      final phone = _phoneController.text.trim();
                      if (phone.isEmpty) return;

                      setDialogState(() => _isSearching = true);

                      try {
                        List<Users> allUsers =
                            await GoogleSheetService.getUsers();

                        var foundParent = allUsers.firstWhere(
                          (u) =>
                              u.phone == phone &&
                              (u.role.toLowerCase() == 'parent' ||
                                  u.role.toLowerCase() == 'veli'),
                          orElse: () => throw Exception("Veli bulunamadı"),
                        );

                        await GoogleSheetService.insertData("parent_student", {
                          "parent_id": foundParent.app,
                          "student_id": widget.user.app,
                        });

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${foundParent.first_name} ${foundParent.last_name} veliniz olarak bağlandı!",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _checkAndLoadParent();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Hata: Bu numaraya sahip bir veli bulunamadı.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setDialogState(() => _isSearching = false);
                      }
                    },
              child: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Bul ve Eşleş",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
