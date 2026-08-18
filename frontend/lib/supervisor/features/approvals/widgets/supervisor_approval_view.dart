import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/supervisor_approval_model.dart';
import '../services/supervisor_approval_service.dart';
import 'supervisor_approval_card.dart';
import 'supervisor_digital_signoff_modal.dart';

class SupervisorApprovalView extends StatefulWidget {
  const SupervisorApprovalView({super.key});

  @override
  State<SupervisorApprovalView> createState() => _SupervisorApprovalViewState();
}

class _SupervisorApprovalViewState extends State<SupervisorApprovalView> {
  final SupervisorApprovalService _approvalService = SupervisorApprovalService();
  List<SupervisorApprovalModel> _items = [];
  bool _isLoading = true;
  Timer? _expiryCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadApprovalsData();
    // Periodic timer to check and auto-expire items older than 1 hour
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {}); // Trigger rebuild to filter out expired items
      }
    });
  }

  @override
  void dispose() {
    _expiryCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadApprovalsData() async {
    setState(() {
      _isLoading = true;
    });
    final data = await _approvalService.fetchPendingApprovalsFromApi();
    if (mounted) {
      setState(() {
        _items = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(SupervisorApprovalModel item, String signatureData) async {
    final success = await _approvalService.approveTicket(item.id, signatureData);
    if (success && mounted) {
      setState(() {
        _items = _items.map((i) {
          if (i.id == item.id) {
            return SupervisorApprovalModel(
              id: i.id,
              code: i.code,
              title: i.title,
              machineId: i.machineId,
              machineCode: i.machineCode,
              machineName: i.machineName,
              engineerName: i.engineerName,
              downtimeDuration: i.downtimeDuration,
              usedSpareParts: i.usedSpareParts,
              description: i.description,
              status: 'APPROVED',
              signatureUrl: signatureData,
              createdAt: i.createdAt,
              actionTimestamp: DateTime.now(),
            );
          }
          return i;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đã ký nghiệm thu thành công phiếu ${item.code}! Máy ${item.machineCode} đã về Active (Tự động ẩn sau 1 tiếng).'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    }
  }

  Future<void> _handleReject(SupervisorApprovalModel item, String reason) async {
    final success = await _approvalService.rejectTicket(item.id, reason);
    if (success && mounted) {
      setState(() {
        _items = _items.map((i) {
          if (i.id == item.id) {
            return SupervisorApprovalModel(
              id: i.id,
              code: i.code,
              title: i.title,
              machineId: i.machineId,
              machineCode: i.machineCode,
              machineName: i.machineName,
              engineerName: i.engineerName,
              downtimeDuration: i.downtimeDuration,
              usedSpareParts: i.usedSpareParts,
              description: i.description,
              status: 'REJECTED',
              rejectionReason: reason,
              createdAt: i.createdAt,
              actionTimestamp: DateTime.now(),
            );
          }
          return i;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đã từ chối nghiệm thu phiếu ${item.code}. Đã chuyển lại cho Kỹ sư ME (Tự động ẩn sau 1 tiếng).'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _openSignoffModal(SupervisorApprovalModel item) {
    SupervisorDigitalSignoffModal.show(
      context,
      item: item,
      onConfirmSign: (sigData) => _handleApprove(item, sigData),
      onReject: (reason) => _handleReject(item, reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Filter active items:
    // Approved / Rejected items automatically expire and disappear after 1 hour (60 minutes)
    final visibleItems = _items.where((i) {
      if (i.status == 'APPROVED' || i.status == 'REJECTED') {
        if (i.actionTimestamp != null) {
          return now.difference(i.actionTimestamp!).inMinutes < 60;
        }
      }
      return true;
    }).toList();

    final pendingCount = visibleItems.where((i) => i.status == 'COMPLETED' || i.status == 'PENDING_APPROVAL' || i.status == 'SUBMITTED').length;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: RefreshIndicator(
        onRefresh: _loadApprovalsData,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Counter Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NHIỆM VỤ & PHÊ DUYỆT NGHIỆM THU',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      'Cần ký: $pendingCount phiếu',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryColor),
                  ),
                )
              else if (visibleItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 40,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Đã hoàn tất nghiệm thu toàn bộ!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final item = visibleItems[index];
                    return SupervisorApprovalCard(
                      item: item,
                      onTap: () => _openSignoffModal(item),
                      onSignTap: () => _openSignoffModal(item),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
