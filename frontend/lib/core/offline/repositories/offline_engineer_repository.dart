import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../engineer/features/ticket_management/models/ticket_model.dart';
import '../../../engineer/features/machines/models/machine_model.dart';
import '../../network/api_client.dart';
import '../database/app_local_database.dart';
import '../models/sync_task_model.dart';
import '../services/network_connectivity_service.dart';
import '../services/sync_manager.dart';

class OfflineEngineerRepository {
  final Ref? _ref;
  final Dio _dio;
  final NetworkConnectivityService _connectivity;
  final _uuid = const Uuid();

  OfflineEngineerRepository(this._dio, [this._ref])
    : _connectivity = NetworkConnectivityService();

  Future<void> _saveCache(String key, String jsonData) async {
    try {
      final db = await AppLocalDatabase.database;
      await db.insert('local_kv_cache', {
        'key': key,
        'json_data': jsonData,
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<String?> _readCache(String key) async {
    try {
      final db = await AppLocalDatabase.database;
      final rows = await db.query(
        'local_kv_cache',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        return rows.first['json_data'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<List<TicketModel>> getTicketsOfflineFirst() async {
    const cacheKey = 'engineer_tickets';
    final isOnline = await _connectivity.checkOnline();

    if (isOnline) {
      try {
        final response = await _dio.get<List<dynamic>>('/tickets');
        if (response.data != null) {
          final tickets = response.data!
              .map(
                (item) => TicketModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();

          final jsonStr = jsonEncode(response.data);
          await _saveCache(cacheKey, jsonStr);

          return tickets;
        }
      } catch (_) {

      }
    }

    final cachedStr = await _readCache(cacheKey);
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        final List jsonList = jsonDecode(cachedStr) as List;
        return jsonList
            .map(
              (item) =>
                  TicketModel.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      } catch (_) {}
    }

    return [];
  }

  Future<TicketModel?> claimTicketOfflineFirst(String ticketId) async {
    final isOnline = await _connectivity.checkOnline();

    if (isOnline) {
      try {
        final response = await _dio.patch<Map<String, dynamic>>(
          '/tickets/$ticketId/claim',
        );
        if (response.data != null) {
          final ticket = TicketModel.fromJson(response.data!);
          await _updateTicketInLocalCache(ticket);
          return ticket;
        }
      } catch (_) {

      }
    }

    final tickets = await getTicketsOfflineFirst();
    final index = tickets.indexWhere((t) => t.id == ticketId);
    TicketModel? updatedTicket;

    if (index != -1) {
      updatedTicket = tickets[index].copyWith(status: TicketStatus.inProgress);
      tickets[index] = updatedTicket;
      await _saveCache(
        'engineer_tickets',
        jsonEncode(tickets.map((t) => t.toJson()).toList()),
      );
    }

    await _enqueueSyncTask(
      actionType: 'CLAIM_TICKET',
      endpoint: '/tickets/$ticketId/claim',
      method: 'PATCH',
      payload: {},
    );

    return updatedTicket;
  }

  Future<TicketModel?> completeTicketOfflineFirst(
    String ticketId, {
    List<SparePartItem>? usedParts,
  }) async {
    final isOnline = await _connectivity.checkOnline();
    final payload = {
      'used_spare_parts': usedParts?.map((p) => p.toJson()).toList() ?? [],
    };

    if (isOnline) {
      try {
        final response = await _dio.patch<Map<String, dynamic>>(
          '/tickets/$ticketId/complete',
          data: payload,
        );
        if (response.data != null) {
          final ticket = TicketModel.fromJson(response.data!);
          await _updateTicketInLocalCache(ticket);
          return ticket;
        }
      } catch (_) {

      }
    }

    final tickets = await getTicketsOfflineFirst();
    final index = tickets.indexWhere((t) => t.id == ticketId);
    TicketModel? updatedTicket;

    if (index != -1) {
      updatedTicket = tickets[index].copyWith(
        status: TicketStatus.pendingApproval,
        usedSpareParts: usedParts ?? tickets[index].usedSpareParts,
      );
      tickets[index] = updatedTicket;
      await _saveCache(
        'engineer_tickets',
        jsonEncode(tickets.map((t) => t.toJson()).toList()),
      );
    }

    await _enqueueSyncTask(
      actionType: 'COMPLETE_TICKET',
      endpoint: '/tickets/$ticketId/complete',
      method: 'PATCH',
      payload: payload,
    );

    return updatedTicket;
  }

  Future<List<MachineModel>> getMachinesOfflineFirst() async {
    const cacheKey = 'engineer_machines';
    final isOnline = await _connectivity.checkOnline();

    if (isOnline) {
      try {
        final response = await _dio.get<List<dynamic>>('/machines');
        if (response.data != null) {
          final machines = response.data!
              .map(
                (item) => MachineModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();

          await _saveCache(cacheKey, jsonEncode(response.data));
          return machines;
        }
      } catch (_) {}
    }

    final cachedStr = await _readCache(cacheKey);
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        final List jsonList = jsonDecode(cachedStr) as List;
        return jsonList
            .map(
              (item) =>
                  MachineModel.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      } catch (_) {}
    }

    return [];
  }

  Future<bool> updateTroubleshootingOfflineFirst(
    String machineId,
    List<TroubleshootingItem> items,
  ) async {
    final isOnline = await _connectivity.checkOnline();
    final payload = {
      'troubleshooting_guide': items.map((e) => e.toJson()).toList(),
    };

    if (isOnline) {
      try {
        final response = await _dio.put(
          '/machines/$machineId/troubleshooting',
          data: payload,
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (_) {}
    }

    await _enqueueSyncTask(
      actionType: 'UPDATE_TROUBLESHOOTING',
      endpoint: '/machines/$machineId/troubleshooting',
      method: 'PUT',
      payload: payload,
    );

    return true;
  }

  Future<void> _updateTicketInLocalCache(TicketModel updatedTicket) async {
    final tickets = await getTicketsOfflineFirst();
    final index = tickets.indexWhere((t) => t.id == updatedTicket.id);
    if (index != -1) {
      tickets[index] = updatedTicket;
    } else {
      tickets.add(updatedTicket);
    }
    await _saveCache(
      'engineer_tickets',
      jsonEncode(tickets.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> _enqueueSyncTask({
    required String actionType,
    required String endpoint,
    required String method,
    required Map<String, dynamic> payload,
  }) async {
    final db = await AppLocalDatabase.database;
    final now = DateTime.now();
    final syncTask = SyncTaskModel(
      id: _uuid.v4(),
      actionType: actionType,
      endpoint: endpoint,
      method: method,
      payload: payload,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      'sync_queue',
      syncTask.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (_ref != null) {
      try {
        final syncManager = _ref.read(syncManagerProvider.notifier);
        await syncManager.updatePendingCount();

        final isOnline = await _connectivity.checkOnline();
        if (isOnline) {
          unawaited(syncManager.syncPendingQueue());
        }
      } catch (_) {}
    }
  }
}

final offlineEngineerRepositoryProvider = Provider<OfflineEngineerRepository>((
  ref,
) {
  final dio = ApiClient.instance;
  return OfflineEngineerRepository(dio, ref);
});
