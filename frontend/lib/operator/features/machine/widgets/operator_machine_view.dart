import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/operator_machines_provider.dart';
import 'machine_card.dart';

class OperatorMachineView extends ConsumerStatefulWidget {
  const OperatorMachineView({super.key});

  @override
  ConsumerState<OperatorMachineView> createState() =>
      _OperatorMachineViewState();
}

class _OperatorMachineViewState extends ConsumerState<OperatorMachineView> {
  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(filteredOperatorMachinesProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(operatorMachinesProvider.future),
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Section Title: TẤT CẢ THIẾT BỊ PHÂN XƯỞNG
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'TẤT CẢ THIẾT BỊ PHÂN XƯỞNG',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF334155),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          machinesAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải danh sách thiết bị...',
                      style: TextStyle(
                        color: AppTheme.mutedForegroundColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(operatorMachinesProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (machines) {
              if (machines.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.precision_manufacturing_outlined,
                            size: 56,
                            color: AppTheme.mutedForegroundColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có thiết bị nào trong phân xưởng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.foregroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final machine = machines[index];
                    return MachineCard(machine: machine);
                  },
                  childCount: machines.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
