import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/work_order_model.dart';
import '../services/engineer_dashboard_service.dart';
import 'pm_checklist_card.dart';
import 'sos_work_order_card.dart';

class EngineerDashboardView extends StatefulWidget {
  const EngineerDashboardView({super.key});

  @override
  State<EngineerDashboardView> createState() => _EngineerDashboardViewState();
}

class _EngineerDashboardViewState extends State<EngineerDashboardView> {
  final EngineerDashboardService _service = EngineerDashboardService();

  late List<WorkOrderModel> _workOrders;
  late List<PMChecklistModel> _pmChecklists;

  @override
  void initState() {
    super.initState();
    _workOrders = _service.getMockWorkOrders();
    _pmChecklists = _service.getMockPMChecklists();
  }

  void _handleClaimWorkOrder(WorkOrderModel wo) {
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

    _service.updateStatus(wo.machineId, 'IN_PROGRESS');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tiếp nhận xử lý ${wo.code} (${wo.machineName})'),
        backgroundColor: const Color(0xFF0284C7),
      ),
    );
  }

  void _handleCompleteWorkOrder(WorkOrderModel wo) {
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

    _service.updateStatus(wo.machineId, 'RUNNING');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã hoàn thành ${wo.code} và gửi Quản đốc nghiệm thu!'),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
                            color: Color(0xFFBE123C), // Rose-700
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Text(
                          'Chạm xem chi tiết',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1), // Sky-700
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // SOS Work Orders Feed
                    if (pendingOrActiveWorkOrders.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: const Center(
                          child: Text(
                            'Hiện không có phiếu sự cố SOS nào cần xử lý',
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
                        color: Color(0xFFB45309), // Amber-700
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // PM Checklists Feed
                    ..._pmChecklists.map(
                      (pm) => PmChecklistCard(
                        pmChecklist: pm,
                        onOpenPM: (item) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Mở danh sách PM Checklist ${item.code} (${item.machineName})',
                              ),
                              backgroundColor: const Color(0xFFD97706),
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
    );
  }
}
