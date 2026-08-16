import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../network/api_client.dart';
import '../../services/upload_service.dart';
import '../database/app_local_database.dart';
import '../models/local_ticket_model.dart';
import '../models/sync_task_model.dart';
import 'network_connectivity_service.dart';

class SyncState {
  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncTime;
  final String? lastError;

  const SyncState({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncTime,
    this.lastError,
  });

  SyncState copyWith({
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSyncTime,
    String? lastError,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError,
    );
  }
}

class SyncManager extends StateNotifier<SyncState> {
  final Ref _ref;
  final Dio _dio;
  final UploadService _uploadService;
  bool _isProcessing = false;
  StreamSubscription<bool>? _networkSubscription;

  SyncManager(this._ref, this._dio, this._uploadService)
      : super(const SyncState()) {
    _init();
  }

  void _init() async {
    await updatePendingCount();
    _networkSubscription = _ref
        .read(networkConnectivityServiceProvider)
        .onOnlineStatusChanged
        .listen((isOnline) {
      if (isOnline) {
        syncPendingQueue();
      }
    });
  }

  Future<void> updatePendingCount() async {
    try {
      final db = await AppLocalDatabase.database;
      final count = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT COUNT(*) FROM sync_queue WHERE status IN ('PENDING', 'PROCESSING')",
          )) ??
          0;
      if (mounted) {
        state = state.copyWith(pendingCount: count);
      }
    } catch (_) {}
  }

  Future<void> syncPendingQueue() async {
    if (_isProcessing) return;

    final isOnline =
        await _ref.read(networkConnectivityServiceProvider).checkOnline();
    if (!isOnline) {
      return;
    }

    _isProcessing = true;
    state = state.copyWith(isSyncing: true, lastError: null);

    try {
      final db = await AppLocalDatabase.database;
      final pendingRows = await db.query(
        'sync_queue',
        where: "status IN ('PENDING', 'FAILED') AND retry_count < max_retries",
        orderBy: 'created_at ASC',
      );

      final tasks = pendingRows.map((e) => SyncTaskModel.fromMap(e)).toList();

      for (final task in tasks) {
        // Mark as processing
        await db.update(
          'sync_queue',
          {
            'status': SyncTaskStatus.processing.value,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [task.id],
        );

        bool success = false;
        String? errorMessage;

        try {
          if (task.actionType == 'CREATE_TICKET') {
            success = await _processCreateTicketTask(task);
          } else {
            success = await _processGenericTask(task);
          }
        } catch (e) {
          success = false;
          errorMessage = e.toString();
        }

        if (success) {
          // Delete completed task from queue
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [task.id]);

          // Update local record status
          if (task.localRecordId != null) {
            await db.update(
              'local_tickets',
              {
                'sync_status': SyncStatus.synced.value,
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [task.localRecordId],
            );
          }
        } else {
          final newRetryCount = task.retryCount + 1;
          final isMaxReached = newRetryCount >= task.maxRetries;

          await db.update(
            'sync_queue',
            {
              'status': isMaxReached
                  ? SyncTaskStatus.failed.value
                  : SyncTaskStatus.pending.value,
              'retry_count': newRetryCount,
              'error_message': errorMessage,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [task.id],
          );

          if (isMaxReached && task.localRecordId != null) {
            await db.update(
              'local_tickets',
              {
                'sync_status': SyncStatus.failed.value,
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [task.localRecordId],
            );
          }

          // Exponential backoff pause
          final backoffMs = min(1000 * pow(2, newRetryCount).toInt(), 30000);
          await Future.delayed(Duration(milliseconds: backoffMs));
        }
      }

      await updatePendingCount();
      if (mounted) {
        state = state.copyWith(
          isSyncing: false,
          lastSyncTime: DateTime.now(),
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isSyncing: false,
          lastError: e.toString(),
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _processCreateTicketTask(SyncTaskModel task) async {
    final payload = Map<String, dynamic>.from(task.payload);

    // 1. Check if there are local offline image files that need uploading
    final localImagePaths = (payload['local_image_paths'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    List<String> uploadedRemoteUrls = (payload['images_urls'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    if (localImagePaths.isNotEmpty) {
      final existingFiles = localImagePaths
          .map((p) => File(p))
          .where((f) => f.existsSync())
          .toList();

      if (existingFiles.isNotEmpty) {
        final newRemoteUrls = await _uploadService.uploadMultipleImages(
          existingFiles,
          folder: 'tickets',
        );
        uploadedRemoteUrls.addAll(newRemoteUrls);
      }
    }

    // 2. Prepare API payload
    final apiPayload = {
      'machine_id': payload['machine_id'],
      'description': payload['description'],
      'severity': payload['severity'],
      'images_urls': uploadedRemoteUrls,
      if (payload['downtime_start'] != null)
        'downtime_start': payload['downtime_start'],
    };

    // 3. Post to Server API
    final response = await _dio.post(
      task.endpoint,
      data: apiPayload,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> _processGenericTask(SyncTaskModel task) async {
    Response response;
    switch (task.method.toUpperCase()) {
      case 'POST':
        response = await _dio.post(task.endpoint, data: task.payload);
        break;
      case 'PUT':
        response = await _dio.put(task.endpoint, data: task.payload);
        break;
      case 'PATCH':
        response = await _dio.patch(task.endpoint, data: task.payload);
        break;
      case 'DELETE':
        response = await _dio.delete(task.endpoint, data: task.payload);
        break;
      default:
        response = await _dio.post(task.endpoint, data: task.payload);
    }
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }
}

final syncManagerProvider =
    StateNotifierProvider<SyncManager, SyncState>((ref) {
  final dio = ApiClient.instance;
  final uploadService = ref.watch(uploadServiceProvider);
  return SyncManager(ref, dio, uploadService);
});
