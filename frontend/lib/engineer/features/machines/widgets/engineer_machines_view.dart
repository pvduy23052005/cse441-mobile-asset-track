import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/machine_model.dart';
import '../services/engineer_machine_service.dart';
import 'machine_card.dart';

class EngineerMachinesView extends StatefulWidget {
  const EngineerMachinesView({super.key});

  @override
  State<EngineerMachinesView> createState() => _EngineerMachinesViewState();
}

class _EngineerMachinesViewState extends State<EngineerMachinesView> {
  final EngineerMachineService _service = EngineerMachineService();

  List<MachineModel> _machines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMachinesData();
  }

  Future<void> _loadMachinesData() async {
    setState(() => _isLoading = true);
    final list = await _service.fetchMachinesFromApi();

    if (mounted) {
      setState(() {
        _machines = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: RefreshIndicator(
        onRefresh: _loadMachinesData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title matching ui prototype: TẤT CẢ THIẾT BỊ PHÂN XƯỞNG
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TẤT CẢ THIẾT BỊ PHÂN XƯỞNG (${_machines.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF475569), // Slate-600
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Chạm xem chi tiết',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF047857), // Emerald-700
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                )
              else if (_machines.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text(
                      'Hiện chưa có máy móc nào trong CSDL Backend',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.mutedForegroundColor,
                      ),
                    ),
                  ),
                )
              else
                ..._machines.map(
                  (m) => MachineCard(
                    machine: m,
                    onTap: (item) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mở lý lịch thiết bị ${item.code} - ${item.name}',
                          ),
                          backgroundColor: AppTheme.foregroundColor,
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
