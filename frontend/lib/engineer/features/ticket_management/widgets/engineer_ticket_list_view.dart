import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/pm_checklist_model.dart';
import '../models/ticket_model.dart';
import '../services/engineer_ticket_service.dart';
import 'modals/pm_checklist_modal.dart';
import 'modals/work_order_detail_modal.dart';
import 'pm_card.dart';
import 'ticket_card.dart';

class EngineerTicketListView extends StatefulWidget {
  const EngineerTicketListView({super.key});

  @override
  State<EngineerTicketListView> createState() => _EngineerTicketListViewState();
}

class _EngineerTicketListViewState extends State<EngineerTicketListView> {
  final EngineerTicketService _ticketService = EngineerTicketService();

  List<TicketModel> _tickets = [];
  bool _isLoading = true;

  final List<PMChecklistModel> _pmChecklists = [
    PMChecklistModel(
      id: 'pm1',
      code: 'PM-2026-0500H',
      machineId: 'm4',
      machineCode: 'ROBOT-2024-004',
      machineName: 'Dây Chuyền Hàn Robot Tự Động',
      scheduledHours: 1000,
      status: 'PENDING',
      items: [
        PMChecklistItem(id: '1', title: 'Kiểm tra mức dầu bôi trơn & thay mới nếu sẫm màu', isCompleted: true),
        PMChecklistItem(id: '2', title: 'Siết lại toàn bộ bulong đỡ chân máy & quạt gió', isCompleted: false),
        PMChecklistItem(id: '3', title: 'Vệ sinh lưới lọc bụi khí nạp phía sau động cơ', isCompleted: false),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTicketsData();
  }

  Future<void> _loadTicketsData() async {
    setState(() => _isLoading = true);
    final apiList = await _ticketService.fetchTicketsFromApi();

    if (mounted) {
      setState(() {
        _tickets = apiList; // Lấy 100% từ API backend
        _isLoading = false;
      });
    }
  }

  Future<void> _handleClaimTicket(TicketModel ticket) async {
    final updated = await _ticketService.claimTicket(ticket.id);
    if (mounted) {
      setState(() {
        _tickets = _tickets.map((t) {
          if (t.id == ticket.id) {
            return updated ??
                TicketModel(
                  id: t.id,
                  code: t.code,
                  machineId: t.machineId,
                  machineCode: t.machineCode,
                  machineName: t.machineName,
                  description: t.description,
                  severity: t.severity,
                  status: TicketStatus.inProgress,
                  createdAt: t.createdAt,
                  imageUrl: t.imageUrl,
                );
          }
          return t;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tiếp nhận sửa chữa ${ticket.code}!'),
          backgroundColor: const Color(0xFF0891B2),
        ),
      );
    }
  }

  Future<void> _handleCompleteTicket(TicketModel ticket, [List<SparePartItem>? parts]) async {
    final updated = await _ticketService.completeTicket(ticket.id, usedParts: parts);
    if (mounted) {
      setState(() {
        _tickets = _tickets.map((t) {
          if (t.id == ticket.id) {
            return updated ??
                TicketModel(
                  id: t.id,
                  code: t.code,
                  machineId: t.machineId,
                  machineCode: t.machineCode,
                  machineName: t.machineName,
                  description: t.description,
                  severity: t.severity,
                  status: TicketStatus.pendingApproval,
                  createdAt: t.createdAt,
                  imageUrl: t.imageUrl,
                  usedSpareParts: parts ?? t.usedSpareParts,
                );
          }
          return t;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi nghiệm thu phiếu ${ticket.code}!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // bg-slate-50
      child: RefreshIndicator(
        onRefresh: _loadTicketsData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Engineer Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'NHIỆM VỤ KỸ SƯ CƠ ĐIỆN (ME TASKS)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900, // font-extrabold
                      color: Color(0xFF475569), // text-slate-600
                      letterSpacing: 0.6,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // bg-slate-100
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'Kỹ sư: Trần Minh Đức',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155), // text-slate-700
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                )
              else ...[
                // Card 1: 1. Sự cố SOS khẩn cấp cần sửa chữa (Count)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Text(
                          '1. Sự cố SOS khẩn cấp cần sửa chữa (${_tickets.length})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B), // text-slate-800
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                        child: _tickets.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: const Center(
                                  child: Text(
                                    'Không có phiếu sự cố SOS nào',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: _tickets.map((t) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: TicketCard(
                                      ticket: t,
                                      onTap: () {
                                        WorkOrderDetailModal.show(
                                          context,
                                          ticket: t,
                                          onClaim: () => _handleClaimTicket(t),
                                          onComplete: (parts) => _handleCompleteTicket(t, parts),
                                        );
                                      },
                                      onClaim: () => _handleClaimTicket(t),
                                      onComplete: () => _handleCompleteTicket(t),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Card 2: 2. Đợt bảo trì định kỳ PM Checklist (Count)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Text(
                          '2. Đợt bảo trì định kỳ PM Checklist (${_pmChecklists.length})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B), // text-slate-800
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                        child: _pmChecklists.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: const Center(
                                  child: Text(
                                    'Không có nhiệm vụ bảo trì PM nào',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: _pmChecklists.map((pm) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: PMCard(
                                      pm: pm,
                                      onTap: () {
                                        PMChecklistModal.show(
                                          context,
                                          pm: pm,
                                          onCompletePM: (updatedPM) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Đã hoàn thành bảo trì PM ${updatedPM.code}!'),
                                                backgroundColor: const Color(0xFFD97706),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
