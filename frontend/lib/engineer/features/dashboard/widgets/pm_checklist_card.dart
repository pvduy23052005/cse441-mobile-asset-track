import 'package:flutter/material.dart';

import '../models/work_order_model.dart';

class PmChecklistCard extends StatelessWidget {
  final PMChecklistModel pmChecklist;
  final ValueChanged<PMChecklistModel> onOpenPM;

  const PmChecklistCard({
    super.key,
    required this.pmChecklist,
    required this.onOpenPM,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // slate-50
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Left Info Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Code & Machine Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pmChecklist.code,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: Color(0xFFD97706), // Amber-600
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pmChecklist.machineName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Scheduled Hours
                Text(
                  'Mốc số giờ: ${pmChecklist.scheduledHours}h',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right Action Button: Thực Hiện PM (Solid Orange)
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: () => onOpenPM(pmChecklist),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B), // Amber/Orange-500
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Thực Hiện PM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
