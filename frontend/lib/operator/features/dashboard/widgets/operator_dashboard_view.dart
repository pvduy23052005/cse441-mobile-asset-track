import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/offline/widgets/offline_sync_banner.dart';
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

class _OperatorDashboardViewState extends ConsumerState<OperatorDashboardView> {
  late final PageController _machinePageController;

  @override
  void initState() {
    super.initState();
    _machinePageController = PageController(
      initialPage: ref.read(operatorDashboardPageProvider),
    );
  }

  @override
  void dispose() {
    _machinePageController.dispose();
    super.dispose();
  }

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

    final totalMachinePages = (machines.isEmpty)
        ? 1
        : (machines.length / operatorDashboardItemsPerPage).ceil();
    final safeMachinePage = currentMachinePage.clamp(0, totalMachinePages - 1);

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
      child: Column(
        children: [
          const OfflineSyncBanner(),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OperatorQRBanner(onTap: _openQRScanner),

                  const SizedBox(height: 20),

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

                  if (isLoading && machines.isEmpty) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
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
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ] else if (totalMachinePages == 1) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: machines.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (ctx, index) {
                        final machine = machines[index];
                        return OperatorMachineCard(
                          machine: machine,
                          index: index,
                          onTap: () =>
                              MachineDetailModal.show(context, machine),
                        );
                      },
                    ),
                  ] else ...[
                    SizedBox(
                      height: 242,
                      child: PageView.builder(
                        controller: _machinePageController,
                        itemCount: totalMachinePages,
                        onPageChanged: (page) {
                          ref
                                  .read(operatorDashboardPageProvider.notifier)
                                  .state =
                              page;
                        },
                        itemBuilder: (ctx, pageIdx) {
                          final startIdx =
                              pageIdx * operatorDashboardItemsPerPage;
                          final endIdx =
                              (startIdx + operatorDashboardItemsPerPage).clamp(
                                0,
                                machines.length,
                              );
                          final pageMachines = machines.sublist(
                            startIdx,
                            endIdx,
                          );

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pageMachines.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, idx) {
                              final machine = pageMachines[idx];
                              final globalIndex = startIdx + idx;
                              return OperatorMachineCard(
                                machine: machine,
                                index: globalIndex,
                                onTap: () =>
                                    MachineDetailModal.show(context, machine),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    OperatorPaginationDots(
                      currentPage: safeMachinePage,
                      totalPages: totalMachinePages,
                      onDotTapped: (targetPage) {
                        _machinePageController.animateToPage(
                          targetPage,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

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

                  if (isLoading && tickets.isEmpty) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
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
                            safeTicketPage *
                                operatorTicketDashboardItemsPerPage +
                            index;
                        return SosTicketCard(
                          ticket: ticket,
                          index: globalIndex,
                        );
                      },
                    ),

                    if (totalTicketPages > 1) ...[
                      const SizedBox(height: 12),
                      OperatorPaginationControls(
                        currentPage: safeTicketPage,
                        totalPages: totalTicketPages,
                        onPrevPressed: safeTicketPage > 0
                            ? () {
                                ref
                                        .read(
                                          operatorTicketDashboardPageProvider
                                              .notifier,
                                        )
                                        .state =
                                    safeTicketPage - 1;
                              }
                            : null,
                        onNextPressed: safeTicketPage < totalTicketPages - 1
                            ? () {
                                ref
                                        .read(
                                          operatorTicketDashboardPageProvider
                                              .notifier,
                                        )
                                        .state =
                                    safeTicketPage + 1;
                              }
                            : null,
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
