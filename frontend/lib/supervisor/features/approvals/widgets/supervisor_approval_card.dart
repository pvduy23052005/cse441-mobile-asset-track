import 'package:flutter/material.dart';
import '../models/supervisor_approval_model.dart';

class SupervisorApprovalCard extends StatelessWidget {
  final SupervisorApprovalModel item;
  final VoidCallback onTap;
  final VoidCallback onSignTap;

  const SupervisorApprovalCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onSignTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isApproved = item.status == 'APPROVED';
    final bool isRejected = item.status == 'REJECTED';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: item.code.startsWith('PM')
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.code.startsWith('PM')
                              ? Icons.build_circle_outlined
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: item.code.startsWith('PM')
                              ? const Color(0xFFD97706)
                              : const Color(0xFFE11D48),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.code,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.code.startsWith('PM')
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.code.startsWith('PM')
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFFECDD3),
                          ),
                        ),
                        child: Text(
                          item.code.startsWith('PM') ? 'PM BẢO TRÌ' : 'SỰ CỐ SOS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: item.code.startsWith('PM')
                                ? const Color(0xFFB45309)
                                : const Color(0xFFBE123C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.memory_rounded,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${item.machineName} (${item.machineCode})',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.engineerName,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_toggle_off_rounded,
                          size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text(
                        'Downtime: ${item.downtimeDuration}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),

                  if (!isApproved && !isRejected)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: const Size(100, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onSignTap,
                      icon: const Icon(Icons.draw_rounded, size: 16),
                      label: const Text(
                        'Ký Nghiệm Thu',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (item.status == 'APPROVED') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: const Text(
          'Đã Nghiệm Thu',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF047857),
          ),
        ),
      );
    }

    if (item.status == 'REJECTED') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: const Text(
          'Từ Chối',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE11D48),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Text(
        'Chờ Nghiệm Thu',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFFB45309),
        ),
      ),
    );
  }
}
