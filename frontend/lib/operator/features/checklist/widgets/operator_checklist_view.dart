import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/operator_machines_provider.dart';
import 'input_shift_hours_modal.dart';

class OperatorChecklistView extends ConsumerStatefulWidget {
  const OperatorChecklistView({super.key});

  @override
  ConsumerState<OperatorChecklistView> createState() =>
      _OperatorChecklistViewState();
}

class _OperatorChecklistViewState extends ConsumerState<OperatorChecklistView> {
  void _openInputHoursModal(MachineModel machine) {
    HapticFeedback.selectionClick();
    InputShiftHoursModal.show(
      context,
      machine: machine,
      onSuccess: () {
        ref.read(operatorMachinesProvider.notifier).refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(operatorMachinesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          await ref.read(operatorMachinesProvider.notifier).refresh();
        },
        child: machinesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(height: 12),
                Text('Lỗi tải danh sách máy: $err'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(operatorMachinesProvider.notifier).refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (machines) {
            if (machines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.precision_manufacturing_outlined,
                        size: 40,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Không có thiết bị nào',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  '1. Khai báo giờ máy chạy ca này (${machines.length} máy)',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFD97706),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Bắt buộc: ',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              TextSpan(
                                text:
                                    'Operator phải khai báo chỉ số giờ máy mỗi ca trực để hệ thống ghi nhận chấm công và tính lương. Không khai báo sẽ không được tính lương ca làm việc.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                ...List.generate(machines.length, (index) {
                  final machine = machines[index];
                  final machineCode = machine.code.isNotEmpty
                      ? machine.code
                      : 'MC-${machine.id.substring(0, 3).toUpperCase()}';
                  final machineName = machine.name.isNotEmpty
                      ? machine.name
                      : 'Thiết bị';
                  final hours = machine.runningHours.toDouble();

                  final List<Map<String, dynamic>> iconStyles = [
                    {
                      'bg': const Color(0xFFECFDF5),
                      'border': const Color(0xFFA7F3D0),
                      'color': const Color(0xFF059669),
                      'icon': Icons.developer_board_rounded,
                    },
                    {
                      'bg': const Color(0xFFFFE4E6),
                      'border': const Color(0xFFFECDD3),
                      'color': const Color(0xFFE11D48),
                      'icon': Icons.memory_rounded,
                    },
                    {
                      'bg': const Color(0xFFFEF3C7),
                      'border': const Color(0xFFFDE68A),
                      'color': const Color(0xFFD97706),
                      'icon': Icons.precision_manufacturing_rounded,
                    },
                  ];

                  final style = iconStyles[index % iconStyles.length];
                  final isTopCard = index == 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isTopCard
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFFE2E8F0),
                        width: isTopCard ? 1.4 : 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: style['bg'] as Color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: style['border'] as Color,
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                style['icon'] as IconData,
                                color: style['color'] as Color,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$machineCode - $machineName',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Giờ hiện tại: ${hours.toStringAsFixed(1)}h',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _openInputHoursModal(machine),
                            child: const Text(
                              'Nhập Giờ Ca',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
