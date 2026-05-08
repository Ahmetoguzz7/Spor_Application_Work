import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Eklendi
import 'package:open_file_plus/open_file_plus.dart'; // Güncellendi
import 'dart:io';
import 'dart:convert';

// Kendi sayfaların
import 'package:my_app/managerpage/manager_interface.dart';
import 'package:my_app/managerpage/signuppage/sign_admin.dart';
import 'package:my_app/userInterfacepage/pt_login_page.dart/pt_signup.dart';
import 'package:my_app/ptpage/user_loginandsignup_page/loginandsignup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 👇 BİLGİLERİNİ BURAYA DOĞRU GİR
const String GITHUB_USERNAME = "kullanici_adin";
const String GITHUB_REPO = "proje_adin";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const RoleSelectPage(),
    );
  }
}

class RoleSelectPage extends StatefulWidget {
  // Update kontrolü için StatefulWidget yaptık
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  @override
  void initState() {
    super.initState();
    // Uygulama açıldıktan hemen sonra kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) => checkForUpdate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Türünü Seç"),
        centerTitle: true,
        actions: [
          FutureBuilder<String>(
            future: getCurrentVersion(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(child: Text("v${snapshot.data ?? '...'}")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Ekran taşmalarına karşı
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            roleCard(
              context,
              title: "Kullanıcı Girişi",
              subtitle: "Sporcular ve Veliler İçin",
              icon: Icons.person,
              color: Colors.blue.shade100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthSelectionPage()),
              ),
            ),
            const SizedBox(height: 16),
            roleCard(
              context,
              title: "Koç Girişi",
              subtitle: "Antrenörler İçin",
              icon: Icons.sports,
              color: Colors.orange.shade100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PtSignUp()),
              ),
            ),
            const SizedBox(height: 16),
            roleCard(
              context,
              title: "Yönetici Girişi",
              subtitle: "Sistem ve Şube Yönetimi",
              icon: Icons.admin_panel_settings,
              color: Colors.red.shade100,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget roleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ==================== GÜNCELLEME MANTIĞI ====================

Future<String> getCurrentVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<Map<String, dynamic>?> getLatestReleaseFromGitHub() async {
  try {
    final url = Uri.parse(
      "https://api.github.com/repos/$GITHUB_USERNAME/$GITHUB_REPO/releases/latest",
    );
    // GitHub API bazen User-Agent başlığı ister, eklemek güvenlidir.
    final response = await http.get(
      url,
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final assets = data['assets'] as List;

      final apkAsset = assets.firstWhere(
        (asset) => asset['name'].toString().endsWith('.apk'),
        orElse: () => null,
      );

      if (apkAsset != null) {
        return {
          'version': data['tag_name'].toString().replaceAll(
            RegExp(r'[a-zA-Z]'),
            '',
          ),
          'downloadUrl': apkAsset['browser_download_url'],
          'releaseNotes':
              data['body'] ??
              'Hata düzeltmeleri ve performans iyileştirmeleri.',
        };
      }
    }
  } catch (e) {
    debugPrint("GitHub Error: $e");
  }
  return null;
}

bool isNewerVersion(String current, String latest) {
  List<int> parseVersion(String v) =>
      v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final v1 = parseVersion(current);
  final v2 = parseVersion(latest);

  for (var i = 0; i < v2.length; i++) {
    int v1Part = i < v1.length ? v1[i] : 0;
    if (v2[i] > v1Part) return true;
    if (v2[i] < v1Part) return false;
  }
  return false;
}

Future<void> checkForUpdate() async {
  final current = await getCurrentVersion();
  final latestData = await getLatestReleaseFromGitHub();

  if (latestData != null && isNewerVersion(current, latestData['version'])) {
    showUpdateDialog(latestData);
  }
}

void showUpdateDialog(Map<String, dynamic> release) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Güncelleme Mevcut! 🚀"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Yeni sürüm: v${release['version']}"),
            const SizedBox(height: 10),
            const Text(
              "Yenilikler:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(release['releaseNotes']),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Daha Sonra"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            downloadAndInstallApk(release['downloadUrl']);
          },
          child: const Text("Şimdi Güncelle"),
        ),
      ],
    ),
  );
}

Future<void> downloadAndInstallApk(String url) async {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  // Yükleme göstergesi
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Dosya indiriliyor, lütfen bekleyin..."),
          ],
        ),
      ),
    ),
  );

  try {
    final response = await http.get(Uri.parse(url));
    final directory =
        await getExternalStorageDirectory(); // Android için daha güvenli
    final filePath = "${directory!.path}/update.apk";
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    Navigator.pop(context); // Loading'i kapat

    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw result.message;
    }
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Hata: $e")));
  }
}
