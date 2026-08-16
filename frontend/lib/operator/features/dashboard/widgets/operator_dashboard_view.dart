import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/operator_dashboard_provider.dart';
import '../../../providers/operator_machines_provider.dart';
import '../../../providers/operator_tickets_provider.dart';
import '../../../widgets/operator_qr_scanner_sheet.dart';
import '../../machine/widgets/machine_detail_modal.dart';
import '../../ticket/widgets/sos_ticket_card.dart';
import 'operator_machine_card.dart';
import 'operator_pagination_controls.dart';
import 'operator_qr_banner.dart';

class OperatorDashboardView extends ConsumerStatefulWidget {
  const OperatorDashboardView({super.key});

  @override
  ConsumerState<OperatorDashboardView> createState() =>
      _OperatorDashboardViewState();
}

class _OperatorDashboardViewState
    extends ConsumerState<OperatorDashboardView> {
  void _openQRScanner() async {
    final machine = await OperatorQRScannerSheet.show(context);
    if (machine != null && mounted) {
      MachineDetailModal.show(context, machine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(operatorMachinesProvider);
    final ticketsAsync = ref.watch(operatorTicketsProvider);
    final currentMachinePage = ref.watch(operatorDashboardPageProvider);
    final currentTicketPage = ref.watch(operatorTicketDashboardPageProvider);

    final machines = machinesAsync.valueOrNull ?? [];
    final tickets = ticketsAsync.valueOrNull ?? [];
    final isLoading = machinesAsync.isLoading || ticketsAsync.isLoading;

    // 1. Phân trang Danh sách máy
    final totalMachinePages = (machines.isEmpty)
        ? 1
        : (machines.length / operatorDashboardItemsPerPage).ceil();
    final safeMachinePage = currentMachinePage.clamp(0, totalMachinePages - 1);
    final pagedMachines = machines
        .skip(safeMachinePage * operatorDashboardItemsPerPage)
        .take(operatorDashboardItemsPerPage)
        .toList();

    // 2. Phân trang Danh sách phiếu SOS
    final totalTicketPages = (tickets.isEmpty)
        ? 1
        : (tickets.length / operatorTicketDashboardItemsPerPage).ceil();
    final safeTicketPage = currentTicketPage.clamp(0, totalTicketPages - 1);
    final pagedTickets = tickets
        .skip(safeTicketPage * operatorTicketDashboardItemsPerPage)
        .take(operatorTicketDashboardItemsPerPage)
        .toList();

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () async {
        await Future.wait([
          ref.refresh(operatorMachinesProvider.future),
          ref.refresh(operatorTicketsProvider.future),
        ]);
      },
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
                  'DANH SÁCH MÁY PHỤ TRÁCH (${machines.length})',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),
                if (machines.isNotEmpty)
                  InkWell(
                    onTap: () {
                      MachineDetailModal.show(context, machines.first);
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
            if (isLoading && machines.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),
            ] else if (machines.isEmpty) ...[
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
                      safeMachinePage * operatorDashboardItemsPerPage + index;
                  return OperatorMachineCard(
                    machine: machine,
                    index: globalIndex,
                    onTap: () => MachineDetailModal.show(context, machine),
                  );
                },
              ),

              // Pagination Controls cho Máy Móc
              if (totalMachinePages > 1) ...[
                const SizedBox(height: 12),
                OperatorPaginationControls(
                  currentPage: safeMachinePage,
                  totalPages: totalMachinePages,
                  onPrevPressed: safeMachinePage > 0
                      ? () {
                          ref
                              .read(operatorDashboardPageProvider.notifier)
                              .state = safeMachinePage - 1;
                        }
                      : null,
                  onNextPressed: safeMachinePage < totalMachinePages - 1
                      ? () {
                          ref
                              .read(operatorDashboardPageProvider.notifier)
                              .state = safeMachinePage + 1;
                        }
                      : null,
                ),
              ],
            ],

            const SizedBox(height: 24),

            // 4. Section Header: Theo Dõi Phiếu Báo Lỗi SOS
            Text(
              'THEO DÕI PHIẾU BÁO LỖI SOS (${tickets.length})',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),

            // 5. Tickets List Phân Trang
            if (isLoading && tickets.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),
            ] else if (tickets.isEmpty) ...[
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
                itemCount: pagedTickets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final ticket = pagedTickets[index];
                  final globalIndex =
                      safeTicketPage * operatorTicketDashboardItemsPerPage +
                          index;
                  return SosTicketCard(
                    ticket: ticket,
                    index: globalIndex,
                  );
                },
              ),

              // Pagination Controls cho Phiếu Báo Lỗi SOS
              if (totalTicketPages > 1) ...[
                const SizedBox(height: 12),
                OperatorPaginationControls(
                  currentPage: safeTicketPage,
                  totalPages: totalTicketPages,
                  onPrevPressed: safeTicketPage > 0
                      ? () {
                          ref
                              .read(
                                  operatorTicketDashboardPageProvider.notifier)
                              .state = safeTicketPage - 1;
                        }
                      : null,
                  onNextPressed: safeTicketPage < totalTicketPages - 1
                      ? () {
                          ref
                              .read(
                                  operatorTicketDashboardPageProvider.notifier)
                              .state = safeTicketPage + 1;
                        }
                      : null,
                ),
              ],
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
