import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/storage_service.dart';
import '../../ticket_management/models/ticket_model.dart';
import '../../ticket_management/widgets/modals/work_order_detail_modal.dart';
import '../models/work_order_model.dart';
import '../services/engineer_dashboard_service.dart';
import 'cards/pm_checklist_card.dart';
import 'cards/sos_work_order_card.dart';
import 'modals/pm_checklist_modal.dart';
import 'quick_stats_cards.dart';

class EngineerDashboardView extends StatefulWidget {
  const EngineerDashboardView({super.key});

  @override
  State<EngineerDashboardView> createState() => _EngineerDashboardViewState();
}

class _EngineerDashboardViewState extends State<EngineerDashboardView> {
  final EngineerDashboardService _service = EngineerDashboardService();

  List<WorkOrderModel> _workOrders = [];
  List<PMChecklistModel> _pmChecklists = [];
  bool _isLoading = true;

  StreamSubscription<List<WorkOrderModel>>? _streamSubscription;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();

    // 1. Realtime Stream from Firestore
    _streamSubscription = _service.streamWorkOrders().listen((realtimeOrders) {
      if (mounted && realtimeOrders.isNotEmpty) {
        setState(() {
          _workOrders = realtimeOrders;
          _isLoading = false;
        });
      }
    });

    // 2. Silent Auto-Polling fallback every 5 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _silentRefreshData();
    });
  }

  Future<void> _silentRefreshData() async {
    final apiOrders = await _service.fetchWorkOrdersFromApi();
    final apiChecklists = await _service.fetchPMChecklistsFromApi();
    if (mounted && apiOrders.isNotEmpty) {
      setState(() {
        _workOrders = apiOrders;
        if (apiChecklists.isNotEmpty) {
          _pmChecklists = apiChecklists;
        }
      });
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final apiOrders = await _service.fetchWorkOrdersFromApi();
    final apiChecklists = await _service.fetchPMChecklistsFromApi();

    if (mounted) {
      setState(() {
        _workOrders = apiOrders;
        _pmChecklists = apiChecklists;
        _isLoading = false;
      });
    }
  }

  TicketModel _convertToTicketModel(WorkOrderModel item) {
    TicketStatus status;
    switch (item.status) {
      case WorkOrderStatus.inProgress:
        status = TicketStatus.inProgress;
        break;
      case WorkOrderStatus.completed:
        status = TicketStatus.pendingApproval;
        break;
      case WorkOrderStatus.approved:
        status = TicketStatus.closed;
        break;
      case WorkOrderStatus.rejected:
        status = TicketStatus.rejected;
        break;
      case WorkOrderStatus.cancelled:
        status = TicketStatus.cancelled;
        break;
      default:
        status = TicketStatus.open;
    }

    TicketSeverity severity;
    switch (item.severity) {
      case WorkOrderSeverity.critical:
      case WorkOrderSeverity.high:
        severity = TicketSeverity.critical;
        break;
      case WorkOrderSeverity.low:
        severity = TicketSeverity.low;
        break;
      default:
        severity = TicketSeverity.medium;
    }

    return TicketModel(
      id: item.id,
      code: item.code,
      machineId: item.machineId,
      machineCode: item.machineId,
      machineName: item.machineName,
      description: item.description,
      severity: severity,
      status: status,
      imageUrl: item.imageUrl,
      rejectionReason: item.rejectionReason,
      engineerName: item.assigneeName,
      createdAt: item.createdAt,
    );
  }

  Future<void> _handleClaimWorkOrder(WorkOrderModel wo) async {
    final currentEngineerName = StorageService.getUserFullName()?.isNotEmpty == true
        ? StorageService.getUserFullName()!
        : 'Kỹ Sư ME';

    setState(() {
      _workOrders = _workOrders.map((item) {
        if (item.id == wo.id) {
          return WorkOrderModel(
            id: item.id,
            code: item.code,
            machineId: item.machineId,
            machineName: item.machineName,
            severity: item.severity,
            status: WorkOrderStatus.inProgress,
            description: item.description,
            imageUrl: item.imageUrl,
            assigneeName: currentEngineerName,
            createdAt: item.createdAt,
          );
        }
        return item;
      }).toList();
    });

    final success = await _service.updateWorkOrderStatus(wo.id, 'IN_PROGRESS');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã tiếp nhận xử lý ${wo.code} (${wo.machineName}) trên DB Backend!'
              : 'Đã tiếp nhận xử lý ${wo.code} (${wo.machineName})',
        ),
        backgroundColor: const Color(0xFF0284C7),
      ),
    );
  }

  Future<void> _handleCompleteWorkOrder(WorkOrderModel wo) async {
    setState(() {
      _workOrders = _workOrders.map((item) {
        if (item.id == wo.id) {
          return WorkOrderModel(
            id: item.id,
            code: item.code,
            machineId: item.machineId,
            machineName: item.machineName,
            severity: item.severity,
            status: WorkOrderStatus.completed,
            description: item.description,
            imageUrl: item.imageUrl,
            assigneeName: item.assigneeName,
            createdAt: item.createdAt,
          );
        }
        return item;
      }).toList();
    });

    final success = await _service.updateWorkOrderStatus(wo.id, 'COMPLETED');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã hoàn thành ${wo.code} và gửi Quản đốc nghiệm thu trên DB Backend!'
              : 'Đã hoàn thành ${wo.code} và gửi Quản đốc nghiệm thu!',
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrActiveWorkOrders =
        _workOrders.where((w) => w.status != WorkOrderStatus.approved).toList();

    return Container(
      color: AppTheme.backgroundColor,
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Loading Indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                ),

              // Quick Stats KPI Cards (CHỜ TIẾP NHẬN & ĐANG XỬ LÝ)
              QuickStatsCards(
                pendingCount: _workOrders
                    .where((w) => w.status == WorkOrderStatus.pending)
                    .length,
                inProgressCount: _workOrders
                    .where((w) => w.status == WorkOrderStatus.inProgress)
                    .length,
              ),
              const SizedBox(height: 10),

              // Section 1: PHIẾU SỰ CỐ SOS CẦN XỬ LÝ
              Card(
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                color: AppTheme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PHIẾU SỰ CỐ SOS CẦN XỬ LÝ (${pendingOrActiveWorkOrders.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFBE123C),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const Text(
                            'Chạm xem chi tiết',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // SOS Work Orders Feed
                      if (!_isLoading && pendingOrActiveWorkOrders.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: Text(
                              'Không có phiếu sự cố SOS nào trong DB',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.mutedForegroundColor,
                              ),
                            ),
                          ),
                        )
                      else
                        ...pendingOrActiveWorkOrders.map(
                          (wo) => SosWorkOrderCard(
                            workOrder: wo,
                            onClaim: _handleClaimWorkOrder,
                            onComplete: _handleCompleteWorkOrder,
                            onTapDetail: (item) {
                              WorkOrderDetailModal.show(
                                context,
                                ticket: _convertToTicketModel(item),
                                onClaim: () => _handleClaimWorkOrder(item),
                                onComplete: (parts) => _handleCompleteWorkOrder(item),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Section 2: NHIỆM VỤ BẢO TRÌ ĐỊNH KỲ (PM CHECKLIST)
              Card(
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                color: AppTheme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      const Text(
                        'NHIỆM VỤ BẢO TRÌ ĐỊNH KỲ (PM CHECKLIST)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PM Checklists Feed
                      if (!_isLoading && _pmChecklists.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: Text(
                              'Chưa có nhiệm vụ bảo trì PM nào trong DB',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.mutedForegroundColor,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._pmChecklists.map(
                          (pm) => PmChecklistCard(
                            pmChecklist: pm,
                            onOpenPM: (item) {
                              showDialog(
                                context: context,
                                builder: (ctx) => PMChecklistModal(
                                  checklist: item,
                                  onClose: () => Navigator.pop(ctx),
                                  onComplete: () {
                                    Navigator.pop(ctx);
                                    if (mounted) {
                                      setState(() {
                                        _pmChecklists = _pmChecklists.map((pm) {
                                          if (pm.id == item.id) {
                                            return PMChecklistModel(
                                              id: pm.id,
                                              code: pm.code,
                                              machineId: pm.machineId,
                                              machineName: pm.machineName,
                                              scheduledHours: pm.scheduledHours,
                                              status: PMChecklistStatus.completed,
                                              itemCount: pm.itemCount,
                                            );
                                          }
                                          return pm;
                                        }).toList();
                                      });
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đã hoàn thành bảo trì PM ${item.code} (${item.machineName})!',
                                        ),
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
