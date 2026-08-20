import 'package:flutter/material.dart';

enum SupervisorTimeFilter { today, sevenDays, thirtyDays }

class SupervisorHeaderBar extends StatelessWidget {
  final String supervisorName;
  final String workshopName;
  final double thresholdAmount;
  final SupervisorTimeFilter selectedFilter;
  final ValueChanged<SupervisorTimeFilter> onFilterChanged;
  final VoidCallback onOpenAddMachine;
  final VoidCallback onOpenThresholdConfig;

  const SupervisorHeaderBar({
    super.key,
    this.supervisorName = 'Quản Đốc Phân Xưởng',
    this.workshopName = 'WS-01',
    this.thresholdAmount = 2000000.0,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onOpenAddMachine,
    required this.onOpenThresholdConfig,
  });

  String _formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    return str.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'QĐ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  supervisorName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$workshopName • Ngưỡng: ${_formatCurrency(thresholdAmount)}đ',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  IconButton(
                    onPressed: onOpenAddMachine,
                    tooltip: 'Thêm máy mới',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 16,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onOpenThresholdConfig,
                    tooltip: 'Cấu hình ngưỡng',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Khung Giờ:',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _buildFilterTab(
                      label: 'Hôm nay',
                      isSelected: selectedFilter == SupervisorTimeFilter.today,
                      onTap: () => onFilterChanged(SupervisorTimeFilter.today),
                    ),
                    _buildFilterTab(
                      label: '7 ngày',
                      isSelected: selectedFilter == SupervisorTimeFilter.sevenDays,
                      onTap: () => onFilterChanged(SupervisorTimeFilter.sevenDays),
                    ),
                    _buildFilterTab(
                      label: '30 ngày',
                      isSelected: selectedFilter == SupervisorTimeFilter.thirtyDays,
                      onTap: () => onFilterChanged(SupervisorTimeFilter.thirtyDays),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
