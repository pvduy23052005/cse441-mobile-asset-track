import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../network/api_client.dart';
import '../../services/upload_service.dart';
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

    // Try online creation first if connected
    final isOnline =
        await _ref.read(networkConnectivityServiceProvider).checkOnline();

    if (isOnline) {
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        try {
          final uploadService = _ref.read(uploadServiceProvider);
          imageUrls = await uploadService.uploadMultipleImages(imageFiles);
        } catch (_) {}
      }

      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/operator/tickets',
          data: {
            'machine_id': machineId,
            'description': description,
            'severity': severity.toUpperCase(),
            'images_urls': imageUrls,
            'downtime_start': downtimeStart ?? now.toIso8601String(),
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final remoteTicket = response.data ?? {};
          final ticketId = remoteTicket['id']?.toString() ?? localTicketId;
          final syncedModel = LocalTicketModel(
            id: ticketId,
            machineId: machineId,
            machineName: machineName ?? remoteTicket['machine_name']?.toString(),
            machineCode: machineCode ?? remoteTicket['machine_code']?.toString(),
            description: description,
            severity: severity.toUpperCase(),
            status: remoteTicket['status']?.toString() ?? 'OPEN',
            imagesUrls: imageUrls,
            localImagePaths: localImagePaths,
            downtimeStart: downtimeStart ?? now.toIso8601String(),
            syncStatus: SyncStatus.synced,
            createdAt: now,
            updatedAt: now,
          );
          await db.insert(
            'local_tickets',
            syncedModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          return syncedModel;
        }
      } on DioException catch (dioErr) {
        if (dioErr.response?.data != null) {
          final data = dioErr.response!.data;
          String msg = '';
          if (data is Map && data['message'] != null) {
            msg = data['message'] is List
                ? (data['message'] as List).join(', ')
                : data['message'].toString();
          } else {
            msg = dioErr.response?.statusMessage ?? 'Lỗi từ máy chủ';
          }
          throw Exception(msg);
        }
      } catch (e) {
        if (e is Exception && !e.toString().contains('SocketException')) {
          rethrow;
        }
      }
    }

    // If offline, save to local database and queue for background sync
    final localTicket = LocalTicketModel(
      id: localTicketId,
      machineId: machineId,
      machineName: machineName,
      machineCode: machineCode,
      description: description,
      severity: severity.toUpperCase(),
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

    final syncTask = SyncTaskModel(
      id: syncTaskId,
      actionType: 'CREATE_TICKET',
      endpoint: '/operator/tickets',
      method: 'POST',
      localRecordId: localTicketId,
      payload: {
        'machine_id': machineId,
        'description': description,
        'severity': severity.toUpperCase(),
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

    final syncManager = _ref.read(syncManagerProvider.notifier);
    await syncManager.updatePendingCount();

    return localTicket;
  }

  Future<List<Map<String, dynamic>>> getTicketsOfflineFirst() async {
    final db = await AppLocalDatabase.database;

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

          final remoteIds = formattedRemote
              .map((t) => t['id']?.toString())
              .where((id) => id != null && id.isNotEmpty)
              .toSet();

          // Clean up stale or already synced local rows
          final localPendingRows = await db.query(
            'local_tickets',
            where: "sync_status IN ('PENDING', 'FAILED')",
            orderBy: 'created_at DESC',
          );

          final List<Map<String, dynamic>> trulyPending = [];
          for (final r in localPendingRows) {
            final localId = r['id']?.toString();
            if (localId != null && remoteIds.contains(localId)) {
              await db.update(
                'local_tickets',
                {'sync_status': SyncStatus.synced.value},
                where: 'id = ?',
                whereArgs: [localId],
              );
              await db.delete('sync_queue',
                  where: 'local_record_id = ?', whereArgs: [localId]);
            } else {
              final taskCount = Sqflite.firstIntValue(await db.rawQuery(
                    "SELECT COUNT(*) FROM sync_queue WHERE local_record_id = ? AND status IN ('PENDING', 'PROCESSING')",
                    [localId],
                  )) ??
                  0;
              if (taskCount > 0) {
                final model = LocalTicketModel.fromMap(r);
                trulyPending.add(model.toDashboardTicketJson());
              } else {
                await db.delete('local_tickets',
                    where: 'id = ?', whereArgs: [localId]);
              }
            }
          }

          // Cache remote items to local database
          for (final item in formattedRemote) {
            try {
              final id = item['id']?.toString() ?? '';
              if (id.isNotEmpty) {
                final model = LocalTicketModel(
                  id: id,
                  machineId: item['machine_id']?.toString() ?? '',
                  machineName: item['machine_name']?.toString(),
                  machineCode: item['machine_code']?.toString(),
                  description: item['description']?.toString() ?? '',
                  severity: item['severity']?.toString() ?? 'MEDIUM',
                  status: item['status']?.toString() ?? 'OPEN',
                  imagesUrls: (item['images_urls'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      [],
                  syncStatus: SyncStatus.synced,
                  createdAt: DateTime.tryParse(item['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                  updatedAt: DateTime.tryParse(item['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                );
                await db.insert(
                  'local_tickets',
                  model.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              }
            } catch (_) {}
          }

          return [...trulyPending, ...formattedRemote];
        }
      } catch (_) {
        // Fallback to local cache if network request fails
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
