import 'package:flutter/material.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/operator_qr_scanner_sheet.dart';
import '../../machine/services/machine_service.dart';
import '../../machine/widgets/machine_detail_modal.dart';
import '../../ticket/services/operator_ticket_service.dart';
import '../../ticket/widgets/sos_ticket_card.dart';
import 'operator_machine_card.dart';
import 'operator_pagination_controls.dart';
import 'operator_qr_banner.dart';

class OperatorDashboardView extends StatefulWidget {
  const OperatorDashboardView({super.key});

  @override
  State<OperatorDashboardView> createState() => _OperatorDashboardViewState();
}

class _OperatorDashboardViewState extends State<OperatorDashboardView> {
  final MachineService _machineService = MachineService();
  final OperatorTicketService _ticketService = OperatorTicketService();

  List<MachineModel> _machines = [];
  List<Map<String, dynamic>> _tickets = [];

  bool _isLoading = true;
  int _currentMachinePage = 0;
  static const int _itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final machinesFuture = _machineService.getMachines();
      final ticketsFuture = _ticketService.getMyTickets();

      final results = await Future.wait([
        machinesFuture,
        ticketsFuture,
      ]);

      if (mounted) {
        setState(() {
          _machines = results[0] as List<MachineModel>;
          _tickets = results[1] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openQRScanner() async {
    final machine = await OperatorQRScannerSheet.show(context);
    if (machine != null && mounted) {
      MachineDetailModal.show(context, machine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages =
        (_machines.isEmpty) ? 1 : (_machines.length / _itemsPerPage).ceil();
    final pagedMachines = _machines
        .skip(_currentMachinePage * _itemsPerPage)
        .take(_itemsPerPage)
        .toList();

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Thao tác công nhân / Quét QR
            OperatorQRBanner(onTap: _openQRScanner),

            const SizedBox(height: 20),

            // 2. Section Header: Danh Sách Máy Phụ Trách
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DANH SÁCH MÁY PHỤ TRÁCH (${_machines.length})',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_machines.isNotEmpty) {
                      MachineDetailModal.show(context, _machines.first);
                    }
                  },
                  child: const Text(
                    'CHẠM XEM CHI TIẾT',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. Machines List
            if (_isLoading && _machines.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),
            ] else if (_machines.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Không có máy móc nào trong danh sách',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pagedMachines.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final machine = pagedMachines[index];
                  final globalIndex =
                      _currentMachinePage * _itemsPerPage + index;
                  return OperatorMachineCard(
                    machine: machine,
                    index: globalIndex,
                    onTap: () => MachineDetailModal.show(context, machine),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Pagination Controls
              OperatorPaginationControls(
                currentPage: _currentMachinePage,
                totalPages: totalPages,
                onPrevPressed: () {
                  setState(() {
                    _currentMachinePage--;
                  });
                },
                onNextPressed: () {
                  setState(() {
                    _currentMachinePage++;
                  });
                },
              ),
            ],

            const SizedBox(height: 24),

            // 4. Section Header: Theo Dõi Phiếu Báo Lỗi SOS
            Text(
              'THEO DÕI PHIẾU BÁO LỖI SOS (${_tickets.length})',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),

            // 5. Tickets List
            if (_isLoading && _tickets.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),
            ] else if (_tickets.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 40,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hiện không có phiếu báo lỗi SOS nào cần theo dõi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tickets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final ticket = _tickets[index];
                  return SosTicketCard(
                    ticket: ticket,
                    index: index,
                  );
                },
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
