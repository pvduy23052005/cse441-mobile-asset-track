import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/offline/database/app_local_database.dart';
import '../../../../core/offline/services/network_connectivity_service.dart';

class PMChecklistRepository {
  final Dio _dio = ApiClient.instance;
  final NetworkConnectivityService _connectivity = NetworkConnectivityService();

  Future<void> savePMStateLocally({
    required String checklistId,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> spareParts,
  }) async {
    try {
      final db = await AppLocalDatabase.database;
      final jsonStr = jsonEncode({
        'items': items,
        'spareParts': spareParts,
      });
      await db.insert(
        'local_kv_cache',
        {
          'key': 'pm_state_$checklistId',
          'json_data': jsonStr,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getPMStateLocally(String checklistId) async {
    try {
      final db = await AppLocalDatabase.database;
      final rows = await db.query(
        'local_kv_cache',
        where: 'key = ?',
        whereArgs: ['pm_state_$checklistId'],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final jsonStr = rows.first['json_data'] as String?;
        if (jsonStr != null && jsonStr.isNotEmpty) {
          return jsonDecode(jsonStr) as Map<String, dynamic>?;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> submitPMChecklist({
    required String checklistId,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> spareParts,
    String? engineerName,
  }) async {

    await savePMStateLocally(
      checklistId: checklistId,
      items: items,
      spareParts: spareParts,
    );

    final isOnline = await _connectivity.checkOnline();
    final payload = {
      'items': items,
      'used_spare_parts': spareParts,
      if (engineerName != null && engineerName.isNotEmpty)
        'engineer_name': engineerName,
    };

    if (isOnline) {
      try {
        final response = await _dio.patch(
          '/machines/pm-checklists/$checklistId/submit',
          data: payload,
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (_) {}
    }

    return true;
  }
}
