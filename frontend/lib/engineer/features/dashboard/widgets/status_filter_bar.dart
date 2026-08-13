import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/work_order_model.dart';

enum StatusFilterType { all, pending, inProgress, completed }

class StatusFilterBar extends StatelessWidget {
  final StatusFilterType activeFilter;
  final List<WorkOrderModel> workOrders;
  final ValueChanged<StatusFilterType> onFilterChanged;

  const StatusFilterBar({
    super.key,
    required this.activeFilter,
    required this.workOrders,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allCount = workOrders.length;
    final pendingCount = workOrders.where((w) => w.status == WorkOrderStatus.pending).length;
    final inProgressCount = workOrders.where((w) => w.status == WorkOrderStatus.inProgress || w.status == WorkOrderStatus.rejected).length;
    final completedCount = workOrders.where((w) => w.status == WorkOrderStatus.completed || w.status == WorkOrderStatus.approved).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildFilterChip(
            type: StatusFilterType.all,
            label: 'Tất cả ($allCount)',
            isSelected: activeFilter == StatusFilterType.all,
            activeBgColor: AppTheme.foregroundColor,
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            type: StatusFilterType.pending,
            label: 'Chờ tiếp nhận ($pendingCount)',
            isSelected: activeFilter == StatusFilterType.pending,
            activeBgColor: const Color(0xFFE11D48), // Rose-600
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            type: StatusFilterType.inProgress,
            label: 'Đang xử lý ($inProgressCount)',
            isSelected: activeFilter == StatusFilterType.inProgress,
            activeBgColor: const Color(0xFF0284C7), // Sky-600
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            type: StatusFilterType.completed,
            label: 'Hoàn thành ($completedCount)',
            isSelected: activeFilter == StatusFilterType.completed,
            activeBgColor: const Color(0xFF059669), // Emerald-600
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required StatusFilterType type,
    required String label,
    required bool isSelected,
    required Color activeBgColor,
  }) {
    return InkWell(
      onTap: () => onFilterChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeBgColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppTheme.mutedForegroundColor,
          ),
        ),
      ),
    );
  }
}
