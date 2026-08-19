import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../network/api_client.dart';
import '../database/app_local_database.dart';
import '../models/local_ticket_model.dart';
import '../models/sync_task_model.dart';
import '../services/network_connectivity_service.dart';
import '../services/sync_manager.dart';

class OfflineTicketRepository {
  final Ref _ref;
  final Dio _dio;
  final _uuid = const Uuid();

  OfflineTicketRepository(this._ref, this._dio);

  Future<LocalTicketModel> createTicketOfflineFirst({
    required String machineId,
    String? machineName,
    String? machineCode,
    required String description,
    required String severity,
    List<XFile> imageFiles = const [],
    String? downtimeStart,
  }) async {
    final db = await AppLocalDatabase.database;
    final now = DateTime.now();
    final localTicketId = _uuid.v4();
    final syncTaskId = _uuid.v4();

    final localImagePaths = imageFiles.map((f) => f.path).toList();

    // 1. Create LocalTicket record (PENDING)
    final localTicket = LocalTicketModel(
      id: localTicketId,
      machineId: machineId,
      machineName: machineName,
      machineCode: machineCode,
      description: description,
      severity: severity,
      status: 'PENDING',
      imagesUrls: const [],
      localImagePaths: localImagePaths,
      downtimeStart: downtimeStart ?? now.toIso8601String(),
      syncStatus: SyncStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      'local_tickets',
      localTicket.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 2. Enqueue task into sync_queue
    final syncTask = SyncTaskModel(
      id: syncTaskId,
      actionType: 'CREATE_TICKET',
      endpoint: '/operator/tickets',
      method: 'POST',
      localRecordId: localTicketId,
      payload: {
        'machine_id': machineId,
        'description': description,
        'severity': severity,
        'images_urls': <String>[],
        'local_image_paths': localImagePaths,
        'downtime_start': downtimeStart ?? now.toIso8601String(),
      },
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      'sync_queue',
      syncTask.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 3. Update SyncManager state & trigger background sync if online
    final syncManager = _ref.read(syncManagerProvider.notifier);
    await syncManager.updatePendingCount();

    final isOnline =
        await _ref.read(networkConnectivityServiceProvider).checkOnline();
    if (isOnline) {
      unawaited(syncManager.syncPendingQueue());
    }

    return localTicket;
  }

  Future<List<Map<String, dynamic>>> getTicketsOfflineFirst() async {
    final db = await AppLocalDatabase.database;

    // 1. Load pending local tickets
    final localRows = await db.query(
      'local_tickets',
      where: "sync_status IN ('PENDING', 'FAILED')",
      orderBy: 'created_at DESC',
    );
    final pendingTickets = localRows.map((r) {
      final model = LocalTicketModel.fromMap(r);
      return model.toDashboardTicketJson();
    }).toList();

    // 2. Try fetching from remote API if online
    final isOnline =
        await _ref.read(networkConnectivityServiceProvider).checkOnline();
    if (isOnline) {
      try {
        final response = await _dio.get('/operator/tickets');
        if (response.statusCode == 200 && response.data != null) {
          final List remoteList = (response.data is List)
              ? response.data
              : (response.data['data'] as List? ?? []);

          final formattedRemote = remoteList.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            map['sync_status'] = 'SYNCED';
            map['is_local'] = false;
            return map;
          }).toList();

          return [...pendingTickets, ...formattedRemote];
        }
      } catch (_) {
        // Fallback to local cache
      }
    }

    // 3. Return cached synced + pending if offline
    final allLocalRows = await db.query(
      'local_tickets',
      orderBy: 'created_at DESC',
    );
    return allLocalRows.map((r) {
      final model = LocalTicketModel.fromMap(r);
      return model.toDashboardTicketJson();
    }).toList();
  }

  Future<void> deleteTicketOfflineFirst(String id, {bool isLocal = false}) async {
    final db = await AppLocalDatabase.database;

    await db.delete('local_tickets', where: 'id = ?', whereArgs: [id]);
    await db.delete('sync_queue', where: 'local_record_id = ?', whereArgs: [id]);

    final syncManager = _ref.read(syncManagerProvider.notifier);
    await syncManager.updatePendingCount();

    final isOnline =
        await _ref.read(networkConnectivityServiceProvider).checkOnline();
    if (isOnline && !isLocal) {
      await _dio.delete('/operator/tickets/$id');
    }
  }
}

final offlineTicketRepositoryProvider =
    Provider<OfflineTicketRepository>((ref) {
  final dio = ApiClient.instance;
  return OfflineTicketRepository(ref, dio);
});
