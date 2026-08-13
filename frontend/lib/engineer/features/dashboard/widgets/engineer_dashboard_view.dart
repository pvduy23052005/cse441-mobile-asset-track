import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/work_order_model.dart';
import '../services/engineer_dashboard_service.dart';
import 'cards/pm_checklist_card.dart';
import 'cards/sos_work_order_card.dart';
import 'modals/pm_checklist_modal.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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

  Future<void> _handleClaimWorkOrder(WorkOrderModel wo) async {
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
            assigneeName: 'Kỹ Sư ME Trần Minh Đức',
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Mở chi tiết phiếu ${item.code} (${item.machineName})',
                                  ),
                                  backgroundColor: AppTheme.foregroundColor,
                                ),
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
