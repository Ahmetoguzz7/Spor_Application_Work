import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:my_app/datapage/fetch_data_page.dart';
import 'package:my_app/local/local_db.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final LocalDatabaseService _localDB = LocalDatabaseService();
  bool _isSyncing = false;

  // =========================================================================
  // VERİ ÇEKME (ÖNCE LOCAL, SONRA API)
  // =========================================================================

  Future<List<T>> getData<T>({
    required String tableName,
    required String apiEndpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Duration cacheDuration = const Duration(minutes: 5),
    bool forceRefresh = false,
  }) async {
    // Force refresh varsa local'i temizle
    if (forceRefresh) {
      await _localDB.clearTable(tableName);
    }

    // 1. ÖNCE LOCAL'DEN AL
    final localData = await _localDB.getAll(tableName);

    // Cache süresi kontrolü
    if (!forceRefresh && localData.isNotEmpty) {
      print("📦 LOCAL'DEN GETİRİLDİ: $tableName (${localData.length} kayıt)");
      return localData.map((item) => fromJson(item)).toList();
    }

    // 2. LOCAL BOŞSA VEYA SÜRESİ GEÇTİYSE API'DEN ÇEK
    print("🌐 API'DEN ÇEKİLİYOR: $tableName");

    final networkData = await _fetchFromApi(apiEndpoint);

    // 3. LOCAL'E KAYDET
    for (var item in networkData) {
      final id = _getIdFromItem(tableName, item);
      await _localDB.insertOrUpdate(tableName, id, item);
    }

    await _localDB.addSyncLog(tableName, "success", networkData.length);

    return networkData.map((item) => fromJson(item)).toList();
  }

  String _getIdFromItem(String tableName, Map<String, dynamic> item) {
    switch (tableName) {
      case 'users':
        return item['app']?.toString() ?? '';
      case 'groups':
        return item['groups_id']?.toString() ?? '';
      case 'payments':
        return item['payments_id']?.toString() ?? '';
      case 'attendances':
        return item['attendances_id']?.toString() ?? '';
      case 'notifications':
        return item['notifications_id']?.toString() ?? '';
      case 'coaches':
        return item['coach_id']?.toString() ?? '';
      case 'branches':
        return item['branches_id']?.toString() ?? '';
      case 'sports':
        return item['sports_id']?.toString() ?? '';
      default:
        return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  Future<List<dynamic>> _fetchFromApi(String apiEndpoint) async {
    return await GoogleSheetService.fetchTable(apiEndpoint);
  }

  // =========================================================================
  // VERİ KAYDETME (PENDING QUEUE)
  // =========================================================================

  Future<bool> saveData({
    required String tableName,
    required Map<String, dynamic> data,
    required Future<bool> Function(Map<String, dynamic>) apiSaveFunction,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();

    // ÖNCE LOCAL'E KAYDET
    final tempId =
        data['${tableName}_id'] ??
        'temp_${DateTime.now().millisecondsSinceEpoch}';
    await _localDB.insertOrUpdate(tableName, tempId.toString(), data);

    if (connectivity != ConnectivityResult.none) {
      // İNTERNET VAR: HEMEN API'YE GÖNDER
      final success = await apiSaveFunction(data);
      if (success) {
        print("✅ API'ye gönderildi: $tableName");
        return true;
      } else {
        // API HATASI: PENDING QUEUE'YE EKLE
        await _localDB.addPendingOperation(
          operation: 'insert',
          tableName: tableName,
          data: data,
        );
        print("⚠️ API hatası, pending queue'ye eklendi: $tableName");
        return true;
      }
    } else {
      // İNTERNET YOK: PENDING QUEUE'YE EKLE
      await _localDB.addPendingOperation(
        operation: 'insert',
        tableName: tableName,
        data: data,
      );
      print("📱 İnternet yok, pending queue'ye eklendi: $tableName");
      return true;
    }
  }

  // =========================================================================
  // SENKRONİZASYON
  // =========================================================================

  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        print("⚠️ İnternet yok, senkronizasyon bekletiliyor");
        _isSyncing = false;
        return;
      }

      final pendingOps = await _localDB.getPendingOperations();
      print("🔄 Senkronize edilecek: ${pendingOps.length} işlem");

      int successCount = 0;
      int failCount = 0;

      for (var op in pendingOps) {
        final data = jsonDecode(op['data'] as String);
        final success = await _executeOperation(
          op['operation'] as String,
          op['table_name'] as String,
          data,
        );

        if (success) {
          await _localDB.removePendingOperation(op['id'] as int);
          successCount++;
          print("✅ Senkronize edildi: ${op['table_name']}");
        } else {
          await _localDB.updatePendingRetryCount(op['id'] as int);

          final retryCount = (op['retry_count'] as int?) ?? 0;
          if (retryCount + 1 >= 3) {
            await _localDB.removePendingOperation(op['id'] as int);
            print(
              "❌ 3 deneme başarısız, işlem iptal edildi: ${op['table_name']}",
            );
          } else {
            failCount++;
            print(
              "❌ Senkronizasyon başarısız, tekrar denenicek: ${op['table_name']}",
            );
          }
        }
      }

      await _localDB.addSyncLog("pending_operations", "success", successCount);
      print(
        "🔄 Senkronizasyon tamamlandı: $successCount başarılı, $failCount başarısız",
      );
    } catch (e) {
      print("Senkronizasyon hatası: $e");
      await _localDB.addSyncLog("pending_operations", "error", 0);
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _executeOperation(
    String operation,
    String tableName,
    Map<String, dynamic> data,
  ) async {
    switch (operation) {
      case 'insert':
        return await GoogleSheetService.insertData(tableName, data);
      case 'update':
        return await GoogleSheetService.updateData(tableName, data);
      case 'delete':
        return await GoogleSheetService.deleteData(tableName, data);
      default:
        return false;
    }
  }

  // =========================================================================
  // PERİYODİK SENKRONİZASYON
  // =========================================================================

  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    Future.delayed(Duration.zero, () async {
      while (true) {
        await Future.delayed(interval);
        await syncPendingOperations();
      }
    });
  }

  // =========================================================================
  // ZORUNLU SENKRONİZASYON
  // =========================================================================

  Future<void> forceSync() async {
    print("🔄 Zorunlu senkronizasyon başlatılıyor...");
    await syncPendingOperations();
  }

  Future<void> refreshAllData() async {
    print("🔄 Tüm veriler yenileniyor...");
    final tables = [
      'users',
      'groups',
      'payments',
      'attendances',
      'notifications',
      'coaches',
      'branches',
      'sports',
    ];

    for (var table in tables) {
      await _localDB.clearTable(table);
      await _fetchFromApi(table);
    }

    print("✅ Tüm veriler yenilendi!");
  }

  // =========================================================================
  // DURUM KONTROLÜ
  // =========================================================================

  Future<bool> hasPendingOperations() async {
    final pending = await _localDB.getPendingOperations();
    return pending.isNotEmpty;
  }

  Future<int> getPendingOperationCount() async {
    final pending = await _localDB.getPendingOperations();
    return pending.length;
  }

  Future<Map<String, int>> getLocalDataStats() async {
    return await _localDB.getAllTableCounts();
  }
}
