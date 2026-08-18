import 'package:flutter/material.dart';
import 'package:frontend/engineer/features/ticket_management/models/ticket_model.dart';
import '../../models/machine_model.dart';
import '../../services/machine_history_service.dart';

class MachineHistoryTab extends StatefulWidget {
  final MachineModel machine;
  final ValueChanged<int>? onCountChanged;

  const MachineHistoryTab({
    super.key,
    required this.machine,
    this.onCountChanged,
  });

  @override
  State<MachineHistoryTab> createState() => _MachineHistoryTabState();
}

class _MachineHistoryTabState extends State<MachineHistoryTab> {
  List<TicketModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final result = await MachineHistoryService().fetchHistoryForMachine(
      widget.machine.id,
    );
    if (mounted) {
      setState(() {
        _history = result;
        _isLoading = false;
      });
      widget.onCountChanged?.call(result.length);
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF008B99),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded,
                size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            const Text(
              'Chưa có lịch sử bảo trì cho thiết bị này.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _history.map((ticket) => _buildHistoryItem(ticket)).toList(),
    );
  }

  Widget _buildHistoryItem(TicketModel ticket) {
    final bool isClosed = ticket.status == TicketStatus.closed;
    final bool isRejected = ticket.status == TicketStatus.rejected;
    final bool isPendingApproval = ticket.status == TicketStatus.pendingApproval;

    final Color iconColor = isClosed
        ? const Color(0xFF059669)
        : isRejected
            ? const Color(0xFFE11D48)
            : const Color(0xFFD97706);

    final Color badgeColor = isClosed
        ? const Color(0xFF047857)
        : isRejected
            ? const Color(0xFFBE123C)
            : const Color(0xFF92400E);

    final Color badgeBg = isClosed
        ? const Color(0xFFECFDF5)
        : isRejected
            ? const Color(0xFFFFF1F2)
            : const Color(0xFFFFFBEB);

    final String badgeLabel = isClosed
        ? 'NGHIỆM THU'
        : isRejected
            ? 'TỪ CHỐI'
            : isPendingApproval
                ? 'CHỜ DUYỆT'
                : 'ĐANG SỬA';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.code,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: iconColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ticket.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if ((ticket.reporterName ?? '').isNotEmpty)
                        'Báo bởi: ${ticket.reporterName}',
                      if ((ticket.engineerName ?? '').isNotEmpty)
                        'Kỹ sư: ${ticket.engineerName}',
                      _formatDate(ticket.createdAt),
                    ].join(' • '),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
