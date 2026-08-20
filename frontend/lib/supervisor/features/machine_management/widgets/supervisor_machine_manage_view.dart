import 'package:flutter/material.dart';
import '../../../../core/models/machine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../services/machine_service.dart';
import 'supervisor_machine_card.dart';

class SupervisorMachineManageView extends StatefulWidget {
  const SupervisorMachineManageView({super.key});

  @override
  State<SupervisorMachineManageView> createState() =>
      _SupervisorMachineManageViewState();
}

class _SupervisorMachineManageViewState
    extends State<SupervisorMachineManageView> {
  final MachineService _machineService = MachineService();
  final TextEditingController _searchController = TextEditingController();

  List<MachineModel> _machines = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMachines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final machines = await _machineService.getMachines();
      if (mounted) {
        setState(() {
          _machines = machines;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _onMachineUpdated(MachineModel updated) {
    setState(() {
      final index = _machines.indexWhere((m) => m.id == updated.id);
      if (index != -1) {
        _machines[index] = updated;
      }
    });
  }

  List<MachineModel> get _filteredMachines {
    return _machines.where((m) {
      final status = m.status.toUpperCase();
      final statusMatch = _selectedStatusFilter == 'ALL' ||
          status == _selectedStatusFilter ||
          (_selectedStatusFilter == 'INACTIVE' &&
              (status == 'INACTIVE' || status == 'ERROR'));

      final q = _searchQuery.trim().toLowerCase();
      final queryMatch = q.isEmpty ||
          m.name.toLowerCase().contains(q) ||
          m.code.toLowerCase().contains(q) ||
          m.model.toLowerCase().contains(q) ||
          m.location.toLowerCase().contains(q);

      return statusMatch && queryMatch;
    }).toList();
  }

  int get _activeCount =>
      _machines.where((m) => m.status.toUpperCase() == 'ACTIVE').length;

  int get _maintenanceCount =>
      _machines.where((m) => m.status.toUpperCase() == 'MAINTENANCE').length;

  int get _otherCount =>
      _machines.where((m) {
        final s = m.status.toUpperCase();
        return s != 'ACTIVE' && s != 'MAINTENANCE';
      }).length;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchMachines,
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản Lý Máy Móc & Thiết Bị Phân Xưởng',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.foregroundColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Giám sát tình trạng vận hành và quản lý kỹ thuật thiết bị',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Tổng số máy',
                          count: _machines.length,
                          color: AppTheme.foregroundColor,
                          icon: Icons.precision_manufacturing_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Hoạt động',
                          count: _activeCount,
                          color: AppTheme.primaryColor,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Bảo trì / Lỗi',
                          count: _maintenanceCount + _otherCount,
                          color: const Color(0xFFD97706),
                          icon: Icons.build_circle_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, mã máy, vị trí hoặc model...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.mutedForegroundColor,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tất cả', 'ALL', _machines.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('Hoạt động', 'ACTIVE', _activeCount),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Bảo trì',
                          'MAINTENANCE',
                          _maintenanceCount,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Tạm ngưng / Lỗi',
                          'INACTIVE',
                          _otherCount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
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
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
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
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchMachines,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_filteredMachines.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppTheme.mutedForegroundColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Không tìm thấy thiết bị phù hợp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Vui lòng thử tìm kiếm với từ khóa khác hoặc thay đổi bộ lọc.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.mutedForegroundColor,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty ||
                          _selectedStatusFilter != 'ALL') ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedStatusFilter = 'ALL';
                            });
                          },
                          child: const Text('Xóa bộ lọc'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final machine = _filteredMachines[index];
                  return SupervisorMachineCard(
                    machine: machine,
                    onStatusUpdated: _onMachineUpdated,
                  );
                },
                childCount: _filteredMachines.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.mutedForegroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedStatusFilter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedStatusFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.foregroundColor,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected ? Colors.white : AppTheme.mutedForegroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
